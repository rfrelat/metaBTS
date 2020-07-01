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

#Repeat on both side - done by the server
# library(sf)
# shape0 <- (st_geometry(st_as_sf(shp)))
# #shape1 <- (shape0+ c(360,90)) - c(0,90)
# shape1 <- shape0 + c(360,0)
# st_bbox(shape1)
# shape2 <- shape0 - c(360,0)
# st_bbox(shape2)
# range(shape1)
# 
# plot(shape0, col="black", xlim=c(-600, 600))
# plot(shape1, col="red", add=TRUE)
# plot(shape2, col="blue", add=TRUE)
# 
# shape3 <- c(shape0, shape1, shape2)
# shape4 <- sf::as_Spatial(shape3)
# shape<-spTransform(shape4, CRS("+init=epsg:4326"))
