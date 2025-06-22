/*
 * Created in 2023 by Gaëtan Serré
 */


// Utils functions

#let TODO(it) = {
  text(fill: red, weight: "extrabold", [TODO #it])
}

#let link_note(url, text) = {
  link(url)[#text] + footnote(link(url))
}

/***********************************MATHS ENVIRONMENT*********************************************/
/*************************************************************************************************/

#let heading_count = counter(heading)

#let math_block(supplement, name, it, lb, stroke_color) = {
  let counter = counter(supplement)
  counter.step()

  let name_box = if name == none {
    text(fill: stroke_color, [*#supplement*])
  } else {
    text(fill: stroke_color, [*#supplement* -- #emph(name)])
  }

  let fig = figure(
    align(left, box(stroke: (left: 5pt + stroke_color), inset: (left: 0.5em, bottom: 0.5em), [
      #box(fill: rgb("#fcfcfc"), inset: (left: 0em, rest: 0.5em), radius: (top-right: 0.3em), name_box),
      #v(-1.4em)
      #set text(font: "New Computer Modern", size: 37pt)
      #rect(width: 100%, fill: rgb("#fcfcfc"), inset: (left: 0em, rest: 0.5em), outset: (bottom: 0.5em), align(
        left,
        it,
      ))
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

#let lemma(name, it, label: none) = math_block("Lemma", name, it, label, rgb("#b287a3"))

#let proposition(name, it, label: none) = math_block("Proposition", name, it, label, rgb("#b1255d"))

#let theorem(name, it, label: none) = math_block("Theorem", name, it, label, rgb("#a4252a"))

#let corollary(name, it, label: none) = math_block("Corollary", name, it, label, rgb("#ffc300"))

#let definition(name, it, label: none) = math_block("Definition", name, it, label, rgb("#78a3ef"))

#let remark(name, it, label: none) = math_block("Remark", name, it, label, rgb("#8380b6"))

#let example(it, label: none) = math_block("Example", none, it, label, rgb("#bfb1c1"))

#let proof(it) = {
  set par(first-line-indent: 0em)
  set align(center)
  block(width: 90%, align(left, [_Proof._ $space$] + it + align(right, text()[$qed$])))
}


/*********************************ALGORITHM ENVIRONMENT*******************************************/
/*************************************************************************************************/

#let code_block(
  identifier: none,
  comment: none,
  content: [],
  has_stroke: true,
  inset: 0.5em,
) = {
  if comment == none {
    identifier
  } else {
    [#identifier #box(width: 1fr, repeat(" ")) #text(fill: rgb("#6c6c6c"), style: "italic", comment)]
  }
  block(width: auto, above: 0.5em, below: 0.5em, {
    let stroke = (left: black + 1pt, rest: none)
    if not has_stroke {
      stroke = none
    }
    rect(stroke: stroke, outset: -0.1em, inset: (right: 0em, left: 1em, rest: inset))[#content]
  })
}

#let for_loop(
  variable: $i$,
  start: $1$,
  end: $n$,
  comment: none,
  content: [],
) = {
  code_block(identifier: [*for* #variable $=$ #start *to* #end *do*], comment: comment, content: content)
  [*end for*]
}

#let foreach_loop(
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
  [#box(width: 1fr, repeat(" ")) #text(fill: rgb("#b2b2b2"), style: "italic", content)]
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
      [*Algorithm:* #smallcaps(name) \ ]
      v(-1.2em)
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
// #let lean_font(cont) = text(font: "FiraCode Nerd Font", size: 12pt, cont)

#let lean_block(it) = {
  /* set par(first-line-indent: 0em)
  show par: set block(spacing: 0em)
  set text(font: "FiraCode Nerd Font", size: 12pt)
  let reg_comment = regex(`(\/-[^-/]*-\/)|(--.*)`.text)
  let comment_matches = cont.matches(reg_comment)
  let cont_without_comments = cont.split(reg_comment)

  let print_comment(comment) = {
    set par(first-line-indent: 0em)
    show regex("[^\*]\*[^\*]+\*(\n | [^\*])"): set text(style: "italic", fill: black)
    show regex("`.+`"): set text(fill: rgb("#ad7fa8"))
    show regex("\*\*[^\*]+\*\*"): set text(weight: "bold", fill: black)
    text(fill: rgb("#6a737d"), comment)
  }

  let print_code(code) = {
    set par(first-line-indent: 0em)
    show regex("(lemma|theorem|by|sorry|have|def|let|noncomputable|variable|with|example|fun|at|show|class|instance|where)(\s|$)"): set text(fill: rgb("#8b3fef"))
    show regex("Type"): set text(fill: rgb("#8b3fef"))
    show regex("(lemma|theorem|def|class)\s\w+"): set text(fill: rgb("#3475f5"))
    show regex("\(|\[|\{|\}|\]|\)"): set text(fill: rgb("#d4244a"))
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
  } */

  block(
    width: 100%,
    stroke: ("left": 1pt + rgb("#d73a4a"), "rest": none),
    fill: rgb("#f8f6fb"),
    inset: (bottom: 0.7em, rest: 0.5em),
    align(left, raw(lang: "lean4", it)),
  )
}

#let gray(it) = text(fill: rgb("#888888"), it)
#let color_left = rgb("#665bad")
#let color_right = rgb("#d3c8e9")
#let grad_color = gradient.linear(color_left, color_right)
#let accent(it, bold: true) = context {
  /* let color = if here().position().at("x").cm() < 84.1 / 2 {
    color_left
  } else {
    color_right
  } */
  let color = color_left
  set text(fill: color, weight: if bold { "bold" } else { "regular" })
  it
}

#let gen_bibliography(references: "") = {
  align(left)[
    #rect(
      width: 85cm,
      inset: (top: 2em, left: 1em, rest: 0em),
      stroke: (top: 10pt + grad_color, rest: none),
      outset: 0em,
    )[
      #bibliography(references)
      #v(0.8em)
    ]
  ]
}

#let mail(email) = {
  set text(font: "CMU Typewriter Text")
  link("mailto:" + email)[#email]
}

#let config(
  title: none,
  subtitle: none,
  authors: none,
  background: none,
  doc,
) = {
  let sans_serif_font = "SF Pro Display"

  // Set rules
  set page(paper: "a0", header: none, numbering: none, background: background, margin: (
    top: 3em,
    bottom: 2em,
    rest: 3em,
  ))

  set par(justify: true, first-line-indent: 0em)

  set text(font: sans_serif_font, size: 33pt)

  set heading(numbering: none)

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

  set cite(style: "ieee")

  set terms(indent: 1em)
  set enum(indent: 1em)

  // Reference style
  set ref(supplement: it => {
    let fig = it.func()
    if fig == math.equation {
      [Eq.]
    } else {
      it.supplement
    }
  })

  set outline(indent: auto)
  set outline.entry(fill: repeat([.$space$]))

  set list(marker: ($gt.tri$, $arrow.r.curve$))

  set raw(theme: "catppuccin_latte.thTheme", syntaxes: "lean4.sublime-syntax")

  // Show rules

  show footnote: set text(fill: rgb("#ff0000"))
  show link: set text(fill: rgb("#7209b7"))
  show cite: set text(fill: rgb("#4361ee"))

  show ref: it => {
    if it.element == none {
      it
    } else {
      show link: set text(fill: rgb("#ff0000"))
      let count = counter(it.element.func()).at(it.element.location()).at(0)
      if it.element.func() == math.equation {
        [Eq. ] + link(it.target, [#count])
      } else {
        let count = counter(figure.where(kind: it.element.kind)).at(it.element.location()).at(0)
        let supp = it.element.supplement
        if supp == [Figure] {
          [Fig. ] + link(it.target, [#count])
        } else {
          supp + link(it.target, [#count])
        }
      }
    }
  }

  show math.equation: set text(font: "New Computer Modern Math")

  // Algorithm & Lean figure
  show figure: fig => {
    if fig.kind == "algorithm" {
      fig.body
    } else if fig.kind == "leancode" {
      counter(fig.kind).step()
      fig.body + align(center, [#fig.supplement #counter(fig.kind).display(): fig.caption])
    } else {
      show figure.caption: set text(fill: rgb("#888888"))
      fig
    }
  }
  show heading: it => {
    if it.body == [Bibliography] or it.body == [Contents] {
      []
    } else {
      let size = {
        if it.level >= 2 { 30pt } else { 50pt }
      }
      set text(size: size, font: sans_serif_font)
      v(0.5em)
      accent(it.body)
      v(-0.5em)
    }
  }

  show bibliography: it => {
    set text(size: 25pt)
    it
  }

  show raw: set text(font: "FiraCode Nerd Font")


  // Title & subtitle
  align(left, {
    text(size: 70pt, fill: white, weight: "bold", font: sans_serif_font, title)
    if subtitle != none {
      text(30pt)[ \ #emph(subtitle)]
    }
  })

  // Authors
  if authors == none {
    v(-1em)
    align(left, text(size: 50pt, fill: white, font: sans_serif_font)[
      Gaëtan Serré \
      #text(size: 30pt)[
        École Normale Supérieure Paris-Saclay, Centre Borelli, MLMDA Team
      ]
    ])
  } else {
    for author in authors {
      v(-1em)
      align(left, text(size: 50pt, fill: white, font: sans_serif_font)[
        #author.name \
        #text(size: 30pt, [
          #author.affiliation \
          #v(-1em)
          #text(font: "CMU Typewriter Text")[
            #link("mailto:" + author.email)
          ]
        ])

      ])
    }
  }

  doc
}
