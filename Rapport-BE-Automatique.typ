#import"template_2A.typ":*

#show: project.with(
  title: "Rapport Bureau Etude --- Automatique",
  authors: (
    "VIGNAUX Adrien",
    "BLANCHARD Enzo",
  ),
  teachers: (
    "COTS Olivier",
    "BEUZEVILLE Theo",
  ),
  year : "2024-2025",
  profondeur: 2,
)

= Introduction

== Contexe
\

Lors des Travaux Pratiques effectués en Automatique, nous nous sommes concentrés sur la simulation et la mise en application d’un système contrôlé, plus particulièrement un pendule inversé.\
Ce dernier peut se représenter de la manière suivante :

$ (S):vec(circle(x_1(t)) = x_2(t), circle(x_2(t)) = frac(g,l)sin(x_1(t))-frac(cos(x_1(t))u(t),l), x_1(0) = x_(0,1)= alpha_0, x_2(0) = x_(0,2)= alpha_0, delim: "{") $

== Objectif
\

L’objectif final de ces séances est de pouvoir contrôler un robot Lego (mentionné plus tard) à l’aide de ce système, afin qu’il soit dans un état d’équilibre : il doit tenir debout.

#align(center)[
  #image("Image1.png", width: 24%)

 Robot Lego
]

= Simulation d’un pendule inversé contrôlé (TP02)

== Situation
\

En utilisant Simulink (un outil inclus dans le logiciel Matlab), nous allons modéliser le système du pendule inversé.

#pagebreak()

== Contrôle par retour d'état
\

Pour réaliser ce système, nous devons écrire un retour d’état de la forme :\
#align($u(t) = "ue" + K*(x-"xe")$, center)

A l’aide des conditions énoncés au début, voici ce qu’il en résulte sur Simulink :
#figure(
  image("Schema simulink Tp02 1.2.jpg"),
  caption: [Premier schema de modelisation du pendule inversé]
)
\

Nous allons tester différentes situations à l’aide de ce tableau de données :

#align(center)[
  #image("Tableau donnee Tp02 1.2.jpg", width: 60%)

 Tableau de données TP02
]
\

Il faut noter que la courbe bleue représente la position de notre système (qui doit tendre vers 0 pour se stabiliser), tandis que la courbe jaune représente la tension nécessaire au contrôle du système afin de le stabiliser.

#figure(
  image("Courbe1.png", width: 60%),
  caption: [Cas 1.1 : Sortie de l'oscilloscope Etats]
)

#figure(
  image("Courbe2c.png", width: 60%),
  caption: [Cas 1.1 : Sortie de l'oscilloscope Contrôle]
)

#pagebreak()

= Simulation du comportement d’un robot Lego (TP03)

== Situation
\

A présent, nous allons modéliser et simuler le robot Lego pendule inversé puis constater les résultats obtenus. Nous débuterons par un modèle Simulink continu qui est le suivant :
\

== Contrôle par retour d'état
\

Suite à cette implantation, nous avons effectué différents tests avec les données suivantes :

#align(center)[
  #image("Tableau donnee Tp03.jpg", width: 60%)

 Tableau de données TP03
]
\


Tout comme au début du TP02, au départ, seul le point initial est modifié afin de constater les différents comportements du robot qui peuvent survenir.

Retrouvons dès à présent les différents résultats :

#figure(
  image("Courbe1.1eTp03.png", width: 60%),
  caption: [Cas 1.1 : Sortie de l'oscilloscope Etats]
)
\

#figure(
  image("Courbe1.2cTp03.png", width: 60%),
  caption: [Cas 1.1 : Sortie de l'oscilloscope Contrôle]
)
\

Étant donné que nous sommes initialement à un point d’équilibre, il faut en effet que le système ne réagisse pas.


#figure(
  image("Courbe1.2eTp03.png", width: 60%),
  caption: [Cas 1.2 : Sortie de l'oscilloscope Etats]
)
\

#figure(
  image("Courbe1.1cTp03.png", width: 60%),
  caption: [Cas 1.2 : Sortie de l'oscilloscope Contrôle]
)


Courbe bleue : angle d’inclinaison du robot\
Courbe orange : vitesse moyenne des roues du robot\
Courbe jaune : angle moyen des roues du robot\
Courbe verte : vitesse de changement d’angle du robot.\

On constate d’abord une forte augmentation des vitesses (des roues et de changement d’angle) au début de la simulation : le système effectue une régulation importante afin de stabiliser le robot. Par la suite, lorsque l’angle du robot passe d’un côté à l’autre de la valeur nulle, les vitesses tentent de réguler, de moins en moins fort, en sens inverse. Finalement, c’est au bout de deux secondes que le système atteint l’équilibre, puisque toutes les courbes convergent vers 0.
\
  
\
 
\

#figure(
  image("Courbe1.3eTp03.png", width: 60%),
  caption: [Cas 1.3 : Sortie de l'oscilloscope Etats]
)
\

#figure(
  image("Courbe1.3cTp03.png", width: 60%),
  caption: [Cas 1.3 : Sortie de l'oscilloscope Contrôle]
)
\

Le comportement est similaire au cas 1.2, cependant le système met un petit peu plus de temps à converger vers 0, donc à se stabiliser : l’équilibre est atteint comme souhaité pour plusieurs départs différents.


== Implémentation des capteurs
\

Nous ajoutons à présent un modèle de capteurs, qui simulent les informations que l’on récupérerait en réalité, à savoir la vitesse moyenne des roues du robot (Ѱ’), ainsi que l’angle (Θ).
Puisqu’il nous manque deux informations pour compléter le retour d’état, nous allons les retrouver à l’aide d’un intégrateur et d’un dérivateur, ces derniers étant implémentés dans un bloc “Prédicteur”.

#figure(
  image("Courbe1.1eTp03.png", width: 59%),
  caption: [Cas 1.1 : Sortie de l'oscilloscope Etats]
)
\

#figure(
  image("Courbe1.2cTp03.png", width: 59%),
  caption: [Cas 1.1 : Sortie de l'oscilloscope Contrôle]
)
\

Similaire au cas 1.1 de la partie précédente, un état initial à l’équilibre amène naturellement à une non-réaction de la part du système.

#figure(
  image("Courbe1.2ex2eTp03.png", width: 60%),
  caption: [Cas 1.2 : Sortie de l'oscilloscope Etats]
)
\

#figure(
  image("Courbe1.2ex2cTp03.png", width: 60%),
  caption: [Cas 1.2 : Sortie de l'oscilloscope Contrôle]
)
\

Nous avons deux changements notables à la différence de précédemment :
La courbe jaune, soit l’angle d’inclinaison du robot, ne converge plus vers 0 mais vers une autre valeur quelconque : nous pouvons en déduire que le robot s’est stabilisé après avoir quelque peu bougé de sa position initiale ;
Le système est plus lent à se stabiliser : on se rapproche bien d’une situation réelle grâce aux capteurs modélisés.

#figure(
  image("Courbe1.3ex2eTp03.png", width: 60%),
  caption: [Cas 1.3 : Sortie de l'oscilloscope Etats]
)
\

#figure(
  image("Courbe1.3ex2cTp03.png", width: 60%),
  caption: [Cas 1.3 : Sortie de l'oscilloscope Contrôle]
)
\

On a le même attendu qu’entre les figures X et X de l’étape précédente.

== Passage en mode discret
\

En réalité, l’implantation du modèle réalisé dans le robot se fera en modèle discret. Nous avons donc la nécessité de simuler cet état, en modifiant le capteur et le prédicteur pour satisfaire l’exigence souhaitée :

Suite à cela, nous obtenons les résultats suivant :

#figure(
  image("Courbe1.1eTp03.png", width: 59%),
  caption: [Cas 1.1 : Sortie de l'oscilloscope Etats]
)
\

#figure(
  image("Courbe1.2cTp03.png", width: 59%),
  caption: [Cas 1.1 : Sortie de l'oscilloscope Contrôle]
)
\

L’état initial nul est et doit toujours être le même : c’est bien le cas une nouvelle fois.

#figure(
  image("Courbe1.2ex3eTp03.png", width: 60%),
  caption: [Cas 1.2 : Sortie de l'oscilloscope Etats]
)
\

#figure(
  image("Courbe1.2ex3cTp03.png", width: 60%),
  caption: [Cas 1.2 : Sortie de l'oscilloscope Contrôle]
)
\

On constate une déformation des courbes : elles sont à présent en escalier. Nous sommes bien sur une discrétisation de ces dernières comme désiré. Assurément, le système réagit tout aussi bien qu’avant.

#figure(
  image("Courbe1.3ex3eTp03.png", width: 60%),
  caption: [Cas 1.3 : Sortie de l'oscilloscope Etats]
)
\

#figure(
  image("Courbe1.3ex3cTp03.png", width: 60%),
  caption: [Cas 1.3 : Sortie de l'oscilloscope Contrôle]
)
\

Nous obtenons un résultat tout aussi convaincant, avec comme toujours les amplitudes des paramètres d’état qui sont diminuées par deux par rapport au cas 1.2.

= Mise en pratique : Robot LegoNXT (TP04)
\

Après avoir validé le modèle du pendule inversé, et avoir simulé de multiples situations, nous sommes finalement rendu à l’implantation de ce modèle dans le robot LegoNXT :

Après nous avoir fourni un ensemble de fichiers écrits en langage C, nous avons exclusivement à remplir la partie de la modélisation du système, puis de transmettre ce fichier au robot afin qu’il exécute notre programme.\

Nous avons pu observer le bon équilibre du robot au bout de quelques secondes, et les perturbations (pousser le robot par exemple) ne le font pas sortir de son état d’équilibre, dans la mesure du raisonnable évidemment.

= Conclusion
\

C’est à l’aide de ce dernier TP que nous avons pu pleinement valider notre modèle du pendule inversé, puisque le robot se comportait comme attendu lors de nos simulations.

De plus, cette réactivité en temps réel à cause d’une quelconque perturbation montre la bonne prédiction des informations manquantes suite au passage par capteurs : le robot cherche continuellement à se retrouver en état d’équilibre.

Ainsi, nous pouvons en conclure que le modèle du pendule inversé permet de stabiliser un système à roues tel que le robot LegoNXT.