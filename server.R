library(dplyr)
library(tidyr)
library(leaflet)
library(rgdal)
library(DT)

#Get the latest shapefile
listshape <- list.files(".", pattern = "shp")
simpleshape <- listshape[grep("_S.shp", listshape)]
# dateshape <- as.Date(substr(listshape, 10, 17), format="%d%m%Y")
# lastshape <- listshape[which.max(dateshape)]
shape<-readOGR(dsn=simpleshape, layer=gsub("\\.shp", "", simpleshape))
#proj4string(shape)

# Add right and left polygons
shape0 <- (st_geometry(st_as_sf(shape)))
shapeE <- shape0 + c(360,0)
shapeW <- shape0 - c(360,0)
shape3 <- c(shape0, shapeE, shapeW)
shape3 <- sf::as_Spatial(shape3)

newdf <- rbind(shape@data, shape@data, shape@data)
row.names(newdf) <- names(shape3)
shape3 <- SpatialPolygonsDataFrame(shape3, newdf)
# transform to WGS884 reference system 
shape<-spTransform(shape3, CRS("+init=epsg:4326"))

# Find the edges of our map
bounds<-bbox(shape)

server <- function(input, output, session){
  
  getDataSet<-reactive({
    subDataset <- shape
  })
  
  # Due to use of leafletProxy below, this should only be called once
  output$Map<-renderLeaflet({
   
      leaflet() %>%
      addTiles() %>%
      
      # Centre the map in the middle of our co-ordinates
      setView(mean(bounds[1,]),
              mean(bounds[2,]),
              zoom=2 # set to 2
      )
  })
  
  
  
  observe({
    theData<-getDataSet() 
    
    # colour palette mapped to data
    colOA <- list("Publicly available" = "blue",
                  "Partly publicly available" = "orange",
                  "Available upon request" = "purple",
                  "Not publicly available"= "red",
                  "Incomplete metadata"="black")
    
    oafac <- factor(theData$Opn_ccs, levels = rev(names(colOA)), 
                    ordered = TRUE)
    shapeOr <- order(oafac)
    theData <- theData[shapeOr, ]
    theData@plotOrder <- 1:length(theData)
    
    oa <- unlist(colOA[as.character(theData$Opn_ccs)])
    names(oa) <- NULL
    
    prov <- ifelse(is.na(theData$link), as.character(theData$Providr), 
                   paste0("<a href= '", theData$link, "' target='_blank'>", theData$Providr, "</a>"))
    cont <- ifelse(is.na(theData$Contact), "", paste0("Contact: ", theData$Contact))

    # set text for the clickable popup labels
    borough_popup <- paste0("<strong>Survey: ", 
                            theData$Survey, 
                            "</strong><br>",
                            theData$nbHauls,
                            " stations <br> ",
                            "Region: ",
                            as.character(theData$Area),
                            "<br> Year: ",
                            as.character(theData$minYear),
                            " - ",
                            as.character(theData$maxYear),
                            "<br> Depth: ",
                            as.character(round(as.numeric(as.character(theData$minDpth)))),
                            " - ",
                            as.character(round(as.numeric(as.character(theData$maxDpth)))), 
                            "m <br><strong>Open access: ", 
                            theData$Opn_ccs, 
                            "</strong><br>",
                            "Provider: ",
                            prov, "<br>",
                            cont)    
    # If the data changes, the polygons are cleared and redrawn, however, the map (above) is not redrawn
    leafletProxy("Map", data = theData) %>%
      clearShapes() %>%
      addPolygons(data = theData,
                  fillColor = oa, 
                  fillOpacity = 0.8, 
                  color = "#BDBDC3", 
                  weight = 2,
                  popup = borough_popup)  
  })
  
  # table of results, rendered using data table
  # output$Table <- renderDataTable(datatable({
  #   dataSet<-getDataSet()
  #   dataSet<-dataSet@data#[,1:10] # Just get name and value columns
  #   #names(dataSet)<-c("Borough",paste0(input$meas," income") )
  #   dataSet
  #   }#,
  # )
    #options = list(lengthMenu = c(5, 10, 33), pageLength = 5))
  #)
    
}
