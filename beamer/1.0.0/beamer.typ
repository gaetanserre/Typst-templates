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

#let in_bib(loc) = {
  let previous_heading_bodies = query(selector(heading).before(loc), loc).map(h => {h.body})
  return previous_heading_bodies.contains([Bibliography])
}

#let get_last_page_before_bib(loc) = {
  if in_bib(loc) {
    return counter(page).final(loc).at(0)
  }

  let headings = query(selector(heading).after(loc), loc)
  let bib_page_nb = counter(page).final(loc).at(0)
  let flag = false
  for heading in headings {
    if heading.body == [Bibliography] {
      bib_page_nb = counter(page).at(heading.location()).at(0)
    }
    flag = heading.body == [Bibliography]
  }
  return bib_page_nb - 1
}

#let has_previous_title(title, loc) = {
  let headings = query(selector(heading).before(loc), loc)
  for heading in headings {
    if heading.body == title {
      return true
    }
  }
  return false
}

#let title_style(title, title_color: rgb("#6e4e80")) = {
  text(size: 25pt, fill: title_color, title)
}

#let subtitle_style(subtitle, subtitle_color: rgb("#9384D1")) = {
  text(style: "italic", fill: subtitle_color, subtitle)
}

#let slide(
  title: none,
  subtitle: none,
  content: none,
  breakpage: true,
) = {
  locate(loc => {
    set par(leading: 20pt)
    if title != none {
      if has_previous_title(title, loc) {
        title_style(title)
      } else {
        [= #title]
      }
    }

    if subtitle != none {
      if has_previous_title(subtitle, loc) {
        linebreak() + subtitle_style(subtitle)
      } else {
        [== #subtitle]
      }
    }

    set par(leading: 0.65em)

    align(center + horizon, box([
      #content
    ]))

    if breakpage {
      pagebreak()
    }
  })
}

#let columns_slide(
  title: none,
  subtitle: none,
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
    set page(footer: [], background: background)
    slide(
      title: none,
      content: [
        #text(size: 20pt, [#title])\
        #emph(subtitle)\
        #authors\
        #emails\
        #date
      ],
      breakpage: false
    )
    counter(page).update(0)
}

#let get_n_space(n) = {
  for i in range(n) {
    $space space space$
  }
}

#let outline_dict_lang = (
  "en": "Outline",
  "fr": "Table des matières",
)

#let outline_slide(lang: "en", size: none) = {
  set par(first-line-indent: 0em)
  //align(center, text(size: 25pt, [Outline\ ]))
  [= #outline_dict_lang.at(lang)]
  locate(loc => {
    let headings = query(selector(heading).after(loc), loc)
    let unique_headings = ()
    //let counter_heading = counter(page).at(loc).at(0)
    align(top,
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
    pagebreak()
  }) 
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
      [*#supplement #counter.display()* (#emph(name)). ] + it
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

#let lemma(name, it, label: none, eq_numbering: none) = math_block("Lemma", name, it, label, rgb("#b287a3"), eq_numbering)

#let proposition(name, it, label: none, eq_numbering: none) = math_block("Proposition", name, it, label, rgb("#b1255d"), eq_numbering)

#let theorem(name, it, label: none, eq_numbering: none) = math_block("Theorem", name, it, label, rgb("#5f072a"), eq_numbering)

#let corollary(name, it, label: none, eq_numbering: none) = math_block("Corollary", name, it, label, rgb("#ffc300"), eq_numbering)

#let definition(name, it, label: none, eq_numbering: none) = math_block("Definition", name, it, label, rgb("#bfb1c1"), eq_numbering)

#let remark(name, it, label: none, eq_numbering: none) = math_block("Remark", name, it, label, rgb("#8380b6"), eq_numbering)

#let example(it, label: none, eq_numbering: none) = math_block("Example", none, it, label, rgb("#9bc4cb"), eq_numbering)

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
#let lean_font(cont) = text(font: "Menlo", size: 12pt, cont)

#let lean_block(cont) = {
  set par(first-line-indent: 0em)
  show par: set block(spacing: 0em)
  set text(font: "Menlo", size: 12pt)
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
  background_color: rgb("#03045e"),
  background: none,
  title_color: rgb("#6e4e80"),
  subtitle_color: rgb("#9384D1"),
  text_color: rgb("#caf0f8"),
  footer: locate(loc => {
    let color = gradient.linear(rgb(63, 78, 155), rgb(233, 80, 57))
    let page_nb = counter(page).at(loc).at(0)
    let last_page = get_last_page_before_bib(loc)
    let max_size_bar = 50pt
    let current_size_bar = ((page_nb - 1)/(last_page - 1)) * max_size_bar

    let box = {
      if in_bib(loc) {
        []
      } else {
        align(right, box(
          width: max_size_bar,
          height: 6pt,
          fill: rgb("#eeeeee"),
          radius: 3pt,
          align(left, rect(
            width: current_size_bar,
            height: 6pt,
            fill: color,
            radius: 3pt
          ))
        ))
      }
    }

    grid(
      columns: (33%, 33%, 33%),
      [],
      align(center, text(size: 9pt, [#page_nb -- G. Serré - Centre Borelli])),
      box
    )
  }),
  lang: "en",
  doc
) = {
  set page(
    paper: "presentation-16-9",
    numbering: "1",
    footer: footer,
    background: {
      if background != none {
        background
      } else {
        rect(width: 100%, height: 100%, fill: background_color, stroke: none)
      }
    }
  )

  // Set rules

  set par(
    justify: true,
  )

  set text(font: "New Computer Modern", size: 15pt, fill: text_color, lang: lang)

  set heading(numbering: none)

  set cite(style: "chicago-author-date")

  set math.equation(numbering: "(1)")

  set list(indent: 1em, marker: ([•], [--]))
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
      set text(25pt, font: "CMU Serif", weight: "regular", fill: title_color)
      it.body
    } else if it.level == 2 {
      set par(first-line-indent: 0em)
      set text(15pt, font: "CMU Serif", style: "italic", weight: "regular", fill: subtitle_color)
      it.body
    } else {
      it.body
    }
    
  }

  doc
}