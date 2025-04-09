#define _GNU_SOURCE
#include "liste_noeud.h"
#include <stdlib.h>
#include <math.h>

struct cellule_t {
    noeud_id_t noeud, precedent;
    float distance;
    struct cellule_t* suivante;
};

typedef struct cellule_t cellule_t;

struct liste_noeud_t {
    cellule_t* debut;
    cellule_t* fin;
};

liste_noeud_t* creer_liste() {
    liste_noeud_t* liste = (liste_noeud_t*)malloc(sizeof(liste_noeud_t));
    
    if (liste == NULL) {
        printf("Erreur d'allocation de mémoire pour la liste\n");
        return NULL;
    }

    liste->debut = NULL;
    liste->fin = NULL;

    return liste;
}

void detruire_liste(liste_noeud_t** liste_ptr) {
    if (liste_ptr != NULL){
        if ((*liste_ptr)->debut != NULL) {
            while ((*liste_ptr)->debut != NULL) {
                cellule_t* courant = (*liste_ptr)->debut;
                free(courant);
                (*liste_ptr)->debut = (*liste_ptr)->debut->suivante;
            }
        }
        
        free(*liste_ptr);
        
        *liste_ptr = NULL;
    }
    
}

bool est_vide_liste(const liste_noeud_t* liste) {
    return liste == NULL || (liste->debut == NULL);
}

bool contient_noeud_liste(const liste_noeud_t* liste, noeud_id_t noeud) {
    cellule_t* courant = liste->debut;
    while(courant != liste->fin) {
        if(courant->noeud == noeud) {
            return true;
        }
        courant = courant->suivante;
    }
    return courant->noeud == noeud;
}

bool contient_arrete_liste(const liste_noeud_t* liste, noeud_id_t source, noeud_id_t destination) {
    if(liste == NULL) {
        return false;
    }
    return contient_noeud_liste(liste, source) && contient_noeud_liste(liste, destination);
}

float distance_noeud_liste(const liste_noeud_t* liste, noeud_id_t noeud) {
    cellule_t* courant = liste->debut;
    while(courant != liste->fin) {
        if(courant->noeud == noeud) {
            return courant->distance;
        }
        courant = courant->suivante;
    }
    if(courant->noeud == noeud) {
        return courant->distance;
    }
    return INFINITY;
}

noeud_id_t precedent_noeud_liste(const liste_noeud_t* liste, noeud_id_t noeud) {
    cellule_t* courant = liste->debut;
    while(courant != liste->fin) {
        if(courant->noeud == noeud) {
            return courant->precedent;
        }
        courant = courant->suivante;
    }
    if(courant->noeud == noeud) {
            return courant->precedent;
        }
    return NO_ID;
}

noeud_id_t min_noeud_liste(const liste_noeud_t* liste) {
    if(liste == NULL || liste->debut == NULL) {
        return NO_ID;
    } else {
        cellule_t* courant = liste->debut;
        double minimum = courant->distance;
        noeud_id_t arg_minimum = courant->noeud;
        while(courant != liste->fin) {
            if(courant->distance < minimum) {
                minimum = courant->distance;
                arg_minimum = courant->noeud;
            }
            courant = courant->suivante;
        }
        if(courant->distance < minimum) {
                minimum = courant->distance;
                arg_minimum = courant->noeud;
        }
        return arg_minimum;
    }
    
}

void inserer_noeud_liste(liste_noeud_t* liste, noeud_id_t noeud, noeud_id_t precedent, float distance) {
    // Créer le nouveau dernier noeud
    cellule_t* nouvelleCellule = (cellule_t*)malloc(sizeof(cellule_t));
    nouvelleCellule->noeud = noeud;
    nouvelleCellule->precedent = precedent;
    nouvelleCellule->distance = distance;
    nouvelleCellule->suivante = NULL;

    if (liste->debut == NULL) {
        liste->debut = nouvelleCellule;
        liste->fin = nouvelleCellule;
        return;
    } else {
        liste->fin->suivante = nouvelleCellule;
        liste->fin = nouvelleCellule;
    }
    // Insérer le nouveau dernier noeud
    
}

void changer_noeud_liste(liste_noeud_t* liste, noeud_id_t noeud, noeud_id_t precedent, float distance) {
    cellule_t* courant = liste->debut;
    while(courant != liste->fin) {
        if(courant->noeud == noeud) {
            courant->precedent = precedent;
            courant->distance = distance;
            break;
        }
        courant = courant->suivante;
    }
    if(courant->noeud == noeud) {
            courant->precedent = precedent;
            courant->distance = distance;
    } else {
        inserer_noeud_liste(liste, noeud, precedent, distance);
    }
}

void supprimer_noeud_liste(liste_noeud_t* liste, noeud_id_t noeud) {
    cellule_t* courant = liste->debut;
    cellule_t* precedent = courant;
    bool estSupprime = false;
    if (!est_vide_liste(liste)) {
        if(liste->debut->noeud == noeud) {
            liste->debut = liste->debut->suivante;
            free(courant);
        } else {
            while(courant != liste->fin && !estSupprime) {
                if(courant->noeud == noeud) {
                    precedent->suivante = courant->suivante;
                    free(courant);
                    estSupprime = true;
                    courant = precedent->suivante;
                } else {
                    precedent = courant;
                    courant = courant->suivante;
                }
            }
            if(courant == liste->fin && courant->noeud == noeud) {
                precedent->suivante = NULL;
                liste->fin = precedent;
                free(courant);
            }
        }
    }
}



