#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>

int main(int argc, char *argv[]) {
    #define BUFSIZE 1024
    char* buffer = (char*)malloc(BUFSIZE*sizeof(char));
    int source = open(argv[1], O_RDONLY);
    int destination = open(argv[2],  O_CREAT | O_WRONLY | O_TRUNC, 0644);
    
    if (source == -1 || destination == -1) {
        perror("Erreur d'ouverture de fichier");
        exit(EXIT_FAILURE);
    }

    ssize_t lus = read(source, buffer, BUFSIZE);
    if (lus == -1) {
        perror("Erreur de lecture du fichier");
        free(buffer);
        close(source);
        close(destination);
        exit(EXIT_FAILURE);
    }

    while (lus > 0) {
        ssize_t ecrits = write(destination, buffer, lus);
        if (ecrits == -1) {
            perror("Erreur d'écriture dans le fichier");
            free(buffer);
            close(source);
            close(destination);
            exit(EXIT_FAILURE);
        }
        
        lus = read(source, buffer, BUFSIZE);
        if (lus == -1) {
            perror("Erreur de lecture du fichier");
            free(buffer);
            close(source);
            close(destination);
            exit(EXIT_FAILURE);
        }
    }

    close(source);
    close(destination);
    free(buffer);
}