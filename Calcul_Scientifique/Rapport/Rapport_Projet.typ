#import "@preview/algo:0.3.4": algo, i, d, comment, code
#import"template_Rapport.typ":*

#show: project.with(
  title: "Rapport Projet Calcul Scientifique",
  authors: (
    "VIGNAUX Adrien",
    "BLANCHARD Enzo",
  ),
  teachers: (
    "GUIVARCH Ronan",
    "ELOUARD Simon",
  ),
  year : "2024-2025",
  profondeur: 2,
)

= Introduction
\

Durant ce module de Calcul Scientifique, il nous a été demandé de réaliser un projet en binôme en utilisant Matlab. Ce dernier s’est déroulé sur deux séances : la première sur l’algorithme de la méthode de la puissance itérée avec différentes améliorations telles que l’approche en blocs et la déflation, puis la seconde sur une application de ces fonctions dans le cas de compression d’images.

= Première Partie : Power Method Algorithm and Deflation

== Introduction et limitations de la méthode de la puissance itérée
\

L’objectif de cette première partie est de tester différentes versions de la puissance itérée entre elles et avec la fonction “eig” de Matlab, afin de pouvoir implémenter la méthode la plus efficace lors de la seconde partie.\

D’abord, nous avons commencé par comparer le programme “power_v11.m” qui nous était fourni avec la fonction “eig” de Matlab : on remarque que cette dernière est bien plus performante que notre programme. Nous allons donc l’améliorer. \

Les coûts de calcul principaux sont les produits vectoriels : réduire leur usage nous permettrait de réduire notablement la durée d’exécution de notre programme. Nous remarquons dans notre programme que nous avons deux produits matriciels A.v qui peuvent être réarrangés de façon à n’en garder qu’un seul tout en ayant les mêmes résultats. En effet, la ligne y = A.v n’est plus utile puisque ce calcul est déjà enregistré lors de l’itération précédente (grâce à la ligne z = A.v), et pour la 1ère itération z est déjà initialisé. Ainsi, nous avons bel et bien des temps d’exécution jusqu’à plus de deux fois plus rapides qu’auparavant, c’est un bon départ. Voici la nouvelle version de ce programme : \

#figure(
  algo(
  title: [                    // note that title and parameters
    #set text(size: 15pt)     // can be content
    #emph(smallcaps("power_v12.m"))
  ],
  comment-prefix: [#sym.triangle.stroked.r ],
  comment-styles: (fill: rgb("#209178")),
  indent-size: 15pt,
  indent-guides: 1pt + gray,
  row-gutter: 5pt,
  column-gutter: 5pt,
  inset: 5pt,
  stroke: 2pt + black,
  fill: none,
)[
  Input: Matrix A ∈ $R^(n×n)$\
  Output: ($λ_1$, $v_1$) eigenpair associated to the largest (in module) eigenvalue.\
  v ∈ $R^n$ given\
  \
  $z = A * v$\
  $β = v^T * z$\
  repeat #i\
    $v = z/ norm(z)_2$\
    $z = A * v$\
    $β_"old" = β$\
    $β = v^T * z$\
  until $|β − β_"old"| / |β_"old"| < ε #d$\
  $λ_1 = β and v_1 = v$\
],

  caption: [Algorythme de la puissance itérée avec deflation]
)
\

Cependant, le principal défaut de cette méthode est sa vitesse de convergence car le nombre de flops de l’algorithme reste conséquent.\

Notre objectif est maintenant d’étendre cette méthode à des blocs de couples propres dits dominants.\

== Extension de la méthode de la puissance itérée à un espace propre dominant
\

Cette fois nous allons devoir implémenter cette nouvelle méthode dans un nouveau fichier “subspace_iter_v0.m”. La différence ici, c’est que notre algorithme va tendre vers une matrice V contenant les m différents vecteurs propres de A, en passant par une décomposition spectrale et une orthonormalisation de celle-ci.\

L’algorithme ressemble grandement au précédent, si ce n’est que les conditions d’arrêt diffèrent, et que l’on doit orthonormaliser. Voici le résultat :\

#figure(
  algo(
  title: [                    // note that title and parameters
    #set text(size: 15pt)     // can be content
    #emph(smallcaps("subspace_iter_v0.m"))
  ],
  comment-prefix: [#sym.triangle.stroked.r ],
  comment-styles: (fill: rgb("#209178")),
  indent-size: 15pt,
  indent-guides: 1pt + gray,
  row-gutter: 5pt,
  column-gutter: 5pt,
  inset: 5pt,
  stroke: 2pt + black,
  fill: none,
)[
  Input: Symmetric matrix A ∈ $R^(n×n)$, number of required eigenpairs m, tolerance ε and #emph[MaxtIter] (max nb of iterations)\
  Output:  $m$ dominant eigenvectors $V_"out"$ and the corresponding eigenvalues $Λ_"out"$.\
  \
  Generate a set of $m$ orthonormal vectors V ∈ $R^(n×m);$\
  \
  $k = 0$\
  repeat #i\
    $k = k + 1$\
    $Y = A * V$\
    $H = V T * A * V " " {"ou" H = V T * Y }$\
    $"Compute "$ #emph[acc] = $norm(A * V − V * H)/norm(A)$\
    $V <--$ orthonormalisation of the columns of $Y$#d\
  until $(k > $#emph[MaxtIter] or #emph[acc] $ ≤ ε)$\
  Compute the spectral decomposition $X * Λ_"out" * X^T = H$, where the eigenvalues of $H ("diag"(Λ_"out"))$ are arranged in descending order of magnitude.\
Compute the corresponding eigenspace $V_"out" = V * X$\
],

  caption: [Algorythme de la puissance itérée avec deflation et orthonormalisation]
)
\

Il est intéressant de noter que, bien que l’on cherche à ne pas faire la décomposition spectrale complète de A, nous effectuons ici celle de H. Pourtant, ce n’est pas un problème : puisque H contient toutes les informations qui nous intéressent à la fin de la boucle, nous n’avons pas besoin d’effectuer la décomposition spectrale de A à chaque itération, mais une seule fois en sortie de boucle .\

== Amélioration en utilisant la projection de Rayleigh-Ritz
\

À présent, nous allons employer la projection de Rayleigh-Ritz pour améliorer les performances de notre code actuel. Voici l’algorithme de cette projection :\

#figure(
  algo(
  title: [                    // note that title and parameters
    #set text(size: 15pt)     // can be content
    #emph(smallcaps("rayleigh_ritz.m"))
  ],
  comment-prefix: [#sym.triangle.stroked.r ],
  comment-styles: (fill: rgb("#209178")),
  indent-size: 15pt,
  indent-guides: 1pt + gray,
  row-gutter: 5pt,
  column-gutter: 5pt,
  inset: 5pt,
  stroke: 2pt + black,
  fill: none,
)[
  \
  $H = V'*(A*V)$\
  $["VH", "DH"] = "eig"(H)$\
  $["W", "indice"] = "sort(diag(DH), 'descend')"$\
],

  caption: [Algorythme de projection de Rayleigh-Ritz]
)
\

Notre programme va naturellement être modifié pour prendre en compte ce changement, notamment au niveau de la condition de sortie basée sur le pourcentage de la trace. Voici donc l’algorithme du fichier “subspace_iter_v1.m” :\

#figure(
  algo(
  title: [                    // note that title and parameters
    #set text(size: 15pt)     // can be content
    #emph(smallcaps("subspace_iter_v1.m"))
  ],
  comment-prefix: [#sym.triangle.stroked.r ],
  comment-styles: (fill: rgb("#209178")),
  indent-size: 15pt,
  indent-guides: 1pt + gray,
  row-gutter: 5pt,
  column-gutter: 5pt,
  inset: 5pt,
  stroke: 2pt + black,
  fill: none,
)[
  Input: Symmetric matrix A ∈ $R^(n×n)$, tolerance ε and #emph[MaxtIter] (max nb of iterations) and #emph[PercentT] race the target percentage of the trace of $A$\
  Output:  $n_"ev"$ dominant eigenvectors $V_"out"$ and the corresponding eigenvalues $Λ_"out"$.\
  \
  Generate an initial set of $m$ orthonormal vectors V ∈ $R^(n×m);$\
  \
  $k = 0$\
  #emph[PercentReached] $= 0$\
  repeat #i\
    $k = k + 1$\
    $Y = A * V$\
    $H = V T * A * V " " {"ou" H = V T * Y }$\
    $"Compute "$ #emph[acc] = $norm(A * V − V * H)/norm(A)$\
    $V <--$ orthonormalisation of the columns of $Y$\
    #emph[Rayleigh-Ritz projection] applied on matrix A and orthonormal vectors V\
    #emph[Convergence analysis step]: save eigenpairs that have converged and update #emph[PercentReached]#d\
  until (#emph[PercentReached] > #emph[PercentTrace] or $n_"ev" = m or k >$ #emph[MaxIter]) \
],

  caption: [Algorythme de la puissance itérée avec deflation et orthonormalisation]
)
\

Les différentes étapes de cet algorithme peuvent être identifiées comme telles :\

#figure(
  image("subspace_iter_v1.png", width: 65%),
  caption : [Algorithme subspace_iter_v1]
)
\

Bien que notre programme soit fonctionnel, il est encore possible de l’optimiser, et pour ce faire nous allons implémenter à la fois l’approche en blocs et la méthode de la déflation afin d’accélérer la convergence de notre algorithme.\

== Approche en blocs
\

Nous pouvons constater que l’orthonormalisation, coûteuse algorithmiquement parlant, est complètement effectuée à chaque itération. Pour ce faire, nous allons donc effectuer les p produits à chaque itération ; voici le résultat de cet algorithme :\

#figure(
  algo(
  title: [                    // note that title and parameters
    #set text(size: 15pt)     // can be content
    #emph(smallcaps("subspace_iter_v2.m"))
  ],
  comment-prefix: [#sym.triangle.stroked.r ],
  comment-styles: (fill: rgb("#209178")),
  indent-size: 15pt,
  indent-guides: 1pt + gray,
  row-gutter: 5pt,
  column-gutter: 5pt,
  inset: 5pt,
  stroke: 2pt + black,
  fill: none,
)[
  Input: Symmetric matrix A ∈ $R^(n×n)$, tolerance ε and #emph[MaxtIter] (max nb of iterations) and #emph[PercentT] race the target percentage of the trace of $A$\
  Output:  $n_"ev"$ dominant eigenvectors $V_"out"$ and the corresponding eigenvalues $Λ_"out"$.\
  \
  Generate an initial set of $m$ orthonormal vectors V ∈ $R^(n×m);$\
  \
  $k = 0$\
  #emph[PercentReached] $= 0$\
  repeat #i\
    $k = k + 1$\
    $Y = A^p * V$\
    $H = V T * A * V " " {"ou" H = V T * Y }$\
    $"Compute "$ #emph[acc] = $norm(A * V − V * H)/norm(A)$\
    $V <--$ orthonormalisation of the columns of $Y$\
    #emph[Rayleigh-Ritz projection] applied on matrix A and orthonormal vectors V\
    #emph[Convergence analysis step]: save eigenpairs that have converged and update #emph[PercentReached]#d\
  until (#emph[PercentReached] > #emph[PercentTrace] or $n_"ev" = m or k >$ #emph[MaxIter]) \
],

  caption: [Algorythme de la puissance itérée avec deflation et orthonormalisation par block]
)
\

Ainsi, le coût de $A^p$ étant de (p-1)$n^3$, et celui de $A^p*v$ de $p*n^3$, en calculant $A^p$ avant la boucle, nous réduisons les coûts de calcul.\

Lors de différents tests de la valeur p, nous pouvons constater quelque chose : plus la valeur est importante, moins le nombre d’itérations est important. Au-delà de p = 100, nous commençons à atteindre les limites de cette méthode, qui réduit considérablement le temps de calcul.\

== Méthode de la déflation
\

Finalement, l’ultime amélioration résulte dans le fait de limiter la projection de Rayleigh-Ritz aux colonnes non convergées de V au lieu de toute la matrice.\

D’abord, remarquons que dans les deux premières versions, les erreurs ont un rapport de $10^5$ entre elles : cela peut s’expliquer du fait que nous continuons à prendre en compte les paires ayant déjà convergées, ce qui les fait davantage converger et ainsi créent cet écart entre les vecteurs.\

Pour la version 3, puisque nous ne les prenons plus en compte, cela va alors uniformiser le rapport d’erreurs entre les vecteurs.\

Ainsi, voici le programme “subspace_iter_v3.m” :\

#figure(
  algo(
  title: [                    // note that title and parameters
    #set text(size: 15pt)     // can be content
    #emph(smallcaps("subspace_iter_v2.m"))
  ],
  comment-prefix: [#sym.triangle.stroked.r ],
  comment-styles: (fill: rgb("#209178")),
  indent-size: 15pt,
  indent-guides: 1pt + gray,
  row-gutter: 5pt,
  column-gutter: 5pt,
  inset: 5pt,
  stroke: 2pt + black,
  fill: none,
)[
  Input: Symmetric matrix A ∈ $R^(n×n)$, tolerance ε and #emph[MaxtIter] (max nb of iterations) and #emph[PercentT] race the target percentage of the trace of $A$\
  Output:  $n_"ev"$ dominant eigenvectors $V_"out"$ and the corresponding eigenvalues $Λ_"out"$.\
  \
  Generate an initial set of $m$ orthonormal vectors V ∈ $R^(n×m);$\
  \
  $k = 0$\
  #emph[PercentReached] $= 0$\
  repeat #i\
    $k = k + 1$\
    $Y = [V(:, 1:"nbc") "  " (A^p)*V(:, "nbc"+1:"end")]$\
    $H = V T * A * V " " {"ou" H = V T * Y }$\
    $"Compute "$ #emph[acc] = $norm(A * V − V * H)/norm(A)$\
    $V <--$ orthonormalisation of the columns of $Y$\
    #emph[Rayleigh-Ritz projection] applied on matrix A and orthonormal vectors V\
    #emph[Convergence analysis step]: save eigenpairs that have converged and update #emph[PercentReached]#d\
  until (#emph[PercentReached] > #emph[PercentTrace] $or n_"ev" = m or k >$ #emph[MaxIter]) \
],

  caption: [Algorythme de la puissance itérée avec deflation et orthonormalisation par block]
)
\

== Analyse et Comparaison
\

Voici les différentes distributions des valeurs propres en fonction de imat :\

#figure(
  image("Courbe_vpropre.png", width: 70%),
  caption : [Tableau de données TP02]
)
\

Voici le bilan des tests des différentes versions en fonction du type et de la taille de la matrice (temps et nombre d’itérations) ; Il faut bien penser que la qualité des couples et valeurs propres s’améliore nettement au fur et à mesure des versions (la v0 a un taux de qualité faible, la v1 a un bon taux , et la v2 et v3 ont un excellent taux) :\

#figure(
  image("tableau_v0_v1_v2_v3.png", width: 80%),
  caption : [Tableau de données TP02]
)
\

\

= Seconde Partie : Subspace Iteration Method
\
== Présentation des objectifs
\

Dans cette partie, nous allons à présent employer les méthodes vues précédemment pour de la compression d’image. Cela revient à employer deux théorèmes : la Décomposition en Valeur Singulière (appelée SVD), et l’approximation du meilleur plus-petit rang. Nous avons à notre disposition différentes images d’une page de BD sous différentes formes : portrait, paysage, deux portraits, en couleur. L’objectif va être d’utiliser nos fonctions précédentes pour vérifier leurs performances sur ce cas concret.\

== Implémentation de la reconstruction d’images en fonction des différents programmes
\

En premier temps, il est important de noter que :\

- $Σ_k$ est de taille $k*k$\
- $U_k$ est de taille $q*k$\
- $V_k$ est de taille $p*k$\

De plus, lorsque q < p, l’image passe en format paysage.
À présent, voici l’algorithme en question:\

[ALGO ReconstructionImage.m]\

== Résultats obtenus
\

#figure(
  image("tableau_v0_v1_v2_v3_eig_v12.png", width: 80%),
  caption : [Tableau de données TP02]
)
\

Les images en couleurs perdent de leurs couleurs, cependant elles se reconstruisent bien.\

= Conclusion
\

Finalement, ce projet nous a permis de développer une première méthode de calcul puis de l’optimiser jusqu’au maximum de nos compétences. De plus, nous avons pu les tester en situation réelle lors de compression d’images (sous différents formats).\

Malgré toutes nos tentatives, il nous a été impossible d’égaler eig : ce qui est normal, puisque cette dernière est optimisée jusqu’à une profondeur de code dont nous n’avions pas accès.