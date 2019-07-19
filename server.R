library(dplyr)
library(tidyr)
library(leaflet)
library(rgdal)
library(DT)

#Get the latest shapefile
listshape <- list.files(".", pattern = "shp")
dateshape <- as.Date(substr(listshape, 9, 16), format="%d%m%Y")
lastshape <- listshape[which.max(dateshape)]
shape<-readOGR(dsn=lastshape, layer=gsub("\\.shp", "", lastshape))
#proj4string(shape)

# Cut out unnecessary columns
#shape@data<-shape@data#[,c(1,2)]

# transform to WGS884 reference system 
shape<-spTransform(shape, CRS("+init=epsg:4326"))

# Find the edges of our map
bounds<-bbox(shape)

# Get the income data 
# income_long<-read.csv("Data/income_long.csv")


server <- function(input, output, session){
  
  getDataSet<-reactive({
    
    # Get a subset of the income data which is contingent on the input variables
    # dataSet<-income_long[income_long$Year==input$dataYear & income_long$Measure==input$meas,]
    
    # Copy our GIS data
    # joinedDataset<-boroughs
    
    # Join the two datasets together
    # joinedDataset@data <- suppressWarnings(left_join(joinedDataset@data, dataSet, by="NAME"))
    
    # If input specifies, don't include data for City of London
    # if(input$city==FALSE){
    #   joinedDataset@data[joinedDataset@data$NAME=="City of London",]$Income=NA
    # }
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
    pal <- rainbow(nlevels(theData$Survey)) 
   
    prov <- ifelse(is.na(theData$link), as.character(theData$Providr), 
                   paste0("<a href= '", theData$link, "' target='_blank'>", theData$Providr, "</a>"))
    cont <- ifelse(is.na(theData$Contact), "", paste0("Contact: ", theData$Contact))

    # set text for the clickable popup labels
    borough_popup <- paste0("<strong>Survey: ", 
                            theData$Survey, 
                            "</strong><br>",
                            theData$nbHauls,
                            " hauls <br> ",
                            theData$nbTaxa, 
                            " taxa <br>",
                            "Year: ",
                            as.character(theData$minYear),
                            " - ",
                            as.character(theData$maxYear),
                            "<br> Depth: ",
                            as.character(round(theData$minDpth)),
                            " - ",
                            as.character(round(theData$maxDpth)), 
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
                  fillColor = pal, 
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
