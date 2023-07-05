/*
 * Created in 2023 by Gaëtan Serré
 */


// Utils functions
#let range(arr: ()) = {
  let ret = ()
  let arr_copy = ()
  for i in arr {
    arr_copy += (i,)
    ret += (arr_copy.len() - 1,)
  }
  ret
}

#let TODO(it) = {
  text(fill: red, weight: "extrabold", [TODO #it])
}

/***********************************MATHS ENVIRONMENT*********************************************/
/*************************************************************************************************/

#let heading_count = counter(heading)

#let math_block(supplement, name, it, lb, stroke_color, eq_numbering) = {
  let counter = counter(supplement)
  counter.step()
  let body = {
    set math.equation(numbering: eq_numbering)
    if name == none {
        [*#supplement #counter.display().* ] + it
    } else {
      [*#supplement #counter.display() * (#emph(name)). ] + it
    }
  }
  let fig = figure(
    rect(
      width:100%,
      stroke: ("left": 1pt+stroke_color, "rest": none),
      fill: rgb("#eeeeee"),
      inset: (bottom: 10pt, rest: 5pt),
      align(left, body)
    ),
    caption: none,
    kind: supplement,
    supplement: supplement,
  )
  if lb != none [
    #fig
    #label(lb)
  ] else [
    #fig
  ]
}

// Math blocks

#let lemma(name, it, label: none, eq_numbering: none) = math_block("Lemma", name, it, label, rgb("#B287A3"), eq_numbering)

#let proposition(name, it, label: none, eq_numbering: none) = math_block("Proposition", name, it, label, rgb("#750D37"), eq_numbering)

#let theorem(name, it, label: none, eq_numbering: none) = math_block("Theorem", name, it, label, rgb("#210124"), eq_numbering)

#let corollary(name, it, label: none, eq_numbering: none) = math_block("Corollary", name, it, label, rgb("#F9F5E3"), eq_numbering)

#let definition(name, it, label: none, eq_numbering: none) = math_block("Definition", name, it, label, rgb("#BFB1C1"), eq_numbering)

#let remark(name, it, label: none, eq_numbering: none) = math_block("Remark", name, it, label, rgb("#8380B6"), eq_numbering)

#let example(it, label: none, eq_numbering: none) = math_block("Example", none, it, label, rgb("#9BC4CB"), eq_numbering)

#let proof(it) = {
  set align(center)
  block(
    width: 90%,
    align(left, [_Proof._ $space$] + it + align(right, text()[$qed$]))
  )
}


/*********************************ALGORITHM ENVIRONMENT*******************************************/
/*************************************************************************************************/

#let code_block(
  identifier: none,
  content: [],
  has_stroke: true,
  inset: 1em
) = {
  identifier
  block(width: auto, above: 0.5em, below:0.5em, {
    let stroke = ("left": 1pt, "rest": none)
    if not has_stroke {
      stroke = none
    }
    rect(
      stroke: stroke,
      outset: -0.1em,
      inset: inset,
      )[#content]
  })
}

#let for_loop(
  variable: "i",
  iterator: "x",
  content: [],
) = {
  code_block(identifier: [*for* #variable *in* #iterator *do*], content: content)
  [*end for*]
}

#let while_loop(
  condition: "x",
  content: [],
) = {
  code_block(identifier: [*while* #condition *do*], content: content)
  [*end while*]
}

#let if_block(
  condition: "x",
  content: [],
  else_content: none,
) = {
  code_block(identifier: [*if* #condition *then*], content: content)
  if else_content != none {
    code_block(identifier: [*else*], content: else_content)
  }
  [*end if*]
}

#let comment(
  content
) = {
  [#box(width: 1fr, repeat(" ")) #text(fill: rgb("#6c6c6c"), style: "italic", content)]
}

#let keyword(
  keyword,
  fill: black,
  weight: "regular",
  style: none
  ) = {
    if style == none {
      text(fill: fill, weight: weight, keyword)
    } else {
      style(keyword)
    }
}

#let Return = keyword([return], weight: "bold")
#let Break  = keyword([break], weight: "bold")
#let Continue = keyword([continue], weight: "bold")

#let algorithm(
  name: none,
  input: none,
  output: none,
  content: []
) = {
  align(center, 
    block(width: auto, {
      align(left, {
        counter("algorithm").step()
        //show line: set block(above: 0.4em, below: 0.4em)
        set par(first-line-indent: 0em)
        box(width: 1fr, line(length: 100%, stroke: {1.5pt + black})) +  [ \ ]
        [*Algorithm #counter("algorithm").display():* #name \ ]
        box(width: 1fr, line(length: 100%, stroke: {1pt + black})) + [ \ ]
        if input != none {
          [*Input:*]
          align(center, block(width: 95%, above: 0.5em, below: 0.5em, align(left, input)))
        }
        if output != none {
          [*Output:*]
          align(center, block(width: 95%, above: 0.5em, below: 0.5em, align(left, output)))
        }

        if output != none or input != none {
          box(width: 1fr, line(length: 100%, stroke: {1pt + black})) +  [ \ ]
        }
        
        [#content \ ]
        box(width: 1fr, line(length: 100%, stroke: {1pt + black}))
      })
    })
  )
}

#let config(
  title: none,
  subtitle: none,
  header: none,
  authors: none,
  abstract: none,
  keywords: (),
  logo:none,
  doc,
) = {

  // Odd-switching header function
  let header_loc = none
  if header != none {
    header_loc = locate(loc => {
      let page_nb = counter(page).at(loc).at(0)
      if page_nb == 1 {
        none
      } else if calc.rem(page_nb, 2) == 1 {
        align(right, header)
      } else {
        if authors == none {
          align(left, "Gaëtan Serré")
        } else if authors.len() > 1 {
          align(left, authors.at(0).name  + " et al.")
        } else {
          align(left, authors.at(0).name)
        }
      }
    })
  }

  // Set rules
  set page(
    paper: "a4",
    header: header_loc,
    numbering: "1",
    background: locate(loc => {
      let page_nb = counter(page).at(loc).at(0)
      if page_nb == 1 and logo != none {
        logo
      } else {
        none
      }
    })
  )

  set par(
    justify: true,
    first-line-indent: 1em
  )

  set text(font: "CMU Serif")

  set heading(numbering: (..nums) => {
      nums.pos().map(str).join(".")
  })

  set math.equation(numbering: "(1)")

  set cite(style: "chicago-author-date")

  set terms(indent: 1em)
  set enum(indent: 1em)

  // Reference style
  set ref(supplement: it => {
    let fig = it.func()
    if fig == math.equation {
      text(fill: black, "Eq.")
    }
    
    else if fig == figure {
      text(fill: black, it.supplement)
    }
  })

  set outline(indent: true, fill: repeat([.$space$]))

  // Show rules

  show ref: set text(fill: rgb("#ff0000"))
  show link: set text(fill: rgb("#7209b7"))
  show cite: set text(fill: rgb("#4361ee"))

  // Algorithm figure
  show figure: fig => {
    if fig.kind == "algorithm" {
      fig.body
    } else {
      fig
    }
  }

  // Title & subtitle
  align(center, {
    text(16pt)[#title]
    if subtitle != none {
      text(14pt)[ \ #emph(subtitle)]
     }
  })

  // Authors
  if authors == none {
      align(center, text(14pt)[
        Gaëtan Serré \
        ENS Paris-Saclay - Centre Borelli \
        #text(font: "CMU Typewriter Text")[
          #link("mailto:gaetan.serre@ens-paris-saclay.fr")
        ]
      ])
  } else {
    for author in authors {
      align(center, text(14pt)[
        #author.name \
        #author.affiliation \
        #text(font: "CMU Typewriter Text")[
          #link("mailto:" + author.email)
        ]
      ])
    }
  }

  // Abstract
  let width_box_abstract = 80%

  if abstract != none {
    align(center, text()[*Abstract*])
    align(center, 
      box(width:width_box_abstract, 
        align(left, text(size: 10pt)[
          #abstract
        ])
      )
    )
  }
  
  // Keywords
  align(center, box(width:width_box_abstract,
    align(left, {
      set text(size: 10pt)
      if keywords.len() > 0 {
        [*Keywords: *]
        let last_keyword = keywords.pop()
        for keyword in keywords {
          [#keyword] + [; ]
        }
        [#last_keyword.]
      }
    })
  ))

  doc
}
