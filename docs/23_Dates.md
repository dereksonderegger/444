# Dates and Times




```r
library(tidyverse)
library(lubridate)
```

Dates within a computer require some special organization because there are several competing conventions for how to write a date (some of them more confusing than others) and because the sort order should be in the order that the dates occur in time.

One useful tidbit of knowledge is that computer systems store a time point as the number of seconds from set point in time, called the epoch. So long as you always use the same epoch, you doesn't have to worry about when the epoch is, but if you are switching between software systems, you might run into problems if they use different epochs. In R, we use midnight on Jan 1, 1970. In Microsoft Excel, they use Jan 0, 1900. 

Base R has a set powerful and flexible functions converting character strings into Date/Time objects. A great reference for the notation for specifying Date/Time is the help file for `strptime`. These functions require to specifying the format using a relatively complex set of rules. For example `%y` represents the two digit year, `%Y` represents the four digit year, `%m` represents the month, but `%b` represents the month written as Jan or Mar. These formats are very specific and easily get tripped up by variations such as using `/` instead of `-`.


```r
# Why does base R force me to get the separating character correct?
as.Date(c('09-4-2004', '09/04/2004'), format='%m-%d-%Y')
```

```
## [1] "2004-09-04" NA
```

Furthermore doing any math with dates is challenging because day-light savings time, leap days and leap seconds make it so that 1 year is not always $365$ days and 1 day is not always $60*60*24=86400$ seconds. So there is conceivably a difference between adding 1 year to a date and adding 365 days (or $31,536,000$ seconds).

Dr Wickham and his then PhD student Dr Grolemund introduced the `lubridate` package to address the need for a robust set of input functions that don't require exact specification date separation characters and to allow for arithmetic in either a person-centric or second-centric fashion.

## Creating Date and Time objects

R gives several mechanism for getting the current date and time.

```r
# base::Sys.Date()     # Today's date
# base::Sys.time()     # Current Time and Date 
lubridate::today()   # Today's date
```

```
## [1] "2020-11-04"
```

```r
lubridate::now()     # Today's Date and Time
```

```
## [1] "2020-11-04 16:50:31 MST"
```

If we have all of our date information as several numerical columns and we can specify `year`, `month`, and `day`, the easiest way to create a date is to use the function `make_date()` or `make_datetime()`

```r
make_date(year=2020, month=10, day=31)  # Halloween!
```

```
## [1] "2020-10-31"
```

```r
data.frame(Year_Col=rep(2020, 5), Month_Col=10, Day_col=1:5) %>%
  mutate(date = make_date(year = Year_Col, month=Month_Col, day=Day_col))
```

```
##   Year_Col Month_Col Day_col       date
## 1     2020        10       1 2020-10-01
## 2     2020        10       2 2020-10-02
## 3     2020        10       3 2020-10-03
## 4     2020        10       4 2020-10-04
## 5     2020        10       5 2020-10-05
```



However, we often need to create a `Date` or `DateTime` object from a character string that has all the information, but possibly mixed up in the ordering. We need to take a string or number that represents a date and tell the `lubridate` how to figure out which bits are the year, which are the month, and which are the day. The lubridate package uses the following functions:

+--------------------------+-----+-------------------------------+
|   Common Orders          |     |    Uncommon Orders            |
+==========================+=====+===============================+
| `ymd()`  Year Month Day  |     |  `dym()`  Day Year Month      |
+--------------------------+-----+-------------------------------+
| `mdy()`  Month Day Year  |     |  `myd()`  Month Year Day      |
+--------------------------+-----+-------------------------------+
| `dmy()`  Day Month Year  |     |  `ydm()`  Year Day Month      |
+--------------------------+-----+-------------------------------+

The uncommon orders aren't likely to be used, but the `lubridate` package includes them for completeness. Once the order has been specified, the `lubridate` package will try as many different ways to parse the date that make sense. As a result, so long as the order is consistent, all of the following will work:

```r
mdy( 'June 26, 1997', 'Jun 26 97', '6-26-97', '6-26-1997', '6/26/97', '6-26/97' )
```

```
## [1] "1997-06-26" "1997-06-26" "1997-06-26" "1997-06-26" "1997-06-26"
## [6] "1997-06-26"
```



```r
mdy('June 26, 0097', 'June 26, 97',  'June 26, 68', 'June 26, 69')
```

```
## [1] "0097-06-26" "1997-06-26" "2068-06-26" "1969-06-26"
```

This shows by default if you only specify the year using two digits, `lubridate` will try to do something clever. It will default to either a 19XX or 20XX and it picks whichever is the closer date. This illustrates that you should ALWAYS fully specify the year using four digits.

The `lubridate` functions will also accommodate if an integer representation of the date, but it has to have enough digits to uniquely identify the month and day.


```r
ymd(20090110)
```

```
## [1] "2009-01-10"
```

```r
ymd(2009722) # only one digit for month --- error!
```

```
## Warning: All formats failed to parse. No formats found.
```

```
## [1] NA
```

```r
ymd(2009116) # this is ambiguous! 1-16 or 11-6?
```

```
## Warning: All formats failed to parse. No formats found.
```

```
## [1] NA
```

If we want to add a time to a date, we will use a function with the suffix `_hm` or `_hms`. Suppose that we want to encode a date and time, for example, the date and time of my wedding ceremony

```r
mdy_hm('Sep 18, 2010 5:30 PM', '9-18-2010 17:30')
```

```
## [1] "2010-09-18 17:30:00 UTC" "2010-09-18 17:30:00 UTC"
```

In the above case, `lubridate` is correctly parsing the AM/PM designation, but it is better to always specify times using 24 hour notation and skip the AM/PM designations.


## Time Zones
Time zones are incredibly important because as humans, we like to have a reasonable scale designating the morning, evening, and night that is universally understood. However this introduces a huge number of complication in scheduling across time zones. To further complicate matters, daylight savings times have us skipping forward an hour during the spring and falling back an hour in the fall.

By default, R codes the time of day using UTC (Coordinated Universal Time)  standard, which is nearly inter-changeable with Greenwich Mean Time (GMT). To specify a different time zone, use the `tz=` option. For example:


```r
mdy_hm('9-18-2010 5:30 PM', tz='MST') # Mountain Standard Time
```

```
## [1] "2010-09-18 17:30:00 MST"
```

This isn't bad, but Loveland, Colorado is on MST in the winter and MDT in the summer because of daylight savings time. So to specify the time zone that could switch between standard time and daylight savings time, I should specify `tz='US/Mountain'`

```r
mdy_hm('9-18-2010 5:30 PM', tz='US/Mountain') # US mountain time
```

```
## [1] "2010-09-18 17:30:00 MDT"
```

Arizona is weird and doesn't use daylight savings time. Fortunately R has a built-in time zone just for us.


```r
mdy_hm('9-18-2010 17:30', tz='US/Arizona') # US Arizona time
```

```
## [1] "2010-09-18 17:30:00 MST"
```

R recognizes 582 different time zone locals and you can find these using the function `OlsonNames()`. To find out more about what these mean you can check out the Wikipedia page on timezones [http://en.wikipedia.org/wiki/List_of_tz_database_time_zones](http://en.wikipedia.org/wiki/List_of_tz_database_time_zones).


There is currently an unexpected challenge in dealing with vectors or data frames of dates, and that is the lubridate expects only a single value for `tz`. So if you pass in a vector, it won't work. The solution is to use `group_by()` or `rowwise()` prior to the calculation.


```r
dates <- c('2013-11-2 10:20', '2013-11-2 9:30', '2013-11-2 16:20') # in chronological order!   
zones <- c('America/New_York', 'America/Denver','America/New_York')

ymd_hm( dates, tz=zones )  # Does not work because of multiple time zones.
```

```
## Error in parse_date_time(dates, orders, tz = tz, quiet = quiet, locale = locale): `tz` argument must be a character of length one
```

```r
ymd_hm(dates) %>% with_tz(tzone = zones) # Also doesn't work
```

```
## Error in as.POSIXlt.POSIXct(x, tz): invalid 'tz' value
```

```r
# Still doesn't work with multiple time zones in a data frame
data.frame(date = dates, zone=zones) %>%
  mutate(date = ymd_hm(date, tz=zone))
```

```
## Error: Problem with `mutate()` input `date`.
## x `tz` argument must be a character of length one
## ℹ Input `date` is `ymd_hm(date, tz = zone)`.
```

```r
# So we have to separate this into separate time zones
# and only send in a SINGLE time zone at a time. The easiest
# way to do this is to use rowwise() which makes each row its
# own group so that zone is just a single value. 
data.frame(date = dates, zone=zones) %>%
  rowwise() %>%
  mutate(date = ymd_hm(date, tz=zone))
```

```
## # A tibble: 3 x 2
## # Rowwise: 
##   date                zone            
##   <dttm>              <chr>           
## 1 2013-11-02 10:20:00 America/New_York
## 2 2013-11-02 11:30:00 America/Denver  
## 3 2013-11-02 16:20:00 America/New_York
```

```r
# Unfortunately using `rowwise()` is very slow because rowwise() operations 
# are really slow. So it is better to group by zones and then just pass in
# the first element of the zone vector.
data.frame(date = dates, zone=zones) %>%
  group_by(zone) %>%
  mutate(date = ymd_hm(date, tz=zone[1]))
```

```
## # A tibble: 3 x 2
## # Groups:   zone [2]
##   date                zone            
##   <dttm>              <chr>           
## 1 2013-11-02 08:20:00 America/New_York
## 2 2013-11-02 09:30:00 America/Denver  
## 3 2013-11-02 14:20:00 America/New_York
```

The previous two calculations are disturbing because depending on how we did the calculation, everything is either on New York time (the first case) or Denver time (the second case). This is exceedingly confusing because when R prints the date column, it isn't showing us what time zone is being used! So we could add a column that shows the timezone.


```r
data.frame(date = dates, zone=zones) %>%
  group_by(zone) %>%  # these are the different input zones!
  mutate(date = ymd_hm(date, tz=zone[1])) %>%
  mutate(zone = tz(date)) # this is the output zone that is identical for all rows!
```

```
## # A tibble: 3 x 2
## # Groups:   zone [1]
##   date                zone          
##   <dttm>              <chr>         
## 1 2013-11-02 08:20:00 America/Denver
## 2 2013-11-02 09:30:00 America/Denver
## 3 2013-11-02 14:20:00 America/Denver
```

Because time zones are finicky a R, if you have an application that has to deal with more than one timezone, I recommend always storing the information as UTC referenced values. Then you can do all your time point calculations knowing that you are on the same time scale. Then if you want to show a date to a user, you know that you always have to convert the time to the desired time zone.


## Extracting information

The `lubridate` package provides many functions for extracting information from the date. Suppose we have defined

```r
# Derek's wedding!
x <- mdy_hm('9-18-2010 17:30', tz='US/Mountain') # US Mountain time
```


|    Command    |      Output    | Description                       |
|:-------------:|:--------------:|:----------------------------------|
| `year(x)`     | 2010           |  Year                             |
| `month(x)`    | 9              |  Month                            |
| `day(x)`      | 18             |  Day                              |
| `hour(x)`     | 17             |  Hour of the day                  |
| `minute(x)`   | 30             |  Minute of the hour               |
| `second(x)`   | 0              |  Seconds                          |
| `wday(x)`     | 7              |  Day of the week (Sunday = 1)     |
| `mday(x)`     | 18             |  Day of the month                 |
| `yday(x)`     | 261            |  Day of the year                  |
| `tz(x)`       | 'US/Mountain'  |  Time Zone                        |

Here we get the output as digits, where September is represented as a 9 and the day of the week is a number between 1-7. To get nicer labels, we can use `label=TRUE` for some commands. In conjunction with `label=TRUE` there is the option `abbr=TRUE` that specifies to return the abbreviation or not.

|   Command              |     Output                | 
|:----------------------:|:--------------------------|
| `wday(x, label=TRUE)`  | Sat   |
| `wday(x, label=TRUE, abbr=FALSE)`  | Saturday   |
| `month(x, label=TRUE)` | Sep  |
| `month(x, label=TRUE, abbr=FALSE)` | September  |


All of these functions can also be used to update the value. For example, we could move the day of the wedding from September $18^{th}$ to October $18^{th}$ by changing the month.


```r
month(x) <- 10             # I really don't like this method of changing the month
x <- update(x, month=10)   # update feels a little better to me
x
```

```
## [1] "2010-10-18 17:30:00 MDT"
```

Often I want to consider some point in time, but need to convert the timezone the date was specified into another timezone. The function `with_tz()` will take a given moment in time and figure out when that same moment is in another timezone. For example, *Game of Thrones* is made available on HBO's streaming service at 9pm on Sunday evenings Eastern time. I need to know when I can start watching it here in Arizona.


```r
GoT <- ymd_hm('2015-4-26 21:00', tz='US/Eastern')
with_tz(GoT, tz='US/Arizona')
```

```
## [1] "2015-04-26 18:00:00 MST"
```

This means that Game of Thrones is available for streaming at 6 pm Arizona time.

## Printing Dates
We often need to print out character strings representing a particular date and time in a format that is convenient for humans to read. The output we've seen is acceptable for many instances, but if we want more control over the format we have to use one of the following methods.

The base R function `format()` allows for a wide variety of possibilities but we have to remember the syntax which is found in help file for `strptime`.


```r
# This is the base R solution
# 
# %A = Day of the week (not abbreviated)
# %B = Month name written out (not abbreviated). 
# %I = Hour on 1-12 scale
# %P = am/pm designation using lowercase am/pm. %p gives the uppercase version
# %Z = Time Zone designation
format(x, '%A, %B %d, %Y at the time of %I:%M %P %Z')  
```

```
## [1] "Monday, October 18, 2010 at the time of 05:30 pm MDT"
```

What lubridate does is allows the user to specify the format using an example date. It then parses the example to figure out the format and then creates a function that will apply that format to any dates you want.


```r
# The weekday needs to match up with the date in the example...
# Notice this still isn't completely un ambiguous and multiple formats are possible
my_fancy_formater <- stamp('Sunday, January 31, 1999 at 12:59 pm')
```

```
## Multiple formats matched: "%A, %B %d, %Y at %I:%M %p"(1), "Sunday, %Om %d, %Y at %H:%M %Op"(1), "Sunday, %B %d, %Y at %I:%M %p"(1), "%A, %Om %d, %Y at %H:%M %Op"(0), "%A, %B %d, %Y at %H:%M %Op"(0), "%A, %Om %d, %Y at %I:%M %p"(0), "Sunday, %B %d, %Y at %H:%M %Op"(0), "Sunday, %Om %d, %Y at %I:%M %p"(0)
```

```
## Using: "%A, %B %d, %Y at %I:%M %p"
```

```r
my_fancy_formater( x )  
```

```
## [1] "Monday, October 18, 2010 at 05:30 PM"
```

The `lubridate::stamp()` function is pretty cool for getting started on an output format string, but I generally prefer to just dig into the `strptime` help and figure it out the format string I want exactly.

When just printing out dates, R is very reluctant to print out the time zone. When dealing with data frames of dates, I often find myself creating a character string with the time zone, just so I can double check the time zone information is correct.

## Arithmetic on Dates

`lubridate` provides two different ways of dealing with arithmetic on dates, and Hadley's chapter on Date/Times in 
[R for Data Science](https://r4ds.had.co.nz/dates-and-times.html) 
is a good reference. 

Recall that dates are stored as the number of seconds since 0:00:00 January 1, 1970 UTC. This fundamental idea that a date is just some number of seconds introduces the idea that a minute is just 60 seconds, an hour is 3600 seconds, a day is $24*3600=86,400$ seconds, and finally a year is $365*86,400=31,536,000$ seconds. But what about leap years! Years are not always 365 days and days are not always 24 hours (think about daylight savings times). 

With this in mind, we need to be able to do arithmetic using conventional ideas of year/month/day that ignores any clock discontinuities as well as using precise ideas of exactly how many seconds elapsed between two time points.

|  Object Class   |   Description                                            |
|:---------------:|:---------------------------------------------------------|
|  **Periods**    | Lubridate periods correspond to a *person's* natural inclination of adding a year or month and ignores any clock discontinuities. |
| **Durations**   | Lubridate duration correspond to the exact number of seconds between two points in time and adding some number of seconds. I remember that durations are the *dorky* number of seconds definition. |
| **Intervals**   | Lubridate allows us to create an object that stores a beginning and ending time point. |


```r
current <- ymd_hms('2019-10-12 10:25:00', tz='MST')
current + years(1)  # period. There are also minutes, hours, days, months functions.
```

```
## [1] "2020-10-12 10:25:00 MST"
```

```r
current + dyears(1) # duration. There are also dminutes, dhours, ddays, dmonths
```

```
## [1] "2020-10-11 16:25:00 MST"
```

Notice that `dyears(1)` didn't just increment the years from 2019 to 2020, but rather added $60*60*24*365$ seconds, and because 2020 is a leap year and therefore February 29 will exist. Thus adding $31,536,000$ seconds ended up with a result of October 11$^{th}$ instead of October 12$^{th}$.

Once we have two or more Date objects defined, we can calculate the amount of time between the two dates. We'll first create an `interval` that defines the exact start and stop of the time interval we care about and then convert that to either a `period` (person convention) or a `duration` (# of seconds).


```r
Wedding <- ymd('2010-Sep-18')
Elise <- ymd('2013-Jan-11')

Childless =  interval(Wedding, Elise)  # Two different ways to 
Childless =  Wedding %--% Elise        # create a time interval

as.period( Childless )                 # Turn it into person readable
```

```
## [1] "2y 3m 24d 0H 0M 0S"
```

```r
as.period(Childless, unit = 'days')    # Person readable version of days
```

```
## [1] "846d 0H 0M 0S"
```

```r
as.duration( Childless )               # dorky number of seconds answer
```

```
## [1] "73094400s (~2.32 years)"
```

While working with dates, I like creating intervals whenever possible and try to NEVER just subtract two data/time objects because that will always just return the number of seconds (aka the `duration` answer). 

As a demonstration, lets consider a data set where we have the individuals birthdays and we are interested in calculated the individuals age in years.


```r
data <- tibble(
  Name = c('Steve', 'Sergey', 'Melinda', 'Bill', 'Alexa', 'Siri'),
  dob = c('Feb 24, 1955', 'August 21, 1973', 'Aug 15, 1964', 
          'October 28, 1955', 'November 6, 2014', 'October 12, 2011') )

data %>%
  mutate( dob = mdy(dob) ) %>%
  mutate( Life = dob %--% today() ) %>%
  mutate( Age = as.period(Life, units='years') ) %>%
  mutate( Age2 = year(Age) )
```

```
## # A tibble: 6 x 5
##   Name    dob        Life                           Age                  Age2
##   <chr>   <date>     <Interval>                     <Period>            <int>
## 1 Steve   1955-02-24 1955-02-24 UTC--2020-11-04 UTC 65y 8m 11d 0H 0M 0S    65
## 2 Sergey  1973-08-21 1973-08-21 UTC--2020-11-04 UTC 47y 2m 14d 0H 0M 0S    47
## 3 Melinda 1964-08-15 1964-08-15 UTC--2020-11-04 UTC 56y 2m 20d 0H 0M 0S    56
## 4 Bill    1955-10-28 1955-10-28 UTC--2020-11-04 UTC 65y 0m 7d 0H 0M 0S     65
## 5 Alexa   2014-11-06 2014-11-06 UTC--2020-11-04 UTC 5y 11m 29d 0H 0M 0S     5
## 6 Siri    2011-10-12 2011-10-12 UTC--2020-11-04 UTC 9y 0m 23d 0H 0M 0S      9
```


As a final example, suppose that an hourly employee clocked in at 11:30 PM March 7, 2020 and then clocked out at 7:30 AM March 8 2020. How long did he or she work?

```r
In  <- ymd_hm('2020-3-7 11:30 PM', tz='US/Mountain')
Out <- ymd_hm('2020-3-8 7:45 AM', tz='US/Mountain')

In %--% Out
```

```
## [1] 2020-03-07 23:30:00 MST--2020-03-08 07:45:00 MDT
```

```r
as.period(  In %--%Out)       # Does NOT account for daylight savings time!
```

```
## [1] "8H 15M 0S"
```

```r
as.duration(In %--%Out)       # Does account for daylight savings time!
```

```
## [1] "26100s (~7.25 hours)"
```

To use a duration in any subsequent calculation, we need to convert it to a numeric value using the `as.numeric()` function, which can convert to whatever unit you want.

```r
# 
time.worked <- as.duration(In %--%Out)
as.numeric(time.worked, "hours")
```

```
## [1] 7.25
```

```r
as.numeric(time.worked, "minutes")
```

```
## [1] 435
```


## Exercises  {#Exercises_Dates}

1. Convert the following to date or date/time objects.
    a) September 13, 2010.
    b) Sept 13, 2010.
    c) Sep 13, 2010.
    d) S 13, 2010. Comment on the month abbreviation needs.
    e) 07-Dec-1941.
    f) 1-5-1998. Comment on why you might be wrong.
    g) 21-5-1998. Comment on why you know you are correct.
    h) 2020-May-5 10:30 am
    i) 2020-May-5 10:30 am PDT (ex Seattle)
    j) 2020-May-5 10:30 am AST (ex Puerto Rico)

    

2. Using just your date of birth (ex Sep 7, 1998) and today's date calculate the following _Write your code in a manner that the code will work on any date after you were born._:
    a) Calculate the date of your 64th birthday.
    b) Calculate your current age (in years). _Hint: Check your age is calculated correctly if your birthday was yesterday and if it were tomorrow!_ 
    d) Using your result in part (b), calculate the date of your next birthday.
    e) The number of _days_ until your next birthday.
    f) The number of _months_ and _days_ until your next birthday.

<!-- 3. It is some what surprising that there exists a `dmonths()` function. -->
<!--     a) Using today's date, add 1 month using `dmonths(1)` and `months()`. Are there any differences? -->
<!--     b) Consider `dmonths(1)`. What does this represent and speculate on how the authors chose to define this, because it isn't just 30 days divided by 7 days in a week. -->

3. Suppose you have arranged for a phone call to be at 3 pm on May 8, 2015 at Arizona time. However, the recipient will be in Auckland, NZ. What time will it be there? 

4. From this book's [GitHub](https://github.com/dereksonderegger/444/) directory, navigate to the `data-raw` directory and then download the `Pulliam_Airport_Weather_Station.csv` data file. (*There are several weather station files. Make sure you get the correct one!*)  There is a `DATE` column (is it of type `date` when you import the data?) as well as the Maximum and Minimum temperature. For the last 5 years of data we have (exactly, not just starting at Jan 1, 2014!), plot the time series of daily maximum temperature with date on the x-axis. Write your code so that it will work if I update the dateset. *Hint: Find the maximum date in the data set and then subtract 5 years. Will there be a difference if you use `dyears(5)` vs `years(5)`? Which seems more appropriate here?*

5. It turns out there is some interesting periodicity regarding the number of births on particular days of the year.
    a. Using the `mosaicData` package, load the data set `Births78` which records the number of children born on each day in the United States in 1978. Because this problem is intended to show how to calculate the information using the `date`, remove all the columns *except* `date` and `births`. 
    b. Graph the number of `births` vs the `date` with date on the x-axis. What stands out to you? Why do you think we have this trend?
    c. To test your assumption, we need to figure out the what day of the week each observation is. Use `dplyr::mutate` to add a new column named `dow` that is the day of the week (Monday, Tuesday, etc). This calculation will involve some function in the `lubridate` package and the `date` column. 
    d. Plot the data with the point color being determined by the day of the week variable.
    

<!-- Split this problem up into 3 problems:  -->
<!-- Give them the joined data for Dest_tzone -->
<!--   Create a Dep_Time column with UTC time zone. -->
<!--   First create an arrival date. -->
<!--   Next create an arrival date/time by parsing arr_time. -->
<!--   Calculate seat time and compare it to airtime. -->
<!-- 6. The R package `nycflights13` contains information about all commercial flights leaving New York City in 2013. One calculation it doesn't contain is the amount of time between the departure and arrival, which we'll call `seat_time`. Departure and arrival times are the points in time when the cabin doors close (and no new passengers may board) and when the when the cabin doors open (and passengers may disembark). Calculate the seat time for each flight and for grading verification, show the carrier, flight number, destination, departure time, arrival time, and seat_time for all flights leaving after 10:40 pm on November 2. -->
<!--     a. Because these are flights leaving NYC, we know the departure timezone is `America/New_York`, but we don't know the time zone for the destination. That information is in the `airports` table. However, there are four airports missing. Manually add the missing rows to the `airports` table using information you find on the internet. -->
<!--     b. For flights with missing data for `dep_time` and `arr_time`, substitute in the scheduled value. -->
<!--     c. Create a date object for arrival times. Notice some flights land the next day and you should account for this! (There is already a datetime object for departure named `time_hour`.  -->
<!--     d. Create a datetime object for the arrival times. *Hint: ymd_hm() only allows for a single time zone to be passed. We can get around this by doing a `rowwise()` prior, which forms a grouped table where the group size is a single row. To grab the hours and minutes, you could either convert the numeric time to a character string of length four and pull the appropriate parts, or you could do a little bit of fancy modulus/remainder arithmatic.* -->
<!--     e. Create an interval and use that to calculate the seat time. -->
<!--     f. Show the carrier, flight number, destination, departure time, arrival time, and seat_time for the first 6 flights leaving after 10:40 pm on November 2. -->
