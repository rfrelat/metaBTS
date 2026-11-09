library(shiny)
library(leaflet)

ui <- navbarPage(
  # page with tabs to navigate to different pages
  title = "Bottom Trawl Surveys - Metadata",
  # -----------------------
  # A. Map
  # -----------------------
  tabPanel(
    "Spatial coverage",
    leafletOutput("Map", height = "80vh")
  ),
  # -----------
  # B. About page
  # -----------
  tabPanel(
    "About",
    "This Shiny app is the companion of the inventory of bottom trawl surveys",
    "published in Global Change Biology by Maureaud A.",
    em("et al."),
    "in 2020, ",
    em(
      "Are we ready to track climate‐driven shifts in marine species across international boundaries? ‐ A global survey of scientific bottom trawl data"
    ),
    tags$a(
      href = "https://doi.org/10.1111/gcb.15404",
      "DOI: 10.1111/gcb.15404"
    ),
    p(" "),
    p("Last update: January 2021"),
    h4("How to use?"),
    p(
      "In the tab 'Spatial Coverage', navigate the map to see the extent of the bottom trawl surveys."
    ),
    p(
      "Click on the survey to see more information about the data provider and its contact informations"
    ),

    p("Colors indicate the status of the survey:"),
    img(src = "LegSurvey.png", height = 100),

    h4("Contact us"),
    "If you see wrong or incomplete information, ",
    "please add an issue in the GitHub folder:",
    tags$a(
      href = "https://github.com/AquaAuma/TrawlSurveyMetadata/issues",
      "TrawlSurveyMetadata"
    ),

    p(" "),
    p(" "),
    "This work is licensed under the ",
    tags$a(href = "https://www.gnu.org/licenses/gpl-3.0", "GPLv3 license")
  )
)
