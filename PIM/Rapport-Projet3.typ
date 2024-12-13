#import"template_Rapport.typ":*

#show: project.with(
  title: "Rapport Projet 3 --- PIM",
  authors: (
    "VIGNAUX Adrien",
    "BLANCHARD Enzo",
  ),
  teachers: (
    "HAMROUNI Zouheir",
  ),
  year : "2024-2025",
  profondeur: 3,
)

= Introduction
\

Lors de ce module de Programmation Impérative, nous avons déjà pu réaliser deux mini-projets individuels : le premier étant sur la création du jeu des 13 allumettes, le second étant sur l’application des modules et de la généricité en lien avec des LCA (Listes Chaînées Associatives).

== Objectifs
\

Pour ce troisième et ultime projet du module, nous sommes en binôme, et il nous est demandé d’écrire deux programmes :\

- Le premier doit compresser des fichiers textes en utilisant le codage de Huffman ;

- Le second doit permettre de les décompresser.
\

Ce rapport débutera sur une présentation large du problème pour se poursuivre par nos démarches de résolution. Nous présenterons ensuite nos différents choix ainsi que les principaux rendus de ce projet (modules par exemple). Puis, nous expliquerons notre gestion du travail en équipe, avec les diverses difficultés rencontrées et ce qui pourrait être amélioré à l’avenir. Nous clôturerons ce rapport par un bilan technique, puis personnel.

== Description du problème
\

Le codage de Huffman permet de compresser, sans perte, des données telles que des textes, des images ou encore du son. Nous sommes ici intéressés par la compression de texte.

Ce principe revient à compter le nombre d'occurrences de chaque caractère présent dans un texte, puis de leur inscrire une série de bits dont la taille dépendra de la fréquence d’apparition du caractère dans le texte. Ainsi, un caractère “commun” sera codé sur peu de bits, tandis qu’un caractère “peu commun” sera codé sur davantage de bits.

Assurément, nous devrons permettre la compression ainsi que la décompression du texte, sinon il nous serait impossible de récupérer et utiliser son contenu initial, avant sa compression.

\


Pour cette première version du rapport, nous resterons exclusivement sur la partie de compression de texte, le reste sera abordé ultérieurement.

= Contenu du projet
== Structure générale du projet
\

Notre projet se regroupe en plusieurs fichiers qui seront explicités au fur et à mesure de ce rapport. Voici la liste :
- Les fichiers arbre.adb et arbre.ads : module “Arbre” permettant de manipuler l’Arbre de Huffman ;
- Les fichiers table.adb et table.ads : module “Table” permettant de manipuler diverses tableaux spécifiques tel que la Table de Fréquence et la Table de Huffman ;
- Le fichier compresser.adb : premier fichier principal réalisant la compression d’un texte à partir du principe de codage de Huffman ;
- Le fichier decompresser.adb : second fichier principal réalisant la décompression de notre texte préalablement compressé ;
- Le fichier test_compresser.adb : fichier de réalisation de tests assurant le bon fonctionnement de compression du texte ;
- Le fichier test_decompresser.adb : fichier de réalisation de tests assurant le bon fonctionnement de décompression du texte.

== Choix effectués


== Architecture de l'application mobile

== Principaux algorithmes

== Démarches de test

= Gestion du travail

== Organisation de l'équipe
\

La répartition des tâches lors de la réalisation de ce projet s’est effectué comme telle :

== Difficultés rencontrées
Durant la réalisation de ce projet, nous avons pu rencontrer certaines difficultés qui valent la peine d’être explicitées.\

Premièrement, nous avons eu du mal à comprendre le fonctionnement de l’arbre de Huffman, ou plutôt comment elle s’implémente d’un point de vue algorithmique. Cela nous a demandé un peu plus de temps que prévu lors des prémices du projet, afin de partir sur de bonnes bases.\

De plus, nous avions toujours en tête d’optimiser le programme dès que possible, cependant pour un projet qui commence à avoir une plus grande ampleur il est essentiel de débuter sur une base fonctionnelle (même si non optimisée), puis par la suite de l’améliorer du mieux que possible. Ainsi, nous partions souvent dans des idées bien trop complexes, qui n’aboutissaient pas forcément.\

Enfin, il nous a été primordial de bien gérer notre temps, afin de pouvoir avancer efficacement dans la complétion du projet et de rendre notre travail dans les temps lorsque c’était demandé. C’était une difficulté continue qui ne devait être négligée à aucun moment, sous peine de retour de bâton imprévu.\

= Conclusion

== Bilan technique

== Bilan personnel et collectif

=== De Adrien VIGNAUX
\


=== De Enzo BLANCHARD
\

Finalement, ce projet était notre première approche du monde de l’ingénierie : entre la gestion d’équipe et du travail, les deadlines à respecter ou encore le processus de création, d’innovation pour un rendu encore et toujours plus performant, efficace, ce projet était assez complet et nous a permis de pleinement manipuler tous les aspects de la programmation impérative.