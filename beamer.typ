/*
 * Created in 2023 by Gaëtan Serré
 */


// Utils functions
#let range(arr) = {
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

/**********************************BEAMER ENVIRONMENT*********************************************/
/*************************************************************************************************/

#let slide(
  title: none,
  subtitle: none,
  content: none,
  breakpage: true,
) = {
  title
  subtitle
  align(center + horizon, box([
    #content
  ]))

  if breakpage {
    pagebreak()
  }
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
  for i in range(items) {
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

#let outline_slide() = {
  set par(first-line-indent: 0em)
  align(center, text(size: 25pt, [Outline\ ]))
  locate(loc => {
    let headings = query(selector(heading).after(loc), loc)
    let unique_headings = ()
    let counter_heading = counter(page).at(loc).at(0)
    for heading in headings {
      counter_heading += 1
      if heading.body not in unique_headings {
        unique_headings += (heading.body,)
       heading.body + box(width: 1fr, repeat([.$space$])) + [#counter_heading] + [ \ ]
      }
    }
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
      [*#supplement #counter.display() * (#emph(name)). ] + it
    }
  }
  let fig = figure(
    rect(
      width:100%,
      stroke: ("left": 1pt+stroke_color, "rest": none),
      fill: rgb("#eeeeee"),
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

#let theorem(name, it, label: none, eq_numbering: none) = math_block("Theorem", name, it, label, rgb("#643843"), eq_numbering)

#let lemma(name, it, label: none, eq_numbering: none) = math_block("Lemma", name, it, label, rgb("#C88EA7"), eq_numbering)

#let proposition(name, it, label: none, eq_numbering: none) = math_block("Proposition", name, it, label, rgb("#99627A"), eq_numbering)

#let corollary(name, it, label: none, eq_numbering: none) = math_block("Corollary", name, it, label, rgb("#E7CBCB"), eq_numbering)

#let definition(name, it, label: none, eq_numbering: none) = math_block("Definition", name, it, label, rgb("#E57C23"), eq_numbering)

#let remark(name, it, label: none, eq_numbering: none) = math_block("Remark", name, it, label, rgb("#E8AA42"), eq_numbering)

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
  content: none,
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
  content: none,
) = {
  code_block(identifier: [*for* #variable *in* #iterator *do*], content: content)
  [*end for*]
}

#let while_loop(
  condition: "x",
  content: none,
) = {
  code_block(identifier: [*while* #condition *do*], content: content)
  [*end while*]
}

#let if_block(
  condition: "x",
  content: none,
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
  content: none
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
  background_color: rgb("#03045e"),
  background: none,
  title_color: rgb("#00b4d8"),
  subtitle_color: rgb("#00b400"),
  text_color: rgb("#caf0f8"),
  footer: none,
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

  set text(font: "CMU Serif", size: 15pt, fill: text_color, lang: lang)

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