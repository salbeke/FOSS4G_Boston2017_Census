##################################################
# Mapping American Community Survey with R
# Lee Hachadoorian, Temple University
# Lee.Hachadoorian@temple.edu / Lee.Hachadoorian@gmail.com
# FOSS4G 2017 - Boston, MA
##################################################
# Preparation for downloading and mapping ACS data
##################################################

##################################################
# Windows Instructions
##################################################
pkgs = c("tidyverse", "tidycensus", "tmap", "acs")
install.packages(pkgs, dependencies = TRUE)

# For Win10, there appears to be a bug in tigris 
# 0.5.1+, a tidycensus dependency. If the following 
# code produces an error, please downgrade tigris as
# indicated. The developer believes that this does 
# NOT apply to versions earlier than Win10, but I
# recommend testing. The developer also intends to 
# have this bug fixed in tigris 0.6.

# TEST
library(tigris)
tmp = counties(state = "DE", refresh = TRUE)

# FAILURE
install.packages(devtools)
install_version("tigris", version = "0.5")
# Rerun test

# SUCCESS
rm(tmp)

##################################################
# OSGeo-Live 11.0 Instructions
##################################################
# NOTE: a/o Aug 10, 2017, this will force an upgrade
# to GDAL which will uninstall QGIS 2.14. If you 
# want to use QGIS for another workshop, you will have
# to install QGIS 2.18.
##################################################

# Using the cran2deb4ubuntu repository (recommended)

# Run in Terminal:
#   sudo add-apt-repository ppa:marutter/c2d4u
#   sudo apt-get update
#   sudo apt-get install r-cran-tidyverse r-cran-tmap r-cran-acs

# Run in R:
install.packages("tidycensus", dependencies = FALSE)

# Using CRAN repositories - This requires several 
# Linux dependencies to be installed, followed by
# installing the R packages in R. It is therefore
# somewhat more complex to accomplish, and will also
# be slower because packages will be compiled from
# source.

# Run in Terminal:
#   sudo apt-get install libv8-dev libpng-dev libudunits2-dev libssl-dev libgdal-dev

# Run in R:
pkgs = c("tidyverse", "tidycensus", "tmap", "acs")
install.packages(pkgs, dependencies = TRUE)

###################################################
# Set up your Census API Key
###################################################

# Get Census API Key: http://api.census.gov/data/key_signup.html
# Check your email and activate the key

# In order to avoid having to include the key in
# individual function calls, add it permanently to
# your R environment.

# NOTES:
# 1. This needs to be done once (but only once) for each computer. 
# 2. You can use the same key on multiple computers.

library(tidycensus)
census_api_key("6b2af3e30458626b0afe2170e4333a8af01b57c5", install = TRUE) 
readRenviron("~/.Renviron")
Sys.getenv("CENSUS_API_KEY") # <--This is just a check
