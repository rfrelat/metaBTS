# library(dplyr)
# library(tidyr)

# library(DT)
library(sf)
library(leaflet)

#Get the latest shapefile
listshape <- list.files(".", pattern = "shp")
simpleshape <- listshape[grep("_S.shp", listshape)]
shape <- sf::st_read(simpleshape, quiet = TRUE)

# Add right and left polygons
shapeE <- shape
st_geometry(shapeE) <- st_geometry(shapeE) + c(360, 0)
st_crs(shapeE) <- st_crs(shape)

shapeW <- shape
st_geometry(shapeW) <- st_geometry(shape) - c(360, 0)
st_crs(shapeW) <- st_crs(shape)

shape_all <- rbind(shape, shapeE, shapeW)

# Find the edges of our map
bounds <- st_bbox(shape_all)
centre <- c(mean(bounds[c("xmin", "xmax")]), mean(bounds[c("ymin", "ymax")]))

# Colour per open-access status (same colours as the original app)
status_cols <- c(
  "Publicly available" = "blue",
  "Partly publicly available" = "orange",
  "Available upon request" = "purple",
  "Not publicly available" = "red",
  "Incomplete metadata" = "black"
)

# Draw the most open surveys last so they sit on top
draw_order <- order(
  match(shape_all$Opn_ccs, rev(names(status_cols))),
  na.last = TRUE
)
shape_all <- shape_all[draw_order, ]

fill_col <- unname(status_cols[as.character(shape_all$Opn_ccs)])
# fill_col[is.na(fill_col)] <- "grey70"

first_year <- ifelse(
  is.na(shape_all$First_year),
  as.character(shape_all$minYear),
  as.character(shape_all$First_year)
)

provider <- ifelse(
  is.na(shape_all$link),
  as.character(shape_all$Providr),
  paste0(
    "<a href='",
    shape_all$link,
    "' target='_blank' rel='noopener'>",
    shape_all$Providr,
    "</a>"
  )
)

contact <- ifelse(
  is.na(shape_all$Contact),
  "",
  paste0("<br>Contact: ", shape_all$Contact)
)

min_depth <- round(as.numeric(as.character(shape_all$minDpth)))
max_depth <- round(as.numeric(as.character(shape_all$maxDpth)))

popup_txt <- paste0(
  "<strong>Survey: ",
  shape_all$Survey,
  "</strong><br>",
  shape_all$nbHauls,
  " stations<br>",
  "Region: ",
  shape_all$Area,
  "<br>",
  "Years: ",
  first_year,
  " - ",
  as.character(shape_all$maxYear),
  "<br>",
  "Depth: ",
  min_depth,
  " - ",
  max_depth,
  " m<br>",
  "<strong>Open access: ",
  shape_all$Opn_ccs,
  "</strong><br>",
  "Provider: ",
  provider,
  contact
)

server <- function(input, output, session) {
  # Due to use of leafletProxy below, this should only be called once
  output$Map <- renderLeaflet({
    leaflet(shape_all) %>%
      addTiles() %>%
      addPolygons(
        fillColor = fill_col,
        fillOpacity = 0.8,
        color = "#BDBDC3",
        weight = 1,
        popup = popup_txt,
        highlightOptions = highlightOptions(
          weight = 3,
          color = "#333333",
          fillOpacity = 0.9,
          bringToFront = TRUE
        )
      ) %>%
      addLegend(
        position = "bottomright",
        colors = unname(status_cols),
        labels = names(status_cols),
        title = "Open access",
        opacity = 0.8
      ) %>%
      # Centre the map in the middle of our co-ordinates
      setView(lng = centre[1], lat = centre[2], zoom = 2)
  })
}
