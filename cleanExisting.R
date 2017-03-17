library(pdftools)
library(xlsx)
library(sp)
library(rgdal)

setwd('~/Dropbox/hawaiiDimensions/gradients')

## ===================================
## read in and clean-up Rosie's points
## ===================================


rgg <- pdf_text('existing/Hawaii Nov 2016 Gillespie Roderick sample sites low resolution.pdf')


## extract lat and lon

latStart <- regexpr('N2.*°|N1.*°', rgg)
lonStart <- regexpr('W15.*°|W16', rgg)
lonEnd <- gregexpr("'", rgg)
lonEnd <- sapply(1:length(lonEnd), function(i) {
    lonEnd[[i]][lonEnd[[i]] > lonStart[i]][1]
})

lat <- substring(rgg, latStart + 1, lonStart - 1)
lon <- substring(rgg, lonStart + 1, lonStart + 12)
nsite <- sum(lat != '')
lon <- lon[lat != '']
lat <- lat[lat != '']


## clean up lat and lon

x <- c(lon, lat)
x <- strsplit(x, '° ')
x <- sapply(x, function(xx) {
    as.numeric(xx[1]) + as.numeric(gsub('[^0-9|.]', '', xx[2])) / 60
})

rggLonLat <- matrix(x, nrow = nsite)
rggLonLat[, 1] <- -rggLonLat[, 1]


## ====================================
## read in and clean-up Henrik's points
## ====================================

hk <- read.xlsx('existing/sampling April 2016.xlsx', sheetIndex = 1)
head(hk)
hkLonLat <- hk[, c('longitude..W..DEG', 'latitude..N..DEG')]
hkLonLat <- hkLonLat[!is.na(hkLonLat[, 1]), ]
hkLonLat[, 1] <- -hkLonLat[, 1]


## =====================
## combine and write out
## =====================

rggLonLat <- data.frame(rggLonLat)
names(rggLonLat) <- c('lon', 'lat')
rggLonLat$site <- paste('rgg', 1:nrow(rggLonLat), sep = '')

hkLonLat <- data.frame(hkLonLat)
names(hkLonLat) <- c('lon', 'lat')
hkLonLat$site <- paste('hk', 1:nrow(hkLonLat), sep = '')

LonLat <- rbind(rggLonLat, hkLonLat)
LonLat <- SpatialPointsDataFrame(LonLat[, 1:2], data = LonLat[, 3, drop = FALSE], 
                                 proj4string = CRS('+proj=longlat +ellps=WGS84 +towgs84=0,0,0,0,0,0,0 +no_defs'))

writeOGR(LonLat, 'existing', 'existing', driver = 'ESRI Shapefile', overwrite_layer = TRUE)
