# Dates and Times




```r
library(tidyverse)
library( lubridate )
```

Dates within a computer require some special organization because there are several competing conventions for how to write a date (some of them more confusing than others) and because the sort order should be in the order that the dates occur in time.

One useful tidbit of knowledge is that computer systems store a time point as the number of seconds from set point in time, called the epoch. So long as you always use the same epoch, you doesn't have to worry about when the epoch is, but if you are switching between software systems, you might run into problems if they use different epochs. In R, we use midnight on Jan 1, 1970. In Microsoft Excel, they use Jan 0, 1900. 

For many years, R users hated dealing with dates because it was difficult to remember how to get R to take a string that represents a date (e.g. “June 26, 1997”) because users were required to specify how the format was arranged using a relatively complex set of rules. For example `%y` represents the two digit year, `%Y` represents the four digit year, `%m` represents the month, but `%b` represents the month written as Jan or Mar. Into this mess came Hadley Wickham (of `ggplot2` and `dplyr` fame) and his student Garrett Grolemund. The internal structure of R dates and times is quite robust, but the functions we use to manipulate them are horrible. To fix this, Dr Wickham and his then PhD student Dr Grolemund introduced the `lubridate` package.

## Creating Date and Time objects

R gives a mechanism for getting the current date and time.

```r
lubridate::today()   # Today's date
```

```
## [1] "2020-09-23"
```

```r
base::Sys.Date()     # Today's date
```

```
## [1] "2020-09-23"
```

```r
base::Sys.time()     # Current Time and Date 
```

```
## [1] "2020-09-23 13:46:19 MST"
```


To create a `Date` object, we need to take a string or number that represents a date and tell the computer how to figure out which bits are the year, which are the month, and which are the day. The lubridate package uses the following functions:

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
mdy_hm('Sept 18, 2010 5:30 PM', '9-18-2010 17:30')
```

```
## [1] NA                        "2010-09-18 17:30:00 UTC"
```

In the above case, `lubridate` is having trouble understanding AM/PM differences and it is better to always specify times using 24 hour notation and skip the AM/PM designations.

By default, R codes the time of day using as if the event occurred in the UMT time zone (also known as Greenwich Mean Time GMT). To specify a different time zone, use the `tz=` option. For example:


```r
mdy_hm('9-18-2010 17:30', tz='MST') # Mountain Standard Time
```

```
## [1] "2010-09-18 17:30:00 MST"
```

This isn't bad, but Loveland, Colorado is on MST in the winter and MDT in the summer because of daylight savings time. So to specify the time zone that could switch between standard time and daylight savings time, I should specify `tz='US/Mountain'`

```r
mdy_hm('9-18-2010 17:30', tz='US/Mountain') # US mountain time
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

R recognizes 582 different time zone locals and you can find these using the function `OlsonNames()`. To find out more about what these mean you can check out the Wikipedia page on timezones [http://en.wikipedia.org/wiki/List_of_tz_database_time_zones||http://en.wikipedia.org/wiki/List_of_tz_database_time_zones].

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

Here we get the output as digits, where September is represented as a 9 and the day of the week is a number between 1-7. To get nicer labels, we can use `label=TRUE` for some commands. 

|   Command              |     Ouput                | 
|:----------------------:|:--------------------------|
| `wday(x, label=TRUE)`  | Sat   |
| `month(x, label=TRUE)` | Sep  |


All of these functions can also be used to update the value. For example, we could move the day of the wedding from September $18^{th}$ to October $18^{th}$ by changing the month.


```r
# I really don't like this method of changing the month
month(x) <- 10

# update feels a little better to me
x <- update(x, month=10)

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
##   Name    dob        Life                           Age                   Age2
##   <chr>   <date>     <Interval>                     <Period>             <int>
## 1 Steve   1955-02-24 1955-02-24 UTC--2020-09-23 UTC 65y 6m 30d 0H 0M 0S     65
## 2 Sergey  1973-08-21 1973-08-21 UTC--2020-09-23 UTC 47y 1m 2d 0H 0M 0S      47
## 3 Melinda 1964-08-15 1964-08-15 UTC--2020-09-23 UTC 56y 1m 8d 0H 0M 0S      56
## 4 Bill    1955-10-28 1955-10-28 UTC--2020-09-23 UTC 64y 10m 26d 0H 0M 0S    64
## 5 Alexa   2014-11-06 2014-11-06 UTC--2020-09-23 UTC 5y 10m 17d 0H 0M 0S      5
## 6 Siri    2011-10-12 2011-10-12 UTC--2020-09-23 UTC 8y 11m 11d 0H 0M 0S      8
```



## Exercises  {#Exercises_Dates}

1. For the following formats for a date, transform them into a date/time object. Which formats can be handled nicely and which are not? *The lubridate package has gotten smarter over time and a couple of these used to fail.*
    a) For September 13
        
        ```r
        birthday <- c(
          'September 13, 1978',
          'Sept 13, 1978',
          'Sep 13, 1978',
          'S 13, 1978',
          '9-13-78',
          '9-13/78',
          '9/13/78')
        ```
    b) For June 15, 1978 we should have a problem.
        
        ```r
        birthday <- c(
          'June 13, 1978',
          'J 13, 1978')
        ```

2. Suppose you have arranged for a phone call to be at 3 pm on May 8, 2015 at Arizona time. However, the recipient will be in Auckland, NZ. What time will it be there? 

3. From this book's [GitHub](https://github.com/dereksonderegger/444/) directory, navigate to the `data-raw` directory and then download the `Pulliam_Airport_Weather_Station.csv` data file. (*There are several weather station files. Make sure you get the correct one!*)  There is a `DATE` column (is it of type `date` when you import the data?) as well as the Maximum and Minimum temperature. For the last 10 years of data we have (exactly, not just starting at Jan 1, 2009!), plot the daily maximum temperature. *Hint: Find the maximum date in the data set and then subtract 10 years. Will there be a difference if you use `dyears(10)` vs `years(10)`? Which seems more appropriate here?*

4. It turns out there is some interesting periodicity regarding the number of births on particular days of the year.
    a. Using the `mosaicData` package, load the data set `Births78` which records the number of children born on each day in the United States in 1978. Because this problem is intended to show how to calculate the information using the `date`, remove all the columns *except* `date` and `births`. 
    b. Graph the number of `births` vs the `date` with date on the x-axis. What stands out to you? Why do you think we have this trend?
    c. To test your assumption, we need to figure out the what day of the week each observation is. Use `dplyr::mutate` to add a new column named `dow` that is the day of the week (Monday, Tuesday, etc). This calculation will involve some function in the `lubridate` package and the `date` column. 
    d. Plot the data with the point color being determined by the day of the week variable.
    

