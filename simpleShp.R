library(rgdal)

listshape <- list.files(".", pattern = "shp")
dateshape <- as.Date(substr(listshape, 10, 17), format="%d%m%Y")
lastshape <- listshape[which.max(dateshape)]
shape<-readOGR(dsn=lastshape, layer=gsub("\\.shp", "", lastshape))

library(rgeos) # for gSimplify
shapeH <- gSimplify(shape, tol = 0.01)
plot(shapeH)

# Create a spatial polygon data frame (includes shp attributes)
shp <- SpatialPolygonsDataFrame(shapeH, shape@data)


#Save the updated shapefile
name<-gsub(".shp", "_S", lastshape)
dir<-paste0("./", name, ".shp")
writeOGR(shp, dir,name, driver="ESRI Shapefile", overwrite_layer = TRUE)
