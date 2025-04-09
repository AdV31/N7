#define _GNU_SOURCE
#include "liste_noeud.h"
#include <stdlib.h>
#include <math.h>

struct cellule_t {
    noeud_id_t noeud, precedent;
    float distance;
    cellule_t* suivante;
};

typedef struct cellule_t cellule_t;

struct liste_noeud_t {
    cellule_t* debut;
    cellule_t* fin;
};

liste_noeud_t* creer_liste() {
    return NULL;
}

void detruire_liste(liste_noeud_t** liste_ptr) {
    free(*liste_ptr);
    *liste_ptr = NULL;
}

bool est_vide_liste(const liste_noeud_t* liste) {
    return liste == NULL;
}

bool contient_noeud_liste(const liste_noeud_t* liste, noeud_id_t noeud) {
    cellule_t* courant = liste->debut;
    while(courant != liste->fin) {
        if(courant->noeud == noeud) {
            return true;
        }
        courant = courant->suivante;
    }
    return false;
}

bool contient_arrete_liste(const liste_noeud_t* liste, noeud_id_t source, noeud_id_t destination) {
    cellule_t* courant = liste->debut;
    while(courant != liste->fin) {
        if(courant->noeud == source && courant->suivante->noeud == destination) {
            return true;
        }
        courant = courant->suivante;
    }
    return false;
}

float distance_noeud_liste(const liste_noeud_t* liste, noeud_id_t noeud) {
    cellule_t* courant = liste->debut;
    while(courant != liste->fin) {
        if(courant->noeud == noeud) {
            return courant->distance;
        }
        courant = courant->suivante;
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
    return NO_ID;
}

noeud_id_t min_noeud_liste(const liste_noeud_t* liste) {
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
    return arg_minimum;
}

void inserer_noeud_liste(liste_noeud_t* liste, noeud_id_t noeud, noeud_id_t precedent, float distance) {
    // Créer le nouveau dernier noeud
    cellule_t* nouvelleCellule = NULL;
    nouvelleCellule->noeud = noeud;
    nouvelleCellule->precedent = precedent;
    nouvelleCellule->distance = distance;
    nouvelleCellule->suivante = NULL;

    // Insérer le nouveau dernier noeud
    liste->fin->suivante = nouvelleCellule;
    liste->fin = nouvelleCellule;
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
}

void supprimer_noeud_liste(liste_noeud_t* liste, noeud_id_t noeud) {
    cellule_t* courant = liste->debut;
    cellule_t* precedent = courant;
    bool estSupprime = false;
    if(courant->noeud == noeud) {
        liste->debut = courant->suivante;
        free(courant);
    }
    while(courant != liste->fin) {
        if(courant->noeud == noeud) {
            precedent->suivante = courant->suivante;
            free(courant);
            estSupprime = true;
            break;
        }
        precedent = courant;
        courant = courant->suivante;
    }
    if(!estSupprime && courant == noeud) {
        precedent->suivante = courant->suivante;
        free(courant);
        liste->fin = precedent;
    }

}



