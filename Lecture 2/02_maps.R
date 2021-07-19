########################################
# Economics of distribution: Maps #
########################################

# Libraries
# set the library with the packages we use
library(ggplot2)
library(tidyverse)
library(sf)
library(purrr)
library(tidyverse)
library(ggrepel)
library(haven)
library(viridisLite)

# Folder Structure
wd           <- list()
wd$root      <- "G:/Mi unidad/Teaching Assistant/TA-Economics of distribution & inequality/"
wd$data      <- paste0(wd$root,"03_data/")
wd$raw       <- paste0(wd$data,"01_raw/")
wd$codes     <- paste0(wd$data,"02_codes/")
wd$cleaned   <- paste0(wd$data,"03_cleaned/")
wd$analysis  <- paste0(wd$data,"04_analysis/")
wd$results   <- paste0(wd$data,"05_results/")

# Call the shapefile

peru_d <- st_read(paste0(wd$raw, "INEI_departamental/department.shp"))

#Remove irrelevant objects of the list
peru_d <- peru_d[-11:-13]

peru_d <- peru_d %>% mutate(centroid = map(geometry, st_centroid), 
                            coords = map(centroid, st_coordinates), 
                            coords_x = map_dbl(coords, 1), coords_y = map_dbl(coords, 2))

ggplot(data = peru_d) +
  geom_sf(fill="skyblue", color="black", alpha = 0.4) + 
  geom_text_repel(mapping = aes(coords_x, coords_y, label = NOMBDEP), size = 2.25)

gini <- read_stata(paste0(wd$cleaned,"gini_regional.dta"))
gini <- spread(gini, key = year, value = gini)
names(gini)[1] <- "OBJECTID"
names(gini)[2] <- "gini2019"
names(gini)[3] <- "gini2020"


#Combine two datasets
peru_datos <- peru_d %>%
  left_join(gini)

#Income distribution in 2019
ggplot(peru_datos) +
geom_sf(aes(fill=gini2019))+
labs(title = "Índice de Gini por departamento (2019)",
       caption = "Fuente: Enaho (2019)
       Elaboración: @rmcondor",
       x="Longitud",
       y="Latitud")+
geom_text_repel(mapping = aes(coords_x, coords_y, label = NOMBDEP), size = 2.25)+
scale_fill_viridis_c(option = "mako", guide_legend(title = "Índice de Gini"))
ggsave(paste0(wd$analysis,"ginimap2019.png"))

#Income distribution in 2019
ggplot(peru_datos) +
  geom_sf(aes(fill=gini2020))+
  labs(title = "Índice de Gini por departamento (2020)",
       caption = "Fuente: Enaho (2020)
       Elaboración: @rmcondor",
       x="Longitud",
       y="Latitud")+
  geom_text_repel(mapping = aes(coords_x, coords_y, label = NOMBDEP), size = 2.25)+
  scale_fill_viridis_c(option = "mako", guide_legend(title = "Índice de Gini"))
ggsave(paste0(wd$analysis,"ginimap2020.png"))

