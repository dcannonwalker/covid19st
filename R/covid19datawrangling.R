# general data wrangling for both SaTScan and ESS methods
# need `dplyr` for pipe operator 
library(dplyr)
# need `tidyr` and `sf` installed, but not necessarily loaded 
# library(tidyr) 
# library(sf)

# county data and shp file from us census 2019, covid data from JHU github
# downloaded 1/28/2022
county = sf::st_read("data/raw/tl_2019_us_county/tl_2019_us_county.shp")
covid = read.csv("data/raw/time_series_covid19_confirmed_US.csv")
county.pop = read.csv("data/raw/co-est2019-alldata.csv", 
                      colClasses = "character") %>%
    dplyr::select(STATE, COUNTY, STNAME, CTYNAME, POPESTIMATE2019)

# make FIPS column that matches the `covid` dataframe 
county = dplyr::mutate(county,
                       FIPS = as.numeric(paste0(as.integer(STATEFP),
                                                COUNTYFP)))
county.pop = dplyr::transmute(county.pop,
                              FIPS = as.numeric(paste0(as.integer(STATE), 
                                                       COUNTY)),
                              population = POPESTIMATE2019,
                              state = STNAME,
                              county = CTYNAME
)
filter(county.pop, is.na(population))
# covid counts are cumulative, but we need daily cases
covid.daily = covid

for(i in ((ncol(covid) - 1):12)) {
    covid.daily[, (i + 1)] = covid[, (i + 1)] - covid[, i]
}

# the paper uses 4 time windows, the largest contains all the others 
covid.daily.window4 = covid.daily %>% dplyr::select(1:11, X1.22.20:X5.20.20)

# the `covid` and `county` include PR counties, etc., that are not 
# included in `county.pop`, `county.pop` includes a row
# for each state that the other two dfs do not
covid.daily.window4 = 
    sf::st_drop_geometry(dplyr::left_join(county, covid.daily.window4)) %>%
    dplyr::right_join(county.pop) %>% filter(!is.na(Lat))

covid.daily.window4 %>% dplyr::filter(is.na(Lat))
# need to lengthen the data to have single date column
covid.daily.window4.long = 
    covid.daily.window4 %>% tidyr::pivot_longer(cols = starts_with("X"), 
                                                names_to = "date",
                                                names_prefix = "X",
                                                values_to = "cases") %>%
    dplyr::mutate(date = as.Date(date, format = "%m.%d.%y"))

save(covid.daily.window4, file = "data/saves/daily_window4_wide.rds")
save(covid.daily.window4.long, file = "data/saves/daily_window4_long.rds")
