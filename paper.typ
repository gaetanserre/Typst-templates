
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

/***********************************MATHS ENVIRONMENT*********************************************/
/*************************************************************************************************/

#let heading_count = counter(heading)
#let math_block(supplement, counter, name, it) = {
  counter.step()
  let body = {
    if name == "" {
        [*#supplement #counter.display().* ] + it
    } else {
      [*#supplement #counter.display() * (#emph(name)). ] + it
    }
  }
  set align(center)
  block(
      width:92%,
      align(left, body)
    )
}

// Counters

#let th_count = counter("theorem")
#let theorem(name, it) = math_block("Theorem", th_count, name, it)

#let def_count = counter("definition")
#let definition(name, it) = math_block("Definition", def_count, name, it)

#let lemma_count = counter("lemma")
#let lemma(name, it) = math_block("Lemma", lemma_count, name, it)

#let prop_count = counter("proposition")
#let proposition(name, it) = math_block("Proposition", prop_count, name, it)

#let proof(it) = {
  set align(center)
  block(
    width: 90%,
    align(left, [_Proof._ $space$] + it + align(right, text()[$qed$]))
  )
  
}


/*********************************ALGORITHM ENVIRONMENT*******************************************/
/*************************************************************************************************/

#let algorithm(
  name: none,
  content: []
) = {
  align(center, 
    block(width: auto, {
      align(left, {
        counter("algorithm").step()
        //show line: set block(above: 0.4em, below: 0.4em)
        set par(first-line-indent: 0em)
        box(width: 1fr, line(length: 100%, stroke: {1.5pt + black}))
        [ \ *Algorithm #counter("algorithm").display():* #name \ ]
        box(width: 1fr, line(length: 100%, stroke: {1pt + black}))
        [\ #content \ ]
        box(width: 1fr, line(length: 100%, stroke: {1pt + black}))
      })
    })
  )
}

#let code_block(
  identifier: none,
  content: [],
  color: red
) = {
  identifier
  block(width: auto, above: 0.5em, below:0.5em, {
    rect(
      stroke:("left": 1pt, "rest": none),
      outset: -0.1em,
      inset: 1em,
      //fill: color
      )[#content]
  })
}

#let for_loop(
  variable: "i",
  iterator: "x",
  content: [],
  color: red
) = {
  code_block(identifier: [*for* #variable *in* #iterator *do*], content: content, color: color)
  [*end for*]
}

#let while_loop(
  condition: "x",
  content: [],
  color: red
) = {
  code_block(identifier: [*while* #condition *do*], content: content, color: color)
  [*end while*]
}

#let if_block(
  condition: "x",
  content: [],
  else_content: none,
  color: red
) = {
  code_block(identifier: [*if* #condition *then*], content: content, color: color)
  if else_content != none {
    code_block(identifier: [*else*], content: else_content, color: color)
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


#let config(
  title: none,
  subtitle: none,
  header: none,
  authors: none,
  abstract: none,
  keywords: (),
  logo: "figures/cb_logo.png",
  doc,
) = {

  // Odd-switching header function
  let header_loc = none
  if header != none {
    header_loc = locate(loc => {
      let page_nb = counter(page).at(loc).at(0)
      if page_nb == 1 {
        none
      } else if calc.mod(page_nb, 2) == 1 {
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

  set page(
    paper: "a4",
    header: header_loc,
    numbering: "1",
    background: locate(loc => {
      let page_nb = counter(page).at(loc).at(0)
      if page_nb == 1 and logo != none {
        align(right+top, image(logo, width: 10%))
      } else {
        none
      }
    })
  )

  set par(
    justify: true,
  )

  show ref: set text(fill: rgb("#ff0000"))
  show link: set text(fill: rgb("#7209b7"))
  show cite: set text(fill: rgb("#4361ee"))

  set text(font: "CMU Serif")

  set heading(numbering: "1.")

  set cite(style: "chicago-author-date")

  set math.equation(numbering: "(1)")

  set list(indent: 1em)
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

  // Algorithm figure
  show figure: fig => {
    if fig.kind == "algorithm" {
      algorithm(
        name: fig.caption,
        content: fig.body
      )
    } else {
      fig
    }
  }

  // Indentation
  set par(
    first-line-indent: 1em
  )

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
