library(tidycensus)
library(tidyverse)
library(tmap)
library(stringr)

options(tigris_use_cache = TRUE)

# Find variables
#This is a list of available variables as a DF. Pretty handy list
vars2015 <- load_variables(2015, "acs5", cache = TRUE)
View(vars2015)
#Download a csv, called a subject table. Collection of related data
url <- "ftp://ftp2.census.gov/programs-surveys/acs/summary_file/2015/documentation/user_tools/ACS_5yr_Seq_Table_Number_Lookup.txt"
download.file(url, "ACS_5yr_Seq_Table_Number_Lookup.csv")

# Overture
#Get data by county, data are structured hierarchically
#Zip codes are not really polygons. 
mass_counties <- get_acs(geography = "county", variables = "B19013_001", endyear = 2015, output = "wide", state = "MA", geometry = TRUE)
#Extract only the county name because it looks nicer and we are only in MA
mass_counties$NAME = str_replace(mass_counties$NAME, " County, Massachusetts", "")

#Create a plot of median income by county
ggplot(mass_counties, aes(x = NAME, y = B19013_001E)) +
  geom_col(width = 0.5) +
  xlab("County") + ylab("Median Income") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
#create a  spatial map of counties with labels
tm_shape(mass_counties) +
  tm_polygons() +
  tm_text("NAME")
#Same map, but filled with median income
tm_shape(mass_counties) +
  tm_polygons(col = "B19013_001E") +
  tm_text("NAME")
#Not an informative representation of median income
tm_shape(mass_counties) +
  tm_polygons(col = "beige") +
  tm_bubbles(size = "B19013_001E", scale = 5, alpha = 0.6,
             col = "red", title.size = "Median Income")

#Census done every 10 years, long form pre-2000, now is the short form
#ACS completed annually, same as long form, 1/100 people, 1 year survey, 5 year average. 1 year data nust yse geographies > 60K
#so that accidental disclosure doesn't happen
# Getting ACS Data
#Build a list of variables by pasting come data together
commute_vars <- paste("B08301", str_pad(string = 1:21, width = 3, side = "left", pad = "0"), sep = "_")
mass_commute <- get_acs(geography = "county", variables = commute_vars, endyear = 2015, output = "tidy", state = "MA", geometry = TRUE)
mass_commute$NAME <- str_replace(mass_commute$NAME, " County, Massachusetts", "")

# Extract drivers (2), transit riders (10), and bikers (18)
commute_filter <- c("B08301_002", "B08301_010", "B08301_018")
# More verbose, but can makes longer list easier:
commute_filter <- paste("B08301", str_pad(c(2, 10, 18), 3, "left", "0"), sep = "_")

#dplyr piping method, filter rows of data, plot it, has to be named variable because that is a column in mass_commute
mass_commute %>%
  filter(variable %in% commute_filter) %>%
  ggplot(aes(x = NAME, y = estimate, fill = variable)) +
  geom_col() +
  xlab("County") + ylab("count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
#100% fill
mass_commute %>%
  filter(variable %in% commute_filter) %>%
  ggplot(aes(x = NAME, y = estimate, fill = variable)) +
  geom_col(position = "dodge") +
  xlab("County") + ylab("count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

mass_commute %>%
  filter(variable %in% commute_filter) %>%
  ggplot(aes(x = NAME, y = estimate, fill = variable)) +
  geom_col(position = "fill") +
  xlab("County") + ylab("proportion") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# This will be slow because polygons will be overplotted
tm_shape(mass_commute) +
  tm_polygons() +
  tm_text("NAME")

# Get county geometries again. Include MHI.
mass_counties <- get_acs(geography = "county", variables = c("B19013_001", commute_vars), endyear = 2015, output = "wide", 
                         state = "MA", geometry = TRUE)

mass_counties$NAME <- str_replace(mass_counties$NAME, " County, Massachusetts", "")

# mass_counties_data = mutate(
#   mass_counties,
#   pct_drive = 100 * B08301_002E / B08301_001E,
#   pct_transit = 100 * B08301_010E / B08301_001E,
#   pct_bike = 100 * B08301_016E / B08301_001E
# )

#
mass_counties$pct_drive <- 100 * (mass_counties$B08301_002E / mass_counties$B08301_001E)
mass_counties$pct_transit <- 100 * (mass_counties$B08301_010E / mass_counties$B08301_001E)
mass_counties$pct_bike <- 100 * (mass_counties$B08301_016E / mass_counties$B08301_001E)

tm_shape(mass_counties) +
  tm_polygons(
    c("pct_drive", "pct_transit"), title = c("Percent Car Commuters", "Percent Transit Commuters")
  )

