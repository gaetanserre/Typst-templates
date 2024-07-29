/*
 * Created in 2023 by Gaëtan Serré
 */


// Utils functions
#let range(n) = {
  let ret = ()
  let i = 0

  while i < n {
    ret += (i,)
    i += 1
  }
  ret
}

#let TODO(it) = {
  text(fill: red, weight: "extrabold", [TODO #it])
}

/**********************************BEAMER ENVIRONMENT*********************************************/
/*************************************************************************************************/

#let s_lang = state("lang", "en")
#let bib_wording = ("en": [Bibliography], "fr": [Bibliographie])
#let outline_wording = ("en": [Outline], "fr": [Table des matières])

#let in_bib(loc) = {
  let previous_heading_bodies = query(selector(heading).before(loc), loc).map(h => {h.body})
  return previous_heading_bodies.contains(bib_wording.at(s_lang.at(loc)))
}

#let get_last_page_before_bib(loc) = {
  if in_bib(loc) {
    return counter("page").final(loc).at(0)
  }

  let headings = query(selector(heading).after(loc), loc)
  let bib_page_nb = counter("page").final(loc).at(0)
  for heading in headings {
    if heading.body == s_lang.at(loc) {
      bib_page_nb = counter("page").at(heading.location()).at(0)
    }
  }
  return bib_page_nb - 1
}

#let s_title_color = state("title_color", rgb("#503fa1"))
#let s_subtitle_color = state("subtitle_color", rgb("#937bf1"))

#let has_previous_title(title, level: 1) = {
  let headings = query(selector(heading).before(here()))
  for heading in headings {
    if heading.body == title and heading.level == level {
      return true
    }
  }
  return false
}

#let title_style(title) = context {
  text(size: 25pt, fill: s_title_color.final(), [#v(-0.5em) #title])
}

#let subtitle_style(subtitle) = context {
  text(style: "italic", fill: s_subtitle_color.get(), [#v(-0.5em) #subtitle])
}

#let slide(
  title: none,
  subtitle: none,
  content: none,
  h_block_align: center,
  v_block_align: horizon,
  breakpage: true,
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
      if has_previous_title(subtitle, level: 2) {
        linebreak() + subtitle_style(subtitle)
      } else {
        [== #subtitle]
        counter("page").step()
      }
    } else {
      counter("page").step()
    }

    set par(leading: 0.65em)

    align(h_block_align + v_block_align, box([
      #content
    ]))

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
  breakpage: true,
) = {

  if columns == none {
    columns = ()
    for content in contents {
      columns += (auto,)
    }
  }

  let content = grid(
    columns: columns,
    column-gutter: column_gutter,
    rows: (auto),
    ..contents
  ) + common_content

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

#let unfold_bullet(items, title: none, numbered:false, last_bullet: none) = {
  let bullet = init_bullet_list(
    items: items,
    numbered: numbered
  )

  let idx = ()
  for i in range(items.len()) {
    idx += (i,)
    slide(
      title: title,
      content: align(left, bullet(
        idx,
        last_bullet: last_bullet
      )),
    )
  }
}

#let title_slide(
  title: [Title],
  subtitle: [Subtitle],
  authors: [Authors],
  emails: [Emails],
  date: none,
  background: none) = {
    set page(footer: [], background: none)
    slide(
      title: none,
      content: [
        #text(size: 35pt, [#title])\
        #emph(subtitle)\
        #authors\
        #emails\
        #date
      ],
      breakpage: false
    )
    counter("page").update(0)
}

#let get_n_space(n) = {
  for i in range(n) {
    $space space space$
  }
}

#let outline_slide(size: none, v_align: horizon) = context {
  set page(footer: [], background: [])
  set par(first-line-indent: 0em)
  [= #outline_wording.at(s_lang.at(here()))]
  locate(loc => {
    let headings = query(selector(heading).after(loc), loc)
    let unique_headings = ()
    align(v_align,
    for heading in headings {
      if heading.body not in unique_headings {
        let heading_loc = heading.location()
        unique_headings += (heading.body,)
        let content = get_n_space(heading.level - 1) + link(heading_loc)[#heading.body] + box(width: 1fr, repeat([.$space$])) + link(heading_loc)[#(heading_loc.page() - 1)] + [ \ ]
        if size != none {
          text(size: size, content)
        } else {
          content
        }
      }
    })
  }) 
}

#let thanks_slide() = {
  set page(footer: [], background: none)
  align(center + horizon, text(size: 30pt, fill: rgb("#9e517b"), [Thank you for your attention!]))
}

/***********************************MATHS ENVIRONMENT*********************************************/
/*************************************************************************************************/

#let math_block(supplement, name, it, lb, stroke_color, eq_numbering) = context {
  //set text(font: "New Computer Modern")
  let body = {
    set math.equation(numbering: eq_numbering)
    if name == none {
      [*#supplement(here()).* ] + it
    } else {
      [*#supplement(here())* (#emph(name))*.* ] + it
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
    kind: supplement(here()),
    supplement: supplement(here()),
  )
  if lb != none [
    #fig
    #label(lb)
  ] else [
    #fig
  ]
}

// Math blocks

#let lem_wording  = ("en": "Lemma", "fr": "Lemme")
#let prop_wording = ("en": "Proposition", "fr": "Proposition")
#let thm_wording  = ("en": "Theorem", "fr": "Théorème")
#let cor_wording  = ("en": "Corollary", "fr": "Corollaire")
#let def_wording  = ("en": "Definition", "fr": "Définition")
#let re_wording   = ("en": "Remark", "fr": "Remarque")
#let ex_wording   = ("en": "Example", "fr": "Exemple")


#let lemma(name, it, label: none, eq_numbering: none) = {
  math_block(l => lem_wording.at(s_lang.at(l)), name, it, label, rgb("#b287a3"), eq_numbering)
}

#let proposition(name, it, label: none, eq_numbering: none) = {
  math_block(l =>prop_wording.at(s_lang.at(l)), name, it, label, rgb("#b1255d"), eq_numbering)
}

#let theorem(name, it, label: none, eq_numbering: none) = {
  math_block(l => thm_wording.at(s_lang.at(l)), name, it, label, rgb("#5f072a"), eq_numbering)
}

#let corollary(name, it, label: none, eq_numbering: none) = {
  math_block(l => cor_wording.at(s_lang.at(l)), name, it, label, rgb("#ffc300"), eq_numbering)
}

#let definition(name, it, label: none, eq_numbering: none) = {
  math_block(l => def_wording.at(s_lang.at(l)), name, it, label, rgb("#bfb1c1"), eq_numbering)
}

#let remark(name, it, label: none, eq_numbering: none) = {
  math_block(l => re_wording.at(s_lang.at(l)), name, it, label, rgb("#8380b6"), eq_numbering)
}

#let example(it, label: none, eq_numbering: none) = {
  math_block(l => ex_wording.at(s_lang.at(l)), none, it, label, rgb("#9bc4cb"), eq_numbering)
}

#let proof(it) = {
  set par(first-line-indent: 0em)
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
  content: none
) = {
  set text(font: "New Computer Modern")
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
#let lean_font(cont) = text(font: "FiraCode Nerd Font", size: 12pt, cont)

#let lean_block(cont) = {
  set par(first-line-indent: 0em)
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
  }
  
  block(
    width:100%,
    stroke: ("left": 1pt+rgb("#d73a4a"), "rest": none),
    fill: rgb("#eeeeee"),
    inset: (bottom: 0.7em, rest: 0.5em),
    align(left, final_content)
  )
}

#let grad_color = gradient.linear(rgb("#665bad"), rgb("#b6a4da"), relative: "parent")

#let footer(loc) = {
  let page_nb = counter("page").at(loc).at(0)

  let hs = query(selector(heading).after(loc), loc).map(h => {h.body})

  if page_nb == 0 or hs.at(0, default: []) == outline_wording.at(s_lang.at(loc)) {
    return []
  }
  let last_page = get_last_page_before_bib(loc)
  let max_size_bar = 50pt
  let current_size_bar = ((page_nb - 1)/(last_page - 1)) * max_size_bar

  let box = {
    if in_bib(loc) {
      []
    } else {
      align(left, box(
        width: max_size_bar,
        height: 6pt,
        fill: rgb("#eeeeee"),
        radius: 3pt,
        align(left, rect(
          width: current_size_bar,
          height: 6pt,
          fill: grad_color,
          radius: 3pt
        ))
      ))
    }
  }
  grid(
    columns: (33%, 33%, 33%),
    box,
    align(center, text(size: 9pt, [G. Serré - Centre Borelli])),
    align(right, text(size: 9pt, [#page_nb]))
  )
}

#let config(
  background: none,
  title_color: rgb("#503fa1"),
  subtitle_color: rgb("#937bf1"),
  text_color: rgb("#000000"),
  lang: "en",
  footer: context footer(here()),
  doc
) = {
  set page(
    paper: "presentation-16-9",
    numbering: "1",
    footer: footer,
    background: background
  )

  // Set rules

  set par(
    justify: true,
  )

  set text(font: "Museo", size: 15pt, fill: text_color, lang: lang)

  set heading(numbering: none)

  set cite(style: "chicago-author-date")

  set math.equation(numbering: "(1)")

  set list(marker: ($gt.tri$, $arrow.r.curve$))
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