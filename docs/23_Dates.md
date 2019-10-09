# Dates and Times




```r
library( lubridate )
```

Dates within a computer require some special organization because there are several competing conventions for how to write a date (some of them more confusing than others) and because the sort order should be in the order that the dates occur in time.

One useful tidbit of knowledge is that computer systems store a time point as the number of seconds from set point in time, called the epoch. So long as you always use the same epoch, you doesn't have to worry about when the epoch is, but if you are switching between software systems, you might run into problems if they use different epochs. In R, we use midnight on Jan 1, 1970. In Microsoft Excel, they use Jan 0, 1900. 

For many years, R users hated dealing with dates because it was difficult to remember how to get R to take a string that represents a date (e.g. “June 26, 1997”) because users were required to specify how the format was arranged using a relatively complex set of rules. For example `%y` represents the two digit year, `%Y` represents the four digit year, `%m` represents the month, but `%b` represents the month written as Jan or Mar. Into this mess came Hadley Wickham (of `ggplot2` and `dplyr` fame) and his student Garrett Grolemund. The internal structure of R dates and times is quite robust, but the functions we use to manipulate them are horrible. To fix this, Dr Wickham and his then PhD student Dr Grolemund introduced the `lubridate` package.

## Creating Date and Time objects

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

This shows by default if you only specify the year using two digits, `lubridate()` will try to do something clever. It will default to either a 19XX or 20XX and it picks whichever is the closer date. This illustrates that you should ALWAYS fully specify the year using four digits.

The lubridate functions will also accommodate if an integer representation of the date, but it has to have enough digits to uniquely identify the month and day.


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


As Arizonans, we recognize that Arizona is weird and doesn't use daylight savings time. Fortunately R has a built-in time zone just for us.


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

+---------------+----------------+-----------------------------------+
|    Command    |      Ouput     | Description                       |
+===============+================+===================================+
| `year(x)`     | 2010           |  Year                             |
+---------------+----------------+-----------------------------------+
| `month(x)`    | 9              |  Month                            |
+---------------+----------------+-----------------------------------+
| `day(x)`      | 18             |  Day                              |
+---------------+----------------+-----------------------------------+
| `hour(x)`     | 17             |  Hour of the day                  |
+---------------+----------------+-----------------------------------+
| `minute(x)`   | 30             |  Minute of the hour               |
+---------------+----------------+-----------------------------------+
| `second(x)`   | 0              |  Seconds                          |
+---------------+----------------+-----------------------------------+
| `wday(x)`     | 7              |  Day of the week (Sunday = 1)     |
+---------------+----------------+-----------------------------------+
| `mday(x)`     | 18             |  Day of the month                 |
+---------------+----------------+-----------------------------------+
| `yday(x)`     | 261            |  Day of the year                  |
+---------------+----------------+-----------------------------------+

Here we get the output as digits, where September is represented as a 9 and the day of the week is a number between 1-7. To get nicer labels, we can use `label=TRUE` for some commands. 

+------------------------+---------------------------+
|   Command              | Ouput                     | 
+========================+===========================+
| `wday(x, label=TRUE)`  | Sat   |
+------------------------+---------------------------+
| `month(x, label=TRUE)` | Sep  |
+------------------------+---------------------------+


All of these functions can also be used to update the value. For example, we could move the day of the wedding from September $18^{th}$ to October $18^{th}$ by changing the month.


```r
month(x) <- 10
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

Once we have two or more Date objects defined, we can perform appropriate mathematical operations. For example, we might want to the know the number of days there are between two dates.


```r
Wedding <- ymd('2010-Sep-18')
Elise <- ymd('2013-Jan-11')
Childless <- Elise - Wedding
Childless
```

```
## Time difference of 846 days
```

Because both dates were recorded without the hours or seconds, R defaults to just reporting the difference in number of days. 

Often I want to add two weeks, or 3 months, or one year to a date. However it is not completely obvious what I mean by “add 1 year”. Do we mean to increment the year number (eg Feb 2, 2011 -> Feb 2, 2012) or do we mean to add 31,536,000 seconds? To get around this, `lubridate` includes functions of the form `dunits()` and `units()` where the “unit” portion could be year, month, week, etc. The “d” prefix will stand for duration when appropriate.


```r
x <- ymd("2011-Feb-21")
x + years(2)  # Just add two to the year
```

```
## [1] "2013-02-21"
```

```r
x + dyears(2) # Add 2*365 days; 2012 was a leap year
```

```
## [1] "2013-02-20"
```



## Exercises

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

3. From this book's [data-raw](https://github.com/dereksonderegger/444/data-raw) directory on GitHub, download the `Pulliam_Airport_Weather_Station.csv` data file. There is a `DATE` column as well as the Maximum and Minimum temperature. For the last 10 years of data, plot the daily maximum temperature.

4. It turns out there is some interesting periodicity regarding the number of births on particular days of the year.

    a. Using the `mosaicData` package, load the data set `Births78` which records the number of children born on each day in the United States in 1978. Because this problem is intended to show how to calculate the information using the `date`, remove the columns of `month`, `day_of_year`, `day_of_month` and `day_of_week`.
    
    b. There is already a date column in the data set that is called, appropriately, date. Graph the number of `births` vs the `date` with date on the x-axis. What stands out to you? Why do you think we have this trend?

    c. To test your assumption, we need to figure out the what day of the week each observation is. Use `dplyr::mutate` to add a new column named `dow` that is the day of the week (Monday, Tuesday, etc). This calculation will involve some function in the `lubridate` package and the `date` column. 

    d. Plot the data with the point color being determined by the day of the week variable.
