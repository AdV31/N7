#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <sched.h>
#include <unistd.h>     // fork, getpid, getppid
#include <sys/wait.h>     // wait
#include <fcntl.h>
#include <dirent.h>

#define N 10

int main(int argc, char *argv[]) {
    __uint8_t tableau[N];
    int t[2];
    pipe(t);
    pid_t pid_fils = fork();
    if (pid_fils == 0) {
        // Fils
        close(t[1]); // Ferme l'écriture
        int buffer;
        int n = read(t[0], &buffer, sizeof(int));
        for (int i = 0; i < N*10; i++) {
            n = read(t[0], &buffer, sizeof(int));
        }
        printf("sortie de boucle\n");
        close(t[0]); // Ferme la lecture
    } else {
        // Père
        close(t[0]); // Ferme la lecture
        for (int i = 0; i < N; i++) {
            int message = tableau[i];
            int oui  = write(t[1], &message, sizeof(int));
            sleep(1);
            printf("%d \n", oui);
        }
        sleep(5);
        close(t[1]); // Ferme l'écriture
    }
}