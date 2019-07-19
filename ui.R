library(shinydashboard)
library(leaflet)
library(DT)

header<-dashboardHeader(title="Bottom Trawl Surveys - Metadata", titleWidth = 450)

body<-dashboardBody(
  fluidRow(
    box(width = NULL, solidHeader = TRUE,
        leafletOutput("Map", height=400)
    )
    # column(width = 10,
    #        box(width = NULL, solidHeader = TRUE,
    #            leafletOutput("Map", height=400)
    #        )#,
    #        #box(width=NULL,
    #        #    dataTableOutput("Table")
    #        #)
    # )
    )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)