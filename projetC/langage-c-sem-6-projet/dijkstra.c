#include "dijkstra.h"
#include <stdlib.h>

/**
 * construire_chemin_vers - Construit le chemin depuis le noeud de départ donné vers le
 * noeud donné. On passe un chemin en entrée-sortie de la fonction, qui est mis à jour
 * par celle-ci.
 *
 * Le noeud de départ est caractérisé par un prédécesseur qui vaut `NO_ID`.
 *
 * Ce sous-programme fonctionne récursivement :
 *  1. Si le noeud a pour précédent `NO_ID`, on a fini (c'est le noeud de départ, le chemin de
 *     départ à départ se compose du simple noeud départ)
 *  2. Sinon, on construit le chemin du départ au noeud précédent (appel récursif)
 *  3. Dans tous les cas, on ajoute le noeud au chemin, avec les caractéristiques associées dans visites
 *
 * @param chemin [in/out] chemin dans lequel enregistrer les étapes depuis le départ vers noeud
 * @param visites [in] liste des noeuds visités créée par l'algorithme de Dijkstra
 * @param noeud noeud vers lequel on veut construire le chemin depuis le départ
 */
void construire_chemin_vers(
    liste_noeud_t** chemin, 
    const liste_noeud_t* visites, 
    noeud_id_t noeud) {
    
    //C1
    if (precedent_noeud_liste(visites, noeud) == NO_ID) {
        inserer_noeud_liste(*chemin, noeud, NO_ID, 0.0);
    } else {
        //C1.2
        construire_chemin_vers(chemin, visites, precedent_noeud_liste(visites, noeud));
        inserer_noeud_liste(*chemin, noeud, precedent_noeud_liste(visites, noeud), distance_noeud_liste(visites, noeud));
    }
}


float dijkstra(
    const struct graphe_t* graphe, 
    noeud_id_t source, noeud_id_t destination, 
    liste_noeud_t** chemin) {
    
    //D
    liste_noeud_t* visites = creer_liste();
    liste_noeud_t* aVisiter = creer_liste();
    noeud_id_t noeud_courant = NO_ID;
        
        //D1
        inserer_noeud_liste(aVisiter, source, NO_ID, 0.0);
        
        //D2
        while (!est_vide_liste(aVisiter)) {
            //D2.1
            noeud_courant = min_noeud_liste(aVisiter);
            
            //D2.2
            inserer_noeud_liste(visites, noeud_courant, precedent_noeud_liste(aVisiter,noeud_courant), distance_noeud_liste(aVisiter,noeud_courant));

            //D2.3
            supprimer_noeud_liste(aVisiter,noeud_courant);

            //D2.4
            int nb_voisins = nombre_voisins(graphe, noeud_courant);
            noeud_id_t voisin[nb_voisins];
            noeuds_voisins(graphe, noeud_courant, voisin);
            float distance = distance_noeud_liste(visites,noeud_courant);
            
            for (int i = 0; i < nb_voisins; i++) {
                noeud_id_t voisin_courant = voisin[i];
                if (!contient_noeud_liste(visites, voisin_courant)) {
                    
                    //D2.4.1
                    float distance_voisin = noeud_distance(graphe, noeud_courant, voisin_courant);
                    float distance_voisin_courant = distance + distance_voisin;
                    float distance_aVisiter = distance_noeud_liste(aVisiter,voisin_courant);

                    //D2.4.3
                    if (distance_voisin_courant < distance_aVisiter) {
                        changer_noeud_liste(aVisiter, voisin_courant, noeud_courant, distance_voisin_courant);
                    }
            }
        }

    }

    //C
    if(chemin != NULL) {
        *chemin = creer_liste();
        construire_chemin_vers(chemin, visites, destination);
    }

    float distance = distance_noeud_liste(visites, destination);

    // Libération de la mémoire
    detruire_liste(&aVisiter);
    detruire_liste(&visites);
    aVisiter = NULL;
    visites = NULL;

    return distance;
}



