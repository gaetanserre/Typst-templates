#import "@preview/fontawesome:0.6.0": *

// Job titles
#let jobtitle-text(data, settings) = {
  if ("titles" in data.personal and data.personal.titles != none) {
    block(width: 100%)[
      #text(weight: "semibold", data.personal.titles.join("  /  "))
      #v(-4pt)
    ]
  } else { none }
}

// Address
#let address-text(data, settings) = {
  if ("location" in data.personal and data.personal.location != none) {
    // Filter out empty address fields
    let address = data.personal.location.pairs().filter(it => it.at(1) != none and str(it.at(1)) != "")
    // Join non-empty address fields with commas
    let location = address.map(it => str(it.at(1))).join(", ")

    block(width: 100%)[
      #location
      #v(-4pt)
    ]
  } else { none }
}

#let contact-text(data, settings) = block(width: 100%)[
  #let contacts = (
    if ("email" in data.personal.contact and data.personal.contact.email != none) {
      box(link("mailto:" + data.personal.contact.email, [#fa-icon("envelope") #data.personal.contact.email]))
    },
    if ("phone" in data.personal.contact and data.personal.contact.phone != none) {
      box(link("tel:" + data.personal.contact.phone, [#fa-icon("mobile") #data.personal.contact.phone]))
    } else { none },
    if ("website" in data.personal.contact) and (data.personal.contact.website != none) {
      box(link(data.personal.contact.website)[#fa-icon("globe") #data.personal.contact.website.split("//").at(1)])
    },
  ).filter(it => it != none) // Filter out none elements from the contact array

  #let profiles = (
    if ("github" in data.personal.profiles and data.personal.profiles.github != none) {
      box(link("https://github.com/" + data.personal.profiles.github, [#fa-icon(
          "github",
        ) \@#data.personal.profiles.github]))
    },
    if ("linkedin" in data.personal.profiles and data.personal.profiles.linkedin != none) {
      box(link("https://www.linkedin.com/in/" + data.personal.profiles.linkedin), [#data.personal.profiles.linkedin])
    },
  ).filter(it => it != none) // Filter out none elements from the profiles array

  #let links = contacts + profiles

  #set text(font: settings.font-body, weight: "medium", size: settings.fontsize)
  #pad(x: 0em)[
    #links.join([#sym.space.en | #sym.space.en])
  ]
]


#let layout-header(data, settings, isbreakable: true) = {
  align(center)[
    = #data.personal.name

    #for section in data.sections.filter(s => s.layout == "header" and s.show == true) {
      if "include" in section {
        for item in section.include {
          if item == "titles" {
            jobtitle-text(data, settings)
          }

          if item == "location" {
            address-text(data, settings)
          }

          if item == "contact" {
            contact-text(data, settings)
          }
        }
      }
    }
  ]
}
