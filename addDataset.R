#Script to add dataset into the metadata shapefile (read by shiny app)
# last update : 18 July 2019
# author: Romain Frelat

today <- format(Sys.Date(), format="%d%m%Y")

#load the previous shapefile
require(rgdal)
require(raster)

#make sure to select the latest shapefile
shape<-readOGR(dsn="Metadata_15102019.shp", layer="Metadata_15102019")

# O. Nansen - FAO -------------------------------
tab <- read.table("../MetaBTS/Nansen_BT_trawl_stations_meta_1975-2018.txt", 
                  sep="\t",  header=TRUE, fileEncoding="UTF-8-BOM")

tab$Year<-format(as.Date(tab$date, format = "%d.%m.%Y"), "%Y")
tab <- subset(tab, Year>2000)

#Create a list of polygons with the convex hull of stations
plist <- list()
tab$Survey <- as.factor("Nansen")
for (i in levels(tab$Survey)){
  subsa <- subset(tab, Survey==i)
  coo <- cbind(subsa$startlondeg, subsa$startlatdeg)
  coo <- coo[!duplicated(coo),]
  coo <- coo[complete.cases(coo),]
  #test resolution
  z <- ahull(coo, alpha=resch)
  y <- ah2sp(z, name=i, rnd = rndch)
  plist[[i]] <- y
}
sps <-  SpatialPolygons(plist, proj4string = CRS(pro))

#Check if everything ok
pal <- rainbow(nlevels(tab$Survey))
par(mar=c(3,3,1,1))
plot(sps, col=pal, border=pal)
map("world",col = "grey70", fill=TRUE, border=NA, add = TRUE)


tab$id <- paste(tab$survey, tab$station, tab$date, sep="_")

#Compute the metadata
newsurvey <- data.frame(
  "Survey"=levels(tab$Survey),
  "nbHauls"=as.numeric(tapply(tab$id, tab$Survey, lunique)),
  "minYear"=as.numeric(tapply(tab$Year, tab$Survey, min)),
  "maxYear"=as.numeric(tapply(tab$Year, tab$Survey, max)),
  "minLat"=as.numeric(tapply(tab$startlatdeg, tab$Survey, min, na.rm=TRUE)),
  "maxLat"=as.numeric(tapply(tab$startlatdeg, tab$Survey, max, na.rm=TRUE)),
  "minLong"=as.numeric(tapply(tab$startlondeg, tab$Survey, min, na.rm=TRUE)),
  "maxLong"=as.numeric(tapply(tab$startlondeg, tab$Survey, max, na.rm=TRUE)),
  "minDpth"=as.numeric(tapply(tab$bottomdepthstart, tab$Survey, min, na.rm=TRUE)),
  "maxDpth"=as.numeric(tapply(tab$bottomdepthstart, tab$Survey, max, na.rm=TRUE)),
  "Contact"="Ines Dias Bernardes",
  "email"="ines.dias.bernardes@hi.no",
  "link"=NA, 
  "Providr"="FAO / IMR / Country representatives", 
  "Opn_ccs"=FALSE,
  "Div_sps"=TRUE,
  "Length"=FALSE
)
row.names(newsurvey) <- newsurvey$Survey
nansenshp <- SpatialPolygonsDataFrame(sps, data = newsurvey)

#Add new survey to existing one
updatedshp <- bind(shape, nansenshp)

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



#From J Thorson
z <- ahull(DF[,c('Lat','Lon')], alpha=.1)
df <- as.data.frame(z$ashape.obj$edges)[,3:6]
segments(df[,1], df[,2], df[,3], df[,4])
