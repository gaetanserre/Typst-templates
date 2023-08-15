/*
 * Created in 2023 by Gaëtan Serré
 */


// Utils functions

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
  set math.equation(numbering: none)
  block(
    width: 90%,
    align(left, [_Proof._ $space$] + it + align(right, text()[$qed$]))
  )
}


/*********************************ALGORITHM ENVIRONMENT*******************************************/
/*************************************************************************************************/

#let code_block(
  identifier: none,
  comment: none,
  content: [],
  has_stroke: true,
  inset: 1em
) = {
  if comment == none {
    identifier
  } else {
    [#identifier #box(width: 1fr, repeat(" ")) #text(fill: rgb("#6c6c6c"), style: "italic", comment)]
  }
  block(width: auto, above: 0.5em, below:0.5em, {
    let stroke = ("left": 1pt, "rest": none)
    if not has_stroke {
      stroke = none
    }
    rect(
      stroke: stroke,
      outset: -0.1em,
      inset: (right: 0em, rest: inset),
      )[#content]
  })
}

#let for_loop(
  variable: "i",
  iterator: "x",
  comment: none,
  content: [],
) = {
  code_block(identifier: [*for* #variable *in* #iterator *do*], comment: comment, content: content)
  [*end for*]
}

#let while_loop(
  condition: "x",
  comment: none,
  content: [],
) = {
    code_block(identifier: [*while* #condition *do*], comment: comment, content: content)
  [*end while*]
}

#let if_block(
  condition: "x",
  comment: none,
  content: [],
  else_comment: none,
  else_content: none,
) = {
  code_block(identifier: [*if* #condition *then*], comment: comment, content: content)
  if else_content != none {
    code_block(identifier: [*else*], comment: else_comment, content: else_content)
  }
  [*end if*]
}

#let comment(content) = {
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
        [*Algorithm #counter("algorithm").display():* #smallcaps(name) \ ]
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

/*********************************LANGUAGE ENVIRONMENT*******************************************/
/*************************************************************************************************/

/***LEAN***/
#let lean_font(cont) = text(font: "Menlo", size: 9pt, cont)

#let lean_block(cont) = {
  set par(first-line-indent: 0em)
  show par: set block(spacing: 0em)
  set text(font: "Menlo", size: 9pt)
  let reg_comment = regex(`(\s*\/-(.|\n)*-\/)|(\s*--.*)`.text)
  let comment_matches = cont.matches(reg_comment)
  let cont_without_comments = cont.split(reg_comment)

  let print_comment(comment) = {
    set par(first-line-indent: 0em)
    show regex("[^\*]\*[^\*]+\*"): set text(style: "italic", fill: rgb("000000"))
    show regex("\*\*[^\*]+\*\*"): set text(weight: "bold", fill: rgb("000000"))
    text(fill: rgb("#6a737d"), comment)
  }

  let print_code(code) = {
    set par(first-line-indent: 0em)
    show regex("(lemma|theorem|by|sorry|have|def|let|noncomputable|variable|with|example|fun|at|sorry)(\s|$)"): set text(fill: rgb("#d73a4a"))
    show regex("(lemma|theorem|def)\s\w+"): set text(fill: rgb("#6f42c1"))
    show regex("\(|\[|\{|\}|\]|\)"): set text(fill: rgb("#4056e9"))
    code
  }
  
  let n_comment = 0
  let n_char = 0
  let final_content = []
  for i in range(cont_without_comments.len()) {
    while (comment_matches.len() > n_comment and (comment_matches.at(n_comment).start == n_char or comment_matches.at(n_comment).start == 1)) {
      final_content += print_comment(comment_matches.at(n_comment).text)
      n_char += comment_matches.at(n_comment).text.len()
      n_comment += 1
    }
    final_content += print_code(cont_without_comments.at(i))
    n_char += cont_without_comments.at(i).len()
  }
  if (comment_matches.len() > n_comment) {
    final_content += print_comment(comment_matches.at(n_comment).text)
  }
  block(width: 90%, align(left, final_content))
}

#let config(
  title: none,
  subtitle: none,
  header: none,
  authors: none,
  supervision: none,
  abstract: none,
  keywords: (),
  first_page_nb: true,
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

  let page_nb = {
    if first_page_nb {
      "1"
    } else {
      (..nums) => {
        let nb = nums.pos().map(str).at(0)
        if nb == "1" {
          none
        } else {
          nb
        }
      }
    }
  }
  
  // Set rules
  set page(
    paper: "a4",
    header: header_loc,
    numbering: page_nb,
    background: locate(loc => {
      let page_nb = counter(page).at(loc).at(0)
      if page_nb == 1 and logo != none {
        logo
      } else {
        none
      }
    })
  )

  set par(justify: true, first-line-indent: 1em)

  set text(font: "New Computer Modern")

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
  show footnote: set text(fill: rgb("#ff0000"))
  show link: set text(fill: rgb("#7209b7"))
  show cite: set text(fill: rgb("#4361ee"))

  show math.equation: set text(font: "New Computer Modern Math")
  

  // Algorithm & Lean figure
  show figure: fig => {
    if fig.kind == "algorithm" {
      fig.body
    } else if fig.kind == "leancode" {
      counter(fig.kind).step()
      fig.body + align(center, [#fig.supplement #counter(fig.kind).display(): #fig.caption])
    } else {
      fig
    }
  }

  show heading: it => {
    if it.body == [Bibliography] or it.body == [Contents] {
      [#it.body \ \ ]
    } else {
      let heading_nb = counter(heading).display()
      if it.level == 1 {
        [\ \ #heading_nb $space$ #it.body\ \ ]
      } else {
        [\ #heading_nb $space$ #it.body\ ]
      }
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

  if supervision != none {
    align(center,[
      #supervision
    ])
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
