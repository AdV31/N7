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
        long int buffer[100];
        int n = read(t[0], buffer, sizeof(buffer));
        if (n > 0) {
            buffer[n] = '\0'; // Null-terminate the string
            printf("%ld \n", *buffer);
        }
        close(t[0]); // Ferme la lecture
    } else {
        // Père
        close(t[0]); // Ferme la lecture
        long int message = 9965668756698;
        write(t[1], &message, sizeof(message));
        close(t[1]); // Ferme l'écriture
    }
}