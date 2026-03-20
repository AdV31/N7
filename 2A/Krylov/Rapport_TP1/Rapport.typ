#import "@preview/algo:0.3.4": algo, i, d, comment, code
#import"template_Rapport.typ":*

#show: project.with(
  title: "Rapport de TP méthodes de Krylov",
  authors: (
    "VIGNAUX Adrien",
  ),
  teachers: (
    "Guivarch Ronan",
  ),
  year : "2025-2026",
  profondeur: 2,
)

= Introduction
\

Dans ce TP, nous allons résoudre le système linéaire $A*x = b$. Pour cela, nous allons implémenter et comparer deux méthodes vues en cours: GMRES et FOM. Nous allons également comparer les résultats avec ceux obtenus via le GMRES implémenté dans Matlab. De plus nous allons étudier l'impact de la tolérence sur la convergence de ces méthodes.

\

= Implémentation des méthodes
\

Pour implémenter les méthodes GMRES et FOM, nous allons suivre les algorithmes présentés en cours. Cependant nous allons les optimiser pour réduire le cout opérationnel. En effet plutôt que de boucler de manière statique sur toutes les composantes de la base de Krylov, nous allons utiliser une approche dynamique, en s'arrêtant dès que la norme du résidu est inférieure à la tolérance spécifiée. Cela nous permettra de réduire le nombre d'itérations nécessaires pour atteindre la convergence, tout en garantissant une précision suffisante.
\

De plus pour la résolution du système nous utiliserons l'opération "$\\$" de Matlab, qui est optimisée pour les systèmes linéaires et permet d'obtenir des résultats plus rapidement que les méthodes itératives classiques.
\

Finalement nous allons afficher les erreurs inverses normalisées pour les différentes méthodes, afin de comparer leur performance et leur précision.

\

De plus nous testerons ses méthodes sur trois matrices différentes, Mat1, Hydcar20, et PDE225_5e-1, afin d'évaluer leur performance dans différents contextes.

#pagebreak()

= Résultats et analyse
\

== Comparaison des performances des méthodes avec tolérance fixe
\

=== Résultats obtenus
\

Après avoir implémenté les méthodes GMRES et FOM, nous avons obtenu les résultats suivants pour la norme du résidu en fonction du nombre d'itérations:
\

#figure(
  image("capture d'écran/comparaison_mat1.png", width: 80%),
  caption : [Comparaison des méthodes sur la matrice Mat1 avec une tolérance de 1e-6],
)
\

#figure(
  image("capture d'écran/comparaison_pde.png", width: 80%),
  caption : [Comparaison des méthodes sur la matrice PDE225_5e-1 avec une tolérance de 1e-6],
)
\

#figure(
  image("capture d'écran/comparaison_hydcar.png", width: 80%),
  caption : [Comparaison des méthodes sur la matrice Hydcar20 avec une tolérance de 1e-6],
)
\

De plus, voici le nombre d'itérations nécessaires pour atteindre la convergence avec une tolérance de 1e-6:
\

#figure(
  image("capture d'écran/itération_mat1.png", width: 30%),
  caption : [Comparaison du nombre d'itérations nécessaires pour atteindre la convergence pour la matrice Mat1 avec une tolérance de 1e-6],
)
\

#figure(
  image("capture d'écran/itération_pde.png", width: 30%),
  caption : [Comparaison du nombre d'itérations nécessaires pour atteindre la convergence pour la matrice PDE225_5e-1 avec une tolérance de 1e-6],
)
\

#figure(
  image("capture d'écran/itération_hydcar.png", width: 30%),
  caption : [Comparaison du nombre d'itérations nécessaires pour atteindre la convergence pour la matrice Hydcar20 avec une tolérance de 1e-6],
)
\

=== Analyse des résultats
\

En analysant les résultats obtenus, nous pouvons observer que les méthodes GMRES et FOM ont des performances similaires en termes de convergence, avec une légère supériorité pour GMRES lorsque la norme de l'erreur inverse commence à décroitre. De plus lorsque la norme de l'erreur inverse stagne, FOM a tendence à être très instable, ce qui peut être dû à la nature de la matrice utilisée. En effet, pour la matrice PDE225_5e-1, FOM ne converge pas, tandis que GMRES parvient à atteindre la convergence sur la dernière itération uniquement.
\

De plus, nous pouvons observer que le GMRES que nous avons implémenté est identique à celui de Matlab, que cela soit en termes de convergence ou de nombre d'itérations nécessaires pour atteindre la convergence. Cela confirme que notre implémentation est correcte et optimisée.
\

Finalement, nous pouvons observer que le nombre d'itérations nécessaires pour atteindre la convergence varie en fonction de la matrice utilisée, avec une tendance générale à augmenter pour les matrices plus complexes. De plus, FOM et GMRES ont des performances similaires en termes de nombre d'itérations nécessaires pour atteindre la convergence.

== Comparaison de la convergence des méthodes avec différentes tolérances
\

=== Résultats obtenus
\

Après avoir testé différentes tolérances pour les méthodes GMRES et FOM, nous avons obtenu les résultats suivants pour la norme du résidu en fonction du nombre d'itérations avec une tolérance de 0,5:
\

#figure(
  image("capture d'écran/comparaison_mat1_0,5.png", width: 80%),
  caption : [Comparaison des méthodes sur la matrice Mat1 avec une tolérance de 0,5],
)
\

#figure(
  image("capture d'écran/comparaison_pde_0,5.png", width: 80%),
  caption : [Comparaison des méthodes sur la matrice PDE225_5e-1 avec une tolérance de 0,5],
)
\

#figure(
  image("capture d'écran/comparaison_hydcar_0,5.png", width: 80%),
  caption : [Comparaison des méthodes sur la matrice Hydcar20 avec une tolérance de 0,5],
)
\

De plus, voici le nombre d'itérations nécessaires pour atteindre la convergence avec une tolérance de 0,5:
\

#figure(
  image("capture d'écran/itération_mat1_0,5.png", width: 30%),
  caption : [Comparaison du nombre d'itérations nécessaires pour atteindre la convergence pour la matrice Mat1 avec une tolérance de 0,5],
)
\

#figure(
  image("capture d'écran/itération_pde_0,5.png", width: 30%),
  caption : [Comparaison du nombre d'itérations nécessaires pour atteindre la convergence pour la matrice PDE225_5e-1 avec une tolérance de 0,5],
)
\

#figure(
  image("capture d'écran/itération_hydcar_0,5.png", width: 30%),
  caption : [Comparaison du nombre d'itérations nécessaires pour atteindre la convergence pour la matrice Hydcar20 avec une tolérance de 0,5],
)
\

=== Analyse des résultats
\

En analysant les résultats obtenus, nous pouvons observer que la modification de la tolérance a un impact significatif sur la convergence des méthodes GMRES et FOM. En effet, avec une tolérance plus élevée de 0,5, les méthodes convergent beaucoup plus rapidement, avec un nombre d'itérations nécessaire pour atteindre la convergence considérablement réduit. Cependant, cela entraine également que la norme de l'erreur inverse stagne à des valeurs très élevées, ce qui peut être problématique pour certaines applications nécessitant une précision élevée. Cela s'explique par le fait qu'une tolérance élevée nous fait sortir de la boucle while plus tôt, ce qui conduit à une solution moins précise, mais obtenue plus rapidement.
\

De plus nous pouvons observer que FOM fait beaucoup plus d'itération que GMRES pour atteindre la convergence. Cela est dû au fait que GMRES décroit plus rapidement que FOM, ce qui lui permet d'atteindre la tolérance plus rapidement. De plus, FOM a tendance à être plus instable que GMRES, ce qui peut expliquer pourquoi il fait plus d'itérations pour atteindre la convergence.
\

= Conclusion
\

En conclusion, ce TP nous a permis d'implémenter et de comparer les méthodes GMRES et FOM pour la résolution de systèmes linéaires. Nous avons observé que les deux méthodes ont des performances similaires en termes de convergence, avec une légère supériorité pour GMRES lorsque la norme de l'erreur inverse commence à décroitre. De plus, nous avons constaté que le nombre d'itérations nécessaires pour atteindre la convergence varie en fonction de la matrice utilisée, avec une tendance générale à augmenter pour les matrices plus complexes. Enfin, nous avons vu que la modification de la tolérance a un impact significatif sur la convergence des méthodes, avec une tolérance plus élevée conduisant à une convergence plus rapide mais à une solution moins précise.