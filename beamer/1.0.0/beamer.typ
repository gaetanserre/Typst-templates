/*
 * Created in 2023 by Gaëtan Serré
 */


#let TODO(it) = {
  text(fill: red, weight: "extrabold", [TODO #it])
}

/**********************************BEAMER ENVIRONMENT*********************************************/
/*************************************************************************************************/

#let sans_serif_font = "Noto Sans"

#let s_lang = state("lang", "en")
#let bib_wording = ("en": [Bibliography], "fr": [Bibliographie])
#let outline_wording = ("en": [Outline], "fr": [Table des matières])
#let thanks_wording = (
  "en": [Thank you for your #text(fill: rgb("#937bf1"), [attention])!],
  "fr": [Merci pour votre #text(fill: rgb("#937bf1"), [attention]) !],
)

#let past_bib(loc) = {
  let previous_heading_bodies = query(selector(heading).before(loc)).map(h => { h.body })
  return previous_heading_bodies.contains(bib_wording.at(s_lang.at(loc)))
}

#let get_last_page_before_bib(loc) = {
  if past_bib(loc) {
    return counter("page").final().at(0)
  }

  let headings = query(selector(heading).after(loc))
  let bib_page_nb = counter("page").final().at(0)
  for heading in headings {
    if heading.body == bib_wording.at(s_lang.at(loc)) {
      bib_page_nb = counter("page").at(heading.location()).at(0)
    }
  }
  return bib_page_nb - 1
}

#let title_color = rgb("#503fa1")
#let subtitle_color = rgb("#937bf1")
#let s_title_color = state("title_color", title_color)
#let s_subtitle_color = state("subtitle_color", subtitle_color)

#let has_previous_title(title) = {
  let headings = query(selector(heading).before(here()))
  for heading in headings {
    if heading.body == title {
      return true
    }
  }
  return false
}

#let has_previous_subtitle(title, subtitle) = {
  let headings = query(selector(heading).before(here()))
  let h = none
  for i in range(headings.len()) {
    if headings.at(i).level == 1 or h == none {
      h = headings.at(i)
    }
    if headings.at(i).body == subtitle and headings.at(i).level == 2 and h.body == title {
      return true
    }
  }
  return false
}

#let title_style(title) = context {
  text(size: 25pt, fill: s_title_color.final(), [#v(-0.5em) #title])
}

#let subtitle_style(subtitle) = context {
  text(style: "italic", fill: s_subtitle_color.get(), [#v(-0.5em) #subtitle #v(-0.555em)])
}

#let slide(
  title: none,
  subtitle: none,
  h_block_align: center,
  v_block_align: horizon,
  breakpage: true,
  content,
) = context {
  set par(leading: 20pt)
  if title != none {
    if has_previous_title(title) {
      title_style(title)
    } else {
      [= #title]
    }
  }

  if subtitle != none {
    if has_previous_subtitle(title, subtitle) {
      subtitle_style(subtitle)
    } else {
      [== #subtitle]
      counter("page").step()
    }
  } else if not has_previous_title(title) {
    counter("page").step()
  }

  set par(leading: 0.65em)

  align(
    h_block_align + v_block_align,
    box([
      #content
    ]),
  )

  if breakpage {
    pagebreak()
  }
}

#let columns_slide(
  title: none,
  subtitle: none,
  h_block_align: center,
  v_block_align: horizon,
  contents: (),
  common_content: none,
  columns: none,
  column_gutter: 2em,
  stroke: none,
  breakpage: true,
) = {
  if columns == none {
    columns = ()
    for content in contents {
      columns += (auto,)
    }
  }

  let content = (
    grid(
      columns: columns,
      column-gutter: column_gutter,
      stroke: stroke,
      rows: auto,
      ..contents
    )
      + common_content
  )

  slide(
    title: title,
    subtitle: subtitle,
    h_block_align: center,
    v_block_align: horizon,
    content: content,
    breakpage: breakpage,
  )
}

#let init_bullet_list(
  items: (),
  numbered: false,
) = {
  (numbers, last_bullet: none) => {
    let counter = 0
    for i in numbers {
      if numbered {
        if counter == (numbers.len() - 1) and last_bullet != none [
          + #last_bullet(items.at(i))
        ] else [
          + #items.at(i)
        ]
      } else {
        if counter == (numbers.len() - 1) and last_bullet != none [
          - #last_bullet(items.at(i))
        ] else [
          - #items.at(i)
        ]
      }
      counter += 1
    }
  }
}

#let unfold_bullet(items, title: none, numbered: false, last_bullet: none) = {
  let bullet = init_bullet_list(
    items: items,
    numbered: numbered,
  )

  let idx = ()
  for i in range(items.len()) {
    idx += (i,)
    slide(
      title: title,
      content: align(
        left,
        bullet(
          idx,
          last_bullet: last_bullet,
        ),
      ),
    )
  }
}

/* #let title_slide(
  title: [Title],
  subtitle: [Subtitle],
  authors: [Authors],
  emails: [Emails],
  date: none,
  logos: (),
) = {
  slide(
    title: none,
    content: [
      #text(size: 30pt, [#title])\
      #text(15pt, style: "italic", subtitle)\
      #authors\
      #emails\
      #date
    ],
    breakpage: false,
  )
  counter("page").update(0)
} */

#let get_n_space(n) = {
  for i in range(n) {
    $space space space$
  }
}

#let check_heading_in_unique(h, hs) = {
  if h.body in hs {
    let elem = hs.find(e => e.body == h.body)
    return elem.level == h.level
  }
  return false
}

#let outline_slide(size: none, v_align: horizon) = context {
  set page(footer: none, background: none)
  set par(first-line-indent: 0em)
  [= #outline_wording.at(s_lang.at(here()))]
  let headings = query(selector(heading).after(here()), here()).slice(1, none)
  let unique_headings = ()
  align(
    v_align,
    for heading in headings {
      if not check_heading_in_unique(heading, unique_headings) {
        let heading_loc = heading.location()
        unique_headings += (heading,)
        let nb_page = {
          let tmp = counter("page").at(heading_loc).at(0)
          if heading.body == bib_wording.at(s_lang.at(here())) {
            tmp
          } else {
            tmp + 1
          }
        }
        let content = (
          get_n_space(heading.level - 1)
            + link(heading_loc)[#heading.body]
            + box(width: 1fr, repeat([.$space$]))
            + link(heading_loc)[#nb_page]
            + [ \ ]
        )
        if size != none {
          text(size: size, content)
        } else {
          content
        }
      }
    },
  )
}

#let thanks_slide() = context {
  set page(footer: none, background: none)
  let wording = thanks_wording.at(s_lang.at(here()))
  align(center + horizon, text(size: 20pt, wording))
}

#let trans_slide(it, subtitle: none) = {
  set page(footer: none, background: none)
  align(center + horizon, text(size: 20pt, title_style(it) + subtitle_style(subtitle)))
}

/***********************************MATHS ENVIRONMENT*********************************************/
/*************************************************************************************************/

#let math_block(supplement_dict, name, it, lb, eq_numbering) = context {
  let supplement = supplement_dict.at(s_lang.final())
  let counter = counter(supplement)
  counter.step()

  set math.equation(numbering: eq_numbering)

  let count = counter.get().at(0) + 1

  let name_box = if name == none {
    text(font: sans_serif_font, size: 15pt, [*#supplement #count*])
  } else {
    [
      #text(font: sans_serif_font, size: 15pt, [*#supplement #count* --])
      #emph(name)
    ]
  }

  let fill_color = rgb("#f7f7f7")

  let fig = figure(
    align(
      left,
      box(
        stroke: (left: 2pt + black),
        inset: (left: 0.5em, bottom: 0.5em),
        [
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
            align(left, it),
          )
        ],
      ),
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

#let lemma(name, it, label: none, eq_numbering: none) = math_block(
  ("en": "Lemma", "fr": "Lemme"),
  name,
  it,
  label,
  eq_numbering,
)

#let proposition(name, it, label: none, eq_numbering: none) = math_block(
  ("en": "Proposition", "fr": "Proposition"),
  name,
  it,
  label,
  eq_numbering,
)

#let theorem(name, it, label: none, eq_numbering: none) = math_block(
  ("en": "Theorem", "fr": "Théorème"),
  name,
  it,
  label,
  eq_numbering,
)

#let corollary(name, it, label: none, eq_numbering: none) = math_block(
  ("en": "Corollary", "fr": "Corollaire"),
  name,
  it,
  label,
  eq_numbering,
)

#let definition(name, it, label: none, eq_numbering: none) = math_block(
  ("en": "Definition", "fr": "Définition"),
  name,
  it,
  label,
  eq_numbering,
)

#let remark(name, it, label: none, eq_numbering: none) = math_block(
  ("en": "Remark", "fr": "Remarque"),
  name,
  it,
  label,
  eq_numbering,
)

#let example(it, label: none, eq_numbering: none) = math_block(
  ("en": "Example", "fr": "Exemple"),
  none,
  it,
  label,
  eq_numbering,
)

#let proof(it) = context {
  block(
    width: 90%,
    align(left, [_#proof_wording.at(s_lang.final())._ $space$] + it + align(right, text()[$qed$])),
  )
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
  block(
    width: auto,
    above: 0.5em,
    below: 0.5em,
    {
      let stroke = ("left": 1pt, "rest": none)
      if not has_stroke {
        stroke = none
      }
      rect(
        stroke: stroke,
        outset: -0.1em,
        inset: (right: 0em, rest: inset),
      )[#content]
    },
  )
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

#let comment(
  content,
) = {
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
  content: none,
) = context {
  set text(font: "New Computer Modern")
  align(
    center,
    block(
      width: auto,
      {
        align(
          left,
          {
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
          },
        )
      },
    ),
  )
}

/*********************************LANGUAGE ENVIRONMENT*******************************************/
/*************************************************************************************************/

#let lean_block(it) = {
  block(
    width: 100%,
    stroke: ("left": 1pt + rgb("#d73a4a"), "rest": none),
    fill: rgb("#f8f6fb"),
    inset: (bottom: 0.7em, rest: 0.5em),
    align(left, raw(lang: "lean4", it)),
  )
}

#let gray(it) = text(fill: rgb("#888888"), it)

#let grad_color = gradient.linear(rgb("#5165aa"), rgb("#8498dd"), relative: "parent")

#let footer(loc, running_author) = {
  let page_nb = counter("page").at(loc).at(0)

  let h = query(selector(heading).after(loc)).map(h => { h.body }).at(0, default: [])

  if page_nb == 0 or h == outline_wording.at(s_lang.at(loc)) {
    return []
  }
  let last_page = counter("page").final().at(0) //get_last_page_before_bib(loc)
  let max_size_bar = 50pt
  let current_size_bar = ((page_nb - 1) / (last_page - 1)) * max_size_bar

  let box = {
    if past_bib(loc) {
      []
    } else {
      align(
        left,
        box(
          width: max_size_bar,
          height: 6pt,
          fill: rgb("#eeeeee"),
          radius: 3pt,
          align(
            left,
            rect(
              width: current_size_bar,
              height: 6pt,
              fill: grad_color,
              radius: 3pt,
            ),
          ),
        ),
      )
    }
  }
  grid(
    columns: (33%, 33%, 33%),
    box, align(center, text(size: 9pt, running_author)), align(right, text(size: 9pt, [#page_nb])),
  )
}

#let config(
  title_color: title_color,
  subtitle_color: subtitle_color,
  text_color: rgb("#000000"),
  lang: "en",
  doc,
) = {
  set page(
    paper: "presentation-16-9",
    numbering: "1",
  )

  // Set rules

  set par(justify: true)

  set text(font: sans_serif_font, size: 15pt, fill: text_color, lang: lang)

  set heading(numbering: none)

  set cite(style: "apa.csl")

  set bibliography(style: "apa.csl")

  set math.equation(numbering: none)

  set list(marker: ([•], $arrow.r.curve$))
  set enum(indent: 1em)

  // Reference style
  set ref(
    supplement: it => {
      let fig = it.func()
      if fig == math.equation {
        text(fill: black, "Eq.")
      } else if fig == figure {
        gray(it.supplement)
      }
    },
  )

  set raw(theme: "catppuccin_latte.thTheme", syntaxes: "lean4.sublime-syntax")

  set footnote.entry(separator: align(right, line(length: 20%, stroke: 1pt + title_color)))

  // Show rules
  show ref: set text(fill: rgb("#ff0000"))
  show link: set text(fill: title_color)
  show cite: set text(fill: rgb("#4361ee"))
  show math.equation: set text(font: "New Computer Modern Math")
  show raw: set text(font: "FiraCode Nerd Font")

  show footnote: set text(fill: subtitle_color)
  show footnote.entry: it => {
    set text(fill: subtitle_color, size: 10pt)
    align(right, it)
  }

  // Algorithm & Lean figure
  show figure: fig => {
    if fig.kind == "algorithm" {
      fig.body
    } else if fig.kind == "leancode" {
      counter(fig.kind).step()
      fig.body + align(center, [#fig.supplement #counter(fig.kind).display(): #fig.caption])
    } else {
      show figure.caption: set text(12pt, fill: rgb("#888888"))
      fig
    }
  }

  show heading: it => {
    set align(left)
    if it.level == 1 {
      set text(25pt, weight: "regular", fill: s_title_color.final())
      v(-0.5em)
      if it.body == bib_wording.at(s_lang.at(here())) {
        it.body
        v(1.5em)
      } else {
        it.body
      }
    } else if it.level == 2 {
      set text(15pt, style: "italic", weight: "regular", fill: s_subtitle_color.final())
      v(-0.5em)
      it.body
    } else {
      it.body
    }
  }
  s_title_color.update(title_color)
  s_subtitle_color.update(subtitle_color)
  s_lang.update(lang)
  doc
}
