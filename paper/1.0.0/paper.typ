/*
 * Created in 2023 by Gaëtan Serré
 */


#let sans_serif_font = "Noto Sans"

#let TODO(it) = {
  let color = rgb("#d4bb65")
  box(width: 100%, stroke: 3pt + color, inset: 1em, [
    #text(fill: color, font: sans_serif_font, underline(stroke: 1.5pt, offset: 2pt, [*TODO!!*])) \
    #it
  ])
}

#let link_note(url, text) = {
  link(url)[#text] + footnote(link(url))
}

#let s_lang = state("lang", "en")
#let bib_wording = ("en": [Bibliography], "fr": [Bibliographie])
#let outline_wording = ("en": [Outline], "fr": [Table des matières])
#let proof_wording = ("en": [Proof], "fr": [Preuve])

/***********************************MATHS ENVIRONMENT*********************************************/
/*************************************************************************************************/

#let math_block(supplement_dict, name, it, lb, numbering: true) = context {
  let supplement = supplement_dict.at(s_lang.final())
  let counter = counter(supplement)
  let prefix = {
    if numbering {
      counter.step()
      let count = counter.get().at(0) + 1
      [*#supplement #count*]
    } else {
      [*#supplement*]
    }
  }

  let name_box = if name == none {
    text(font: sans_serif_font, size: 10pt, prefix)
  } else {
    [
      #text(font: sans_serif_font, size: 10pt, [#prefix --])
      #emph(name)
    ]
  }

  let fill_color = rgb("#f7f7f7")

  let fig = figure(
    align(left, box(stroke: (left: 2pt + black), inset: (left: 0.5em, bottom: 0.5em), [
      #box(
        fill: fill_color,
        inset: (left: 0em, rest: 0.5em),
        outset: (left: 0.5em - 1pt),
        radius: (top-right: 0.3em),
        name_box,
      )
      #v(-1.4em)
      #rect(
        width: 100%,
        fill: fill_color,
        inset: (left: 0em, rest: 0.5em),
        outset: (bottom: 0.5em, left: 0.5em - 1pt),
        radius: (right: 0.3em),
        align(left, it),
      )
    ])),
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

#let lemma(name, it, label: none) = math_block(
  ("en": "Lemma", "fr": "Lemme"),
  name,
  it,
  label,
)

#let proposition(name, it, label: none) = math_block(
  ("en": "Proposition", "fr": "Proposition"),
  name,
  it,
  label,
)

#let theorem(name, it, label: none) = math_block(
  ("en": "Theorem", "fr": "Théorème"),
  name,
  it,
  label,
)

#let corollary(name, it, label: none) = math_block(
  ("en": "Corollary", "fr": "Corollaire"),
  name,
  it,
  label,
)

#let definition(name, it, label: none) = math_block(
  ("en": "Definition", "fr": "Définition"),
  name,
  it,
  label,
)

#let remark(it, label: none, numbering: false) = math_block(
  ("en": "Remark", "fr": "Remarque"),
  none,
  it,
  label,
  numbering: numbering,
)

#let example(it, label: none, numbering: false) = math_block(
  ("en": "Example", "fr": "Exemple"),
  none,
  it,
  label,
  numbering: numbering,
)

#let proof(it) = context {
  block(width: 100%, align(
    left,
    [_#proof_wording.at(s_lang.final())._ $space$] + it + align(right, $square.stroked$),
  ))
}


/*********************************ALGORITHM ENVIRONMENT*******************************************/
/*************************************************************************************************/

#let code_block(
  identifier: none,
  comment: none,
  content: [],
  has_stroke: true,
  inset: 1em,
) = {
  if comment == none {
    identifier
  } else {
    [#identifier #box(width: 1fr, repeat(" ")) #text(fill: rgb("#6c6c6c"), style: "italic", comment)]
  }
  block(width: auto, above: 0.5em, below: 0.5em, {
    let stroke = ("left": 1pt, "rest": none)
    if not has_stroke {
      stroke = none
    }
    rect(stroke: stroke, outset: -0.1em, inset: (right: 0em, rest: inset))[#content]
  })
}

#let for_loop(
  variable: "i",
  start: "1",
  end: "n",
  comment: none,
  content: [],
) = {
  code_block(identifier: [*for* #variable $=$ #start *to* #end *do*], comment: comment, content: content)
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
  style: none,
) = {
  if style == none {
    text(fill: fill, weight: weight, keyword)
  } else {
    style(keyword)
  }
}

#let Return = keyword([return], weight: "bold")
#let Break = keyword([break], weight: "bold")
#let Continue = keyword([continue], weight: "bold")

#let algorithm(
  name: none,
  input: none,
  output: none,
  content: [],
) = {
  align(center, block(width: auto, {
    align(left, {
      counter("algorithm").step()
      //show line: set block(above: 0.4em, below: 0.4em)
      set par(first-line-indent: 0em)
      box(width: 1fr, line(length: 100%, stroke: { 1.5pt + black })) + [ \ ]
      [*Algorithm #counter("algorithm").display():* #smallcaps(name) \ ]
      box(width: 1fr, line(length: 100%, stroke: { 1pt + black })) + [ \ ]
      if input != none {
        [*Input:*]
        align(center, block(width: 95%, above: 0.5em, below: 0.5em, align(left, input)))
      }
      if output != none {
        [*Output:*]
        align(center, block(width: 95%, above: 0.5em, below: 0.5em, align(left, output)))
      }

      if output != none or input != none {
        box(width: 1fr, line(length: 100%, stroke: { 1pt + black })) + [ \ ]
      }

      [#content \ ]
      box(width: 1fr, line(length: 100%, stroke: { 1pt + black }))
    })
  }))
}

/*********************************LANGUAGE ENVIRONMENT*******************************************/
/*************************************************************************************************/

/***LEAN***/
// #let lean_font(cont) = text(font: "FiraCode Nerd Font", size: 9pt, cont)

#let lean_block(it) = {
  block(
    width: 100%,
    stroke: ("left": 1pt + rgb("#d73a4a"), "rest": none),
    fill: rgb("#eeeeee"),
    inset: (bottom: 0.7em, rest: 0.5em),
    align(left, raw(lang: "lean4", it)),
  )
}

#let heading_numbering = state("heading_numbering", "1.1")

#let nonumber_headings = state("nonumber_headings", ())

#let nonumber_heading(it) = context {
  nonumber_headings.update(headings => (..headings, it.body))
  set heading(numbering: none)
  it
}

#let appendix() = {
  heading_numbering.update("A.1")
  nonumber_heading([= Appendix])
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
  logo: none,
  lang: "en",
  doc,
) = context {
  s_lang.update(lang)

  let bib_wording_final = bib_wording.at(s_lang.final())
  let outline_wording_final = outline_wording.at(s_lang.final())
  nonumber_headings.update(headings => (headings, bib_wording_final, outline_wording_final))

  // Odd-switching header function
  let header_loc = none
  if header != none {
    header_loc = context {
      let page_nb = counter(page).at(here()).at(0)
      if page_nb == 1 {
        none
      } else if calc.rem(page_nb, 2) == 1 {
        align(right, header)
      } else {
        if authors == none {
          align(left, "Gaëtan Serré")
        } else if authors.len() > 1 {
          align(left, authors.at(0).name + " et al.")
        } else {
          align(left, authors.at(0).name)
        }
      }
    }
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
    background: context {
      let page_nb = counter(page).at(here()).at(0)
      if page_nb == 1 and logo != none {
        logo
      } else {
        none
      }
    },
    footer: context {
      let page_nb = counter(page).display()
      if page_nb == none {
        none
      } else {
        align(center, [-- #page_nb --])
      }
    },
  )

  set par(justify: true, first-line-indent: 0em)


  set text(font: "New Computer Modern", lang: s_lang.final())

  set heading(numbering: (..nums) => context {
    numbering(heading_numbering.get(), ..(nums.pos()))
  })

  // Display math equations only if they have a label
  show: it => {
    let state = state("equation-labels", ())
    show math.equation.where(block: true): it => {
      if it.has("label") {
        state.update(labels => (..labels, it.label))
      }
      it
    }
    context if state.final() != () {
      let labeled = state.final().map(label => math.equation.where(label: label))
      show selector.or(..labeled): set math.equation(numbering: "(1)", supplement: "Eq.")
      it
    } else {
      it
    }
  }

  set cite(style: "chicago-author-date")

  set terms(indent: 1em)
  set list(marker: ("--", $arrow.r.curve$))
  set enum(indent: 1em)

  // Reference style
  set ref(supplement: it => {
    let fig = it.func()
    if fig == math.equation {
      text(fill: black, "Eq.")
    } else if fig == figure {
      text(fill: black, it.supplement)
    }
  })

  set outline(indent: auto)
  set outline.entry(fill: repeat([.$space$]))
  set raw(theme: "catppuccin_latte.thTheme", syntaxes: "lean4.sublime-syntax")

  set enum(numbering: "i.")

  // Show rules

  show ref: set text(fill: rgb("#ff0000"))
  show footnote: set text(fill: rgb("#ff0000"))
  show link: set text(fill: rgb("#7209b7"))
  show cite: set text(fill: rgb("#4361ee"))
  show math.equation: set text(font: "New Computer Modern Math")
  show raw: set text(font: "FiraCode Nerd Font")


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

  show heading: it => context {
    set text(font: sans_serif_font)
    let counter_value = counter(heading).get().at(0)

    if it.level == 1 and not nonumber_headings.final().contains(it.body) {
      grid(
        columns: (5%, 95%),
        column-gutter: 0.5em,
        square(width: 100%, fill: black, radius: 0.2em, align(horizon + center, text(fill: white, [#counter_value]))),
        align(horizon, it.body),
      )
      v(0.3em)
    } else {
      it
      v(0.2em)
    }
  }

  //show outline: set page(numbering: "1")

  // Title & subtitle
  align(center, {
    text(size: 18pt, font: sans_serif_font)[*#title*]
    if subtitle != none {
      text(size: 14pt)[ \ #emph(subtitle)]
    }
  })

  // Authors
  if authors == none {
    align(center, text(font: sans_serif_font, size: 12pt)[
      Gaëtan Serré \
      Centre Borelli - ENS Paris-Saclay \
      #text(font: "CMU Typewriter Text")[
        #link("mailto:gaetan.serre@ens-paris-saclay.fr")
      ]
    ])
  } else {
    for author in authors {
      align(center, text(font: sans_serif_font, size: 14pt)[
        #author.name \
        #author.affiliation \
        #text(font: "CMU Typewriter Text")[
          #link("mailto:" + author.email)
        ]
      ])
    }
  }

  if supervision != none {
    align(center, [
      #supervision
    ])
  }

  // Abstract
  let width_box_abstract = 80%

  if abstract != none {
    align(center, text()[*Abstract*])
    align(center, box(width: width_box_abstract, align(left, text(size: 10pt)[
      #abstract
    ])))
  }

  // Keywords
  align(center, box(width: width_box_abstract, align(left, {
    set text(size: 10pt)
    if keywords.len() > 0 {
      [*Keywords: *]
      let last_keyword = keywords.pop()
      for keyword in keywords {
        [#keyword] + [; ]
      }
      [#last_keyword.]
    }
  })))

  doc
}
