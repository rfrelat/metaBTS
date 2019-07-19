#Script to add dataset into the metadata shapefile (read by shiny app)
# last update : 19 July 2019
# author: Romain Frelat

today <- format(Sys.Date(), format="%d%m%Y")

#load the previous shapefile
require(rgdal)
require(raster)

#make sure to select the latest shapefile
shape<-readOGR(dsn="Metadata19072019.shp", layer="Metadata19072019")

#load new data with stations coordinate
tab <- read.csv("../NewData/AUS survey/metadataAUS.csv")

#if only one survey, add a new column with the survey name
tab$Survey<-"AUS"

#Create a list of polygons with the convex hull of stations
plist <- list()
tab$Survey <- as.factor(tab$Survey)
for (i in levels(tab$Survey)){
  subsa <- subset(tab, Survey==i)
  coo <- cbind(subsa$lon, subsa$lat)
  ch <- chull(coo)
  ch <- c(ch, ch[1])
  p <-  Polygon(coo[ch,])
  ps <-  Polygons(list(p),i)
  plist[[i]] <- ps
}
sps <-  SpatialPolygons(plist, proj4string = CRS(proj4string(shape)))

#Check if everything ok
pal <- rainbow(nlevels(tab$Survey))
par(mar=c(3,3,1,1))
plot(sps, col=pal)
require(mapdata)
map("world",col = "grey70", fill=TRUE, border=NA, add = TRUE)

#Compute the metadata
## Please be sure to change the name of the variable corresponding to:
## Year, Latitude, Longitude, Depth and Species (if any)
lunique <- function(x)length(unique(x))
newsurvey <- data.frame(
  "Survey"=levels(tab$Survey),
  "nbHauls"=as.numeric(tapply(tab$id, tab$Survey, lunique)),
  "minYear"=as.numeric(tapply(tab$year, tab$Survey, min)),
  "maxYear"=as.numeric(tapply(tab$year, tab$Survey, max)),
  "minLat"=as.numeric(tapply(tab$lat, tab$Survey, min)),
  "maxLat"=as.numeric(tapply(tab$lat, tab$Survey, max)),
  "minLong"=as.numeric(tapply(tab$long, tab$Survey, min)),
  "maxLong"=as.numeric(tapply(tab$long, tab$Survey, max)),
  "minDpth"=as.numeric(tapply(tab$depth, tab$Survey, min, na.rm=TRUE)),
  "maxDpth"=as.numeric(tapply(tab$depth, tab$Survey, max, na.rm=TRUE)),
  "nbTaxa"=NA, #as.numeric(tapply(tab$Species, tab$Survey, lunique))
  "Contact"=NA,
  "email"=NA,
  "link"="http://www.marlin.csiro.au/geonetwork/srv/eng/search#!253fa409-5f2b-2559-e053-08114f8c376e", 
  "Providr"="CSIRO O&A Hobart", 
  "Opn_ccs"="yes"
)
row.names(newsurvey) <- newsurvey$Survey
spdf <- SpatialPolygonsDataFrame(sps, data = newsurvey)

#Add new survey to existing one
updatedshp <- bind(shape, spdf)

#Check the new updated shapefile
#metadata
View(updatedshp@data)

#polygons
pal <- rainbow(nlevels(updatedshp$Survey))
par(mar=c(3,3,1,1))
plot(updatedshp, col=pal)
map("world",col = "grey70", fill=TRUE, border=NA, add = TRUE)

#Save the updated shapefile
dir<-paste0("./Metadata", today, ".shp") 
name<-paste0("Metadata", today)
writeOGR(updatedshp, dir,name, driver="ESRI Shapefile")

