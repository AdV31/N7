#include <stdio.h>
#include <stdlib.h>
#include "readcmd.h"
#include <stdbool.h>
#include <string.h>
#include <sched.h>
#include <unistd.h>     // fork, getpid, getppid
#include <sys/wait.h>     // wait
#include <fcntl.h>
#include <dirent.h>

bool forground;
pid_t pid_forground;


void traitementFini(int sig){
    int status;
    pid_t pid_termine = waitpid(-1, &status, WNOHANG|WUNTRACED|WCONTINUED);
    
    if (pid_termine == -1) {
        perror("il n'y a plus de processus à attendre");
        exit(EXIT_FAILURE);
    }

    if (pid_termine == pid_forground){
        forground = false;
        if (WIFEXITED(status)){
            printf("Le processus fils de pid : %d vient de se terminer ", pid_termine);
            printf("avec le code %d ", sig);
        } else if (WIFSTOPPED(status)){
            printf("Le processus fils de pid : %d est arrete ", pid_termine);
            printf("avec le signal %d ", sig);
        } else if (WIFCONTINUED(status)){
            printf("Le processus fils de pid : %d est relance ", pid_termine);
            printf("avec le signal %d ", sig);
        }
    }
}

void traintementInt(int sig){
    if (forground){
        kill(pid_forground, SIGINT);
        printf("\nSignal d'interruption envoyé au processus fils de pid : %d", pid_forground);
        printf(" avec le signal %d ", sig);
    }
}

void traitementTSTP(int sig){
    if (forground){
        kill(pid_forground, SIGTSTP);
        printf("\nSignal d'arret envoyé au processus fils de pid : %d", pid_forground);
        printf(" avec le signal %d \n", sig);
    }
}


int main(void) {
    bool fini= false;
    int fichier_out, fichier_in;
    
    struct sigaction actionFini;
    actionFini.sa_handler = traitementFini;
    actionFini.sa_flags = SA_RESTART;
    sigemptyset(&actionFini.sa_mask);
    
    if (sigaction(SIGCHLD, &actionFini, NULL) ==-1){
        perror("sigaction(SIGCHLD)");
        exit(EXIT_FAILURE);
    }

    struct sigaction actionInt;
    actionInt.sa_handler = traintementInt;
    actionInt.sa_flags = SA_RESTART;
    sigemptyset(&actionInt.sa_mask);

    if (sigaction(SIGINT, &actionInt, NULL) ==-1){
        perror("sigaction(SIGINT)");
        exit(EXIT_FAILURE);
    }

    struct sigaction actionTSTP;
    actionTSTP.sa_handler = traitementTSTP;
    actionTSTP.sa_flags = SA_RESTART;
    sigemptyset(&actionTSTP.sa_mask);

    if (sigaction(SIGTSTP, &actionTSTP, NULL) ==-1){
        perror("sigaction(SIGTSTP)");
        exit(EXIT_FAILURE);
    }
    


    while (!fini) {
        printf("> ");
        struct cmdline *commande= readcmd();

        if (commande == NULL) {
            // commande == NULL -> erreur readcmd()
            perror("erreur lecture commande \n");
            exit(EXIT_FAILURE);
    
        } else {

            if (commande->err) {
                // commande->err != NULL -> commande->seq == NULL
                printf("erreur saisie de la commande : %s\n", commande->err);
        
            } else {

                /* Pour le moment le programme ne fait qu'afficher les commandes
                   tapees et les affiche à l'écran.
                   Cette partie est à modifier pour considérer l'exécution de ces
                   commandes
                */
                int indexseq= 0;
                char **cmd;
                int tube1[2];
                int tube2[2];
                pipe(tube1);
                while ((cmd= commande->seq[indexseq])) {
                    
                    if (indexseq != 0) {
                        tube2[0] = tube1[0];
                        tube2[1] = tube1[1];
                    }

                    if (commande->seq[indexseq + 1] != NULL) {
                        pipe(tube2);
                    }

                    if (cmd[0]) {
                        if (strcmp(cmd[0], "exit") == 0) {
                            fini= true;
                            printf("Au revoir ...\n");
                        }
                        
                        if (strcmp(cmd[0], "cd") == 0 || strcmp(cmd[0], "dir") == 0) {
                            char *chemin_dir;
                            char *rep = cmd[1];
                            if (rep != NULL) {
                                chemin_dir = rep;
                            } else {
                                rep = getenv("HOME");
                                chemin_dir = getcwd(NULL, 0);
                            }
                            
                            if (strcmp(cmd[0], "cd") == 0) {
                                if (chdir(rep) == -1) {
                                    perror("cd");
                                }
                            } else if (strcmp(cmd[0], "dir") == 0) {
                                DIR *rep = opendir(chemin_dir);
                                if (rep == NULL) {
                                    perror("dir");
                                } else {
                                    struct dirent *ent;
                                    while ((ent = readdir(rep)) != NULL) {
                                        printf("%s\n", ent->d_name);
                                    }
                                    closedir(rep);
                                }
                            }
                        }
                        
                        else {

                            printf("commande : ");
                                pid_t pid_fils = fork();
                                printf("%s ", cmd[0]);
                                if (pid_fils == -1) {
                                    perror("Error création du processus");
                                    exit(EXIT_FAILURE);
                                } else if (pid_fils == 0) {
                                    
                                    if (indexseq != 0) {
                                        dup2(tube1[0], 0);
                                    }

                                    if (commande->seq[indexseq + 1] != NULL) {
                                        dup2(tube2[1], 1);
                                    }

                                    if (indexseq != 0) {
                                        close(tube1[0]);
                                        close(tube1[1]);
                                    }

                                    if (commande->seq[indexseq + 1] != NULL) {
                                        close(tube2[0]);
                                        close(tube2[1]);
                                    }

                                    if (commande->backgrounded != NULL) {
                                        setpgrp();
                                    }

                                    if (commande->in != NULL) {
                                        fichier_in = open(commande->in, O_RDONLY);
                                        if (fichier_in == -1) {
                                            perror("Erreur ouverture fichier d'entrée");
                                            exit(EXIT_FAILURE);
                                        }
                                        
                                        dup2(fichier_in, 0);
                                    }
    
                                    if (commande->out != NULL) {
                                        fichier_out = open(commande->out, O_WRONLY | O_CREAT | O_TRUNC, 0644);
                                        if (fichier_out == -1) {
                                            perror("Erreur ouverture fichier de sortie");
                                            exit(EXIT_FAILURE);
                                        }
    
                                        dup2(fichier_out, 1);
                                    }

                                    int execution = execvp(cmd[0],cmd);

                                    if (execution == -1){
                                        perror("Error execution");
                                        exit(EXIT_FAILURE);
                                    }
                                } else {
                                    
                                    if (indexseq != 0) {
                                        close(tube1[0]);
                                        close(tube1[1]);
                                    }

                                    if (commande->seq[indexseq + 1] != NULL) {
                                        close(tube2[0]);
                                        close(tube2[1]);
                                    }

                                    if (commande->backgrounded == NULL) {
                                        pid_forground = pid_fils;
                                        forground = true;
                                        while (forground){
                                            pause();
                                        }
                                    }
                                }
                            printf("\n");
                        }

                        indexseq++;
                    }
                }
            }
        }
    }
    return EXIT_SUCCESS;
}
