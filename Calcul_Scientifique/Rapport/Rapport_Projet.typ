#import "@preview/algo:0.3.4": algo, i, d, comment, code
#import"template_Rapport.typ":*

#show: project.with(
  title: "Rapport Bureau Etude --- Automatique",
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

#figure(
  algo(
  title: [                    // note that title and parameters
    #set text(size: 15pt)     // can be content
    #emph(smallcaps("Fib"))
  ],
  parameters: ([#math.italic("n")],),
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
  if $n < 0$:#i\
    return null#d\
  if $n = 0$ or $n = 1$:#i\
    return $n$#d\
  \
  let $x <- 0$\
  let $y <- 1$\
  for $i <- 2$ to $n-1$:#i #comment[so dynamic!]\
    let $z <- x+y$\
    $x <- y$\
    $y <- z$#d\
    \
  return $x+y$
],

  caption: [Premier schéma de modélisation du pendule inversé]
)
\

