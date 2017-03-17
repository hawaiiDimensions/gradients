library(sp)
library(rgdal)

setwd('~/Dropbox/hawaiiDimensions/gradients')

ff <- list.files('.', pattern = '.kml')

allPnts <- lapply(ff, function(f) {
    x <- readOGR(f, f)
    pnts <- coordinates(x)[[1]][[1]]
    out <- SpatialPointsDataFrame(pnts, 
                                  data = data.frame(name = paste(gsub('.kml', '', f), 
                                                                 formatC(1:nrow(pnts), 
                                                                         width = 2, 
                                                                         format = 'd', 
                                                                         flag = '0'), 
                                                                 sep = '_')), 
                                  proj4string = CRS(proj4string(x)))
    
    return(out)
})

allPnts <- do.call(rbind, allPnts)

writeOGR(allPnts, 'gps/ageTransect.gpx', layer='waypoints', driver='GPX')
