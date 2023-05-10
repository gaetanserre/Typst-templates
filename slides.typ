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

/**********************************BEAMER ENVIRONMENT*********************************************/
/*************************************************************************************************/

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

#let slide(
  title: "Title",
  content: [Content],
  breakpage: true,
) = {
  title
  align(center + horizon, box([
    #content
  ]))

  if breakpage {
    pagebreak()
  }
}

#let title_slide(
  title: "Title",
  subtitle: [Subtitle],
  authors: [Authors],
  emails: [Emails],
  date: none) = {
    set page(footer: [])
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
  background_color: rgb("#03045e"),
  background: none,
  title_color: rgb("#00b4d8"),
  text_color: rgb("#caf0f8"),
  footer: none,
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

  set par(
    justify: true,
  )

  show ref: set text(fill: rgb("#ff0000"))
  show link: set text(fill: rgb("#7209b7"))
  show cite: set text(fill: rgb("#4361ee"))

  set text(font: "CMU Serif", size: 15pt, fill: text_color)

  set heading(numbering: none)

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
      fig.body
    } else {
      fig
    }
  }

  // Indentation
  set par(
    first-line-indent: 1em
  )

  show heading: it => [
    #set align(center)
    #set text(25pt, font: "CMU Serif", weight: "regular", fill: title_color)
    #it.body
  ]

  doc
}