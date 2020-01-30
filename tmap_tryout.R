# Introduction to the R Tmap package
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# install and load necessary packages
install.packages('raster')
install.packages('tmap')
install.packages('sf')
install.packages('grid')
library(raster)
library(tmap)
library(sf)
library(grid)



# STEP I: Input Data
#----------------------------

# Load Data via GADM:
# country borders
gerBorder <- getData('GADM', country='DEU', level=0)
ger <- getData('GADM', country='DEU', level=1)

# elevation
gerElev <- getData('alt', country='DEU', mask=TRUE)


# SF object for later use:
gerSF <- st_as_sf(ger) # transform to a SF object
gerSF$area <- lwgeom::st_geod_area(gerSF_2) # calculate the area
gerSF$area <- units::set_units(gerSF$area, km^2) # set units to km^2

# STEP 2: Basic visualization
 #--------------------------------------------

tm_shape(ger)+ # to plot the spatial object
  tm_fill() # to define the layer style

# alternatives
tm_shape(ger)+
  tm_borders()

tm_shape(ger)+
  tm_fill()+
  tm_borders()

# -> also works with 
tm_shape(ger) + tm_polygons()


# STEP 3: Combine commands into one map object
#-----------------------------------------------

gerL0 <- tm_shape(gerBorder) + tm_polygons()
gerL0

# add another layer to it via tm_shape() + specifications (tm_raster)
ger2 <- gerL0+
  tm_shape(gerElev) + tm_raster(alpha = 0.8)

ger2

# aaand another -> layers get stacked one over the other, all elements modifying the
# preceding tm_shape until the next tm_shape is added
ger3 <- gerL0+
  tm_shape(gerElev) + tm_raster(alpha = 0.8)+
  tm_shape(ger) + tm_borders()

ger3


# Nice little extra:
# display multiple map objects next to each other

tmap_arrange(gerL1, ger2, ger3)


#STEP 4: Change the looks!
#-------------------------------------

# Change aesthetics with  constant values by giving specifications to the additional style elements

# fill colour
m1 <- tm_shape(ger) + tm_fill(col = 'green')
# also takes Hex codes (check out f.ex. http://colorbrewer2.org/) or alpha values
m2 <- tm_shape(ger) + tm_fill(col='#6e016b', alpha = .5)

# border colour
m3 <- tm_shape(ger) + tm_borders(col='red')
# line width
m4 <- tm_shape(ger) + tm_borders(lwd=3)
# line type
m5 <- tm_shape(ger) + tm_borders(lty=2)

# and of course you can combine them just as you like
m6 <- tm_shape(ger)+ 
  tm_fill(col='#4d9221', alpha = .7)+
  tm_borders(col ='blue', lwd=2, lty = 3)

tmap_arrange(m1,m2,m3,m4,m5,m6)


# STEP 5: Colour by field values
#------------------------------------------

ger_a <- tm_shape(gerSF)+
  tm_fill(col='area')+
  tm_borders()
ger_a


# adjust legend
tm_shape(gerSF)+
  # alter the title
  tm_polygons(col='area', title = expression('Area [km'^2*']'))+ 
  # position it outside the plot when it's too large
  tm_layout(legend.outside = TRUE, legend.outside.position = 'right') 




# STEP 6: Color settings
#--------------------------------------------

# Adjust color breaks
# Default: style = 'pretty' -> rounded to whole numbers and spaced evenly
# Check the style-argument for other options!

# by manual breaks or preferred number of breaks
breaks <- c(0,3,5,7)*10000

tm_shape(gerSF) + tm_polygons(col='area', breaks = breaks)+
  tm_layout(legend.outside = TRUE, legend.outside.position = 'right')

tm_shape(gerSF) + tm_polygons(col='area', n = 16)+
  tm_layout(legend.outside = TRUE, legend.outside.position = 'right')



# Adjust the colour palette

tm_shape(gerSF) + tm_polygons(col='area', palette='Blues') # single hues
tm_shape(gerSF) + tm_polygons(col='area', palette='viridis') # viridis: a group of perceptually-uniform and colour-blindness-friendly colour maps

tm_shape(gerSF) + tm_polygons(col='area', palette= c('#edf8fb','#b3cde3','#8c96c6','#88419d')) # vectors with colour values



# STEP 7: Map Layout
#----------------------------------------

# Add compass and scale bar to a map object
plain <- tm_shape(ger)+ tm_polygons()

plain2 <- plain+
  tm_compass(type='8star', position = c('left', 'bottom'), size = 2)+
  tm_scale_bar(breaks = c(0,50,100), text.size = .5, position = c('right', 'bottom'))
plain2

# Add map title
plain2 + tm_layout(title='Germany', title.position = c('center', 'top'), inner.margins = .07) # inner margins to give space to the layout elements


# Examples of predefined tmap styles
ger_a + tm_style('bw')+
  tm_layout(legend.outside = TRUE, legend.outside.position = 'right') # note that you have to put all manual layout adjustments after the style command

ger_a + tm_style('classic')+
  tm_layout(legend.outside = TRUE, legend.outside.position = 'right')

ger_a + tm_style('cobalt')


# STEP 8: Inset maps
#----------------------------------------
# Create a little inset map that shows where the actual big map is located

# Create an area of interest
# subset bavaria
bavaria <- ger[ger@data$NAME_1=='Bayern',]
bavaria_elev <- crop(gerElev, bavaria)

# Create elevation map of bavaria
aoi <- tm_shape(bavaria_elev) + tm_raster()+
  tm_shape(bavaria) + tm_borders()
aoi

extent <- st_as_sfc(st_bbox(bavaria_elev)) # create polygon from aoi extent

# create 'overview' map with extent of the aoi highlighted
inset <- tm_shape(gerBorder)+tm_polygons()+
  tm_shape(extent) + tm_borders(col='red', lwd=2)
inset

# And combine the two with a viewport (using viewport() from the grid package)
aoi
print(inset, vp=viewport(x=0.77, y=0.82, width = 0.3, height = 0.3)) # adjust the position with x and y



#STEP 9: Faceted Maps
#-----------------------------------------

# Load some input data
# world map in the package
data("World")

# populted places implemented in the package, altered beforehand
metro <- st_read('./metroThirty.shp')


# Plot a faceted map time series with the 30 most populated places on the globe
popPlaces <- tm_shape(World) + tm_polygons()+
  tm_shape(metro) + tm_dots(size = 'popMil')+
  tm_facets(by='year')

popPlaces


# animation also possible, but requires free tool ImageMagick



# Created after https://geocompr.robinlovelace.net/adv-map.html
# You can also check there for some more examples :)


