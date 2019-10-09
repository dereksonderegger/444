# Read in the Pulliam Airport Weather Information

library(tidyverse)
library(lubridate)
read.csv('./data-raw/Pulliam_Airport_Weather_Station.csv') %>%
  select(STATION, NAME, LATITUDE, LONGITUDE, ELEVATION,DATE,
         TMIN, TMAX, PRCP, SNOW) %>%
  mutate( DATE = DATE %>% as.character() %>% str_remove_all('-') ) %>%
  write_csv('./data-raw/Pulliam_Airport_Weather.csv')

