library(dplyr)
library(tidyr)
library(lubridate)
library(weathermetrics)
library(gdata)

data <- read.table('./Flagstaff_Temp_Modified.csv', header=TRUE, sep=',') %>%
  mutate(DATE = ymd(DATE),
         Year = year(DATE),
         Month = month(DATE),
         Day = day(DATE),
         TMAX = celsius.to.fahrenheit(TMAX/10)) %>%
  select(Year, Month, Day, TMAX) %>%
  group_by(Year, Month) %>%
  spread(key=Day, value=TMAX)

write.csv(data, file='FlagMaxTemp.csv')

