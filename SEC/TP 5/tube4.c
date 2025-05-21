#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <sched.h>
#include <unistd.h>     // fork, getpid, getppid
#include <sys/wait.h>     // wait
#include <fcntl.h>
#include <dirent.h>

int main(int argc, char *argv[]) {
    int t[2];
    pipe(t);
    pid_t pid_fils = fork();
    if (pid_fils == 0) {
        // Fils
        close(t[1]); // Ferme l'écriture
        int buffer;
        int n = read(t[0], &buffer, sizeof(int));
        while (buffer != 0) {
            printf("%d \n", buffer);
            n = read(t[0], &buffer, sizeof(int));
        }
        printf("sortie de boucle\n");
        close(t[0]); // Ferme la lecture
    } else {
        // Père
        close(t[0]); // Ferme la lecture
        for (int i = 100; i >= 0; i--) {
            int message = i;
            write(t[1], &message, sizeof(int));
        }
        sleep(10); // Sleep pour laisser le temps au fils de lire
        close(t[1]); // Ferme l'écriture
    }
}