rm(list=ls())

library(itcSegment)
library(rgdal)
library(raster)
library(dplyr)
library(sp)
library(visualraster)
library(reshape2)

#epsg: 32611!!!!!!

# impoort raster
chm <- raster("../inputs/CHM_SJER.tif")
vegData <- read.csv("../inputs/fieldData.csv")
sjer.plots <- readOGR(dsn = '../inputs/PlotCentroids/SJERPlotCentroids_Buffer.shp')
plot.names <- read.csv('../inputs/plot_list.csv')
i <- 1
ww <- 50
epsg <- 32611
res <- spTransform(sjer.plots, CRS(paste("+init=epsg:", epsg, sep = "")))
centroids <- cbind(sjer.plots@data$northing, sjer.plots@data$easting)
crs(chm) <- (paste("+init=epsg:", epsg, sep = ""))

pos_trees <- data.frame(vegData$tagID, vegData$plotID, vegData$E, vegData$N)
colnames(pos_trees) <- c("tagID", "plotID", "E", "N")
p.foo <- list()
link <- NA
for(i in 1: dim(plot.names)[1]){
  
  yPlus <- centroids[i,2]+ww
  xPlus <- centroids[i,1]+ww
  yMinus <- centroids[i,2]-ww
  xMinus <- centroids[i,1]-ww
  
  ## Create the clipping polygon
  CP <- as(extent( yMinus, yPlus, xMinus, xPlus), "SpatialPolygons")
  proj4string(CP) <- CRS(paste("+init=epsg:", epsg, sep = ""))
  
  #check which trees are in the plot
  temp.trees <- pos_trees[pos_trees$plotID==as.character(plot.names[i,1]),]
  tree.location <- SpatialPointsDataFrame(temp.trees[,3:4],temp.trees, proj4string =  
                                            CRS(paste("+init=epsg:", epsg, sep = "")))   # assign a CRS 
  ## Clip the map
  foo <- crop(chm, CP)
  itc.plot <- itcIMG(imagery = foo, epsg = epsg, searchWinSize = 9)
  plot(foo)
  plot(itc.plot, add = T)
  plot(tree.location, add =T)
  
  itc.plot@data$poly.ID <- 1:nrow(itc.plot) 
  itc.plot@data$plot.ID <- as.character(plot.names[i,1])
  
  a.data <- over(tree.location, itc.plot)
  tree.location$treeID <- a.data$poly.ID
  tree.location$treeID
  lookup <- cbind(a.data,   tree.location$tagID)
  if(all(is.na(link))){
    link <-lookup
  }else{
    link <- rbind(link, lookup)
  }
  p.foo[i] <-Polygon((itc.plot))
  crownSpectra <- extract(foo, itc.plot)
  cr.data.extract <- melt(crownSpectra)
}
write.csv(link, '../outputs/which_crown.csv')
write.csv(cr.data.extract, '../outputs/featuresPerCrown.csv')

# ps <- lapply(p.foo, Polygon)
# # add id variable
# p1 <- lapply(seq_along(ps), function(i) Polygons(list(ps[[i]]), 
#                                                  ID = as.character(plot.names[i,1]) ))
# # create SpatialPolygons object
# my_spatial_polys <- SpatialPolygons(p1, proj4string=CRS(paste("+init=epsg:", epsg, sep = "")))
# plot(my_spatial_polys)
