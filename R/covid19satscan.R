# prep satscan files for covid data
load("data/saves/daily_window4_long.rds")
library(rsatscan)
library(dplyr)

# match the structure of data frames given in `rsatscan` examples
covidcas = covid.daily.window4 %>% 
    transmute(fips = FIPS, cases = cases, date = date)
covidgeo = covid.daily.window4 %>%
    transmute(fips = FIPS, lat = Lat, long = Long_)
covidpop = covid.daily.window4 %>% 
    transmute(fips = FIPS, year = 20, population = population)

# create files to use in SaTScan program

# negative cases break SaTScan, need a better way to handle these
# (presumed) reporting errors
negative.index = covidcas$cases < 0
covidcas$cases[negative.index] = 0

# check that no rows will throw an error for SaTScan
sum(is.na(covidgeo$long))
sum(covidcas$cases < 0)

# can run SaTScan from gui app using the three files saved below
dir = "data/satscan/covid19"
write.cas(as.data.frame(covidcas), dir, "covid")
write.geo(as.data.frame(covidgeo), dir, "covid")
write.pop(as.data.frame(covidpop), dir, "covid")



