# Data Reshaping




```r
# library(tidyr)   # for the gather/spread commands
# library(dplyr)   # for the join stuff
library(tidyverse) # dplyr, tidyr, ggplot2, etc.
```


Most of the time, our data is in the form of a data frame and we are interested in exploring the relationships. However most procedures in R expect the data to show up in a 'long' format where each row is an observation and each column is a covariate. In practice, the data is often not stored like that and the data comes to us with repeated observations included on a single row. This is often done as a memory saving technique or because there is some structure in the data that makes the 'wide' format attractive. As a result, we need a way to convert data from 'wide' to 'long' and vice-versa.

Next we need a way to squish two data frames together. It is often advantageous to store data that would be be repeated separately in a different table so that a particular piece of information lives in only one location. This makes the data easier to modify, and more likely to maintain consistence. However, this practice requires that, when necessary, we can add information to a table, that might involve a lot of duplicated rows.

## `data.frames` vs `tibbles`
Previously we've been using `data.frame` and `tibble` objects interchangeably, but now is a good time make a distinction. Essentially a `tibble` is a `data.frame` that does more type checking and less coercion during creation and manipulation. So a `tibble` does less (automatically) and complains more. The rational for this is that while coercion between data types can be helpful, it often disguises errors that take a long time to track down. On the whole, is better to force the user to do the coercion explicitly rather than hope that R magically does the right thing.


Second, the printing methods for `tibbles` prevent it from showing too many rows or columns. This is a very convenient and more user-friendly way to show the data. We can control how many rows or columns are printed using the `options()` command, which sets all of the global options.

|  Options            |    Result                           |
|:--------------------------------------:|:-----------------|
| `options(tibble.print_max = n, tibble.print_min = m)`  | if there are more than `n` rows, print only the first `m`. 
| `options(tibble.print_max = Inf)` |  Always print all the rows. |
| `options(tibble.width = Inf)` | Always print all columns, regardless of the width of the display device. |

Third, `tibbles` support column names that would be rejected by a data frame.  For example, a data frame will not allow columns to begin with a number, nor can column names contain a space. These are allowable by `tibbles`, although they are required to be enclosed by back-quotes when referring to them.


```r
example <- tribble(
  ~'1984', ~"Is Awesome",
  'George',   20,
  'Orwell',   87)

example %>% select( `1984`, `Is Awesome` )
```

```
## # A tibble: 2 x 2
##   `1984` `Is Awesome`
##   <chr>         <dbl>
## 1 George           20
## 2 Orwell           87
```

## `cbind` & `rbind`
Base R has two functions for squishing two data frames together, but they assume that the data frames are aligned correctly. The `c` and `r` parts of `cbind` and `rbind` correspond to if we are pushing columns together or rows together. 


```r
# Define a tibble using a row-wise layout.
df1 <- tribble(            
  ~ID,  ~First,
  1,   'Alice',
  2,   'Bob',
  3,   'Charlie')

# Define a tibble by columns
df2 <- tibble( Last = c('Anderson', 'Barker', 'Cooper') )

# Squish the two tibbles together by columns - results in a data.frame
People <- cbind( df1, df2 )
People
```

```
##   ID   First     Last
## 1  1   Alice Anderson
## 2  2     Bob   Barker
## 3  3 Charlie   Cooper
```

Squishing together by rows is easy as well.

```r
df3 <- tibble( ID=4, First='Daniel', Last='Davidson' )

People <- rbind( People, df3 )
People
```

```
##   ID   First     Last
## 1  1   Alice Anderson
## 2  2     Bob   Barker
## 3  3 Charlie   Cooper
## 4  4  Daniel Davidson
```

If both inputs have row or column names, then they don't need to be appropriate arranged as `rbind` and `cbind` can figure out how to order them. 

There are equivalent functions in the `dplyr` package that do the same job, but will work more consistently. For example, if we try to bind a row of data that has more columns, `bind_rows()` will introduce a column of `NA` values to the smaller data set. Furthermore, if the column orders are mixed up


```r
df4 <- tibble(First='Elise', ID=5, Last='Erikson') # Notice changed columns order! 
rbind(People, df4)  # but rbind() can still figure it out!
```

```
##   ID   First     Last
## 1  1   Alice Anderson
## 2  2     Bob   Barker
## 3  3 Charlie   Cooper
## 4  4  Daniel Davidson
## 5  5   Elise  Erikson
```

```r
df5 <- tibble(First='Frank', ID=6, Last='Fredrick', dob=lubridate::ymd('1980-7-21'))
rbind(People, df5)   # throws an error
```

```
## Error in rbind(deparse.level, ...): numbers of columns of arguments do not match
```

```r
bind_rows( People, df4, df5) # Inserts NA values as appropriate.
```

```
##   ID   First     Last        dob
## 1  1   Alice Anderson       <NA>
## 2  2     Bob   Barker       <NA>
## 3  3 Charlie   Cooper       <NA>
## 4  4  Daniel Davidson       <NA>
## 5  5   Elise  Erikson       <NA>
## 6  6   Frank Fredrick 1980-07-21
```

In general, I find that `rbind()` and `bind_rows()` work really well and I use them quite often. However, `cbind()` and `bind_cols()` are less useful because I have to make sure that either I have rownames set up for each data set, or I have to be very careful with the ordering. Instead, it is safer to write code that relies on `joins`, which will be discussed later in this chapter.


## `tidyr`

There is a common issue with obtaining data with many columns that you wish were organized as rows. For example, I might have data in a grade book that has several homework scores and I'd like to produce a nice graph that has assignment number on the x-axis and score on the y-axis. Unfortunately this is incredibly hard to do when the data is arranged in the following way:


```r
grade.book <- rbind(
  data.frame(name='Alison',  HW.1=8, HW.2=5, HW.3=8, HW.4=4),
  data.frame(name='Brandon', HW.1=5, HW.2=3, HW.3=6, HW.4=9),
  data.frame(name='Charles', HW.1=9, HW.2=7, HW.3=9, HW.4=10))
grade.book
```

```
##      name HW.1 HW.2 HW.3 HW.4
## 1  Alison    8    5    8    4
## 2 Brandon    5    3    6    9
## 3 Charles    9    7    9   10
```

What we want to do is turn this data frame from a *wide* data frame into a *long* data frame. In MS Excel this is called pivoting. Essentially I'd like to create a data frame with three columns: `name`, `assignment`, and `score`. That is to say that each homework datum really has three pieces of information: who it came from, which homework it was, and what the score was. It doesn't conceptually matter if I store it as 3 rows of 4 columns or 12 rows so long as there is a way to identify how a student scored on a particular homework. So we want to reshape the HW1 to HW4 columns into two columns (assignment and score). 

This package was built by the same people that created dplyr and ggplot2 and there is a nice introduction at: [http://blog.rstudio.org/2014/07/22/introducing-tidyr/]

### Verbs 
As with the dplyr package, there are two main verbs to remember:

|  Function     |   Description                                                                    |
|:-------------:|:---------------------------------------------------------------------------------|
| `gather`      |  Gather multiple columns that are related into two columns that contain the original column name and the value. For example for columns `HW1`, `HW2`, `HW3` we would gather them into two columns: `Homework` and `Score`. In this case, we refer to `Homework` as the key column and `Score` as the value column. So for any key:value pair you know everything you need. |
| `spread`      | This is the opposite of `gather`. This takes a key column (or columns) and a value column and forms a new column for each level of the key column(s). |


```r
# first we gather the score columns into columns we'll name Homework and Score
tidy.scores <- grade.book %>% 
  gather( key=Homework,     # What should I call the key column
          value=Score,      # What should I call the values column
          HW.1:HW.4)        # which columns to apply this to
tidy.scores
```

```
##       name Homework Score
## 1   Alison     HW.1     8
## 2  Brandon     HW.1     5
## 3  Charles     HW.1     9
## 4   Alison     HW.2     5
## 5  Brandon     HW.2     3
## 6  Charles     HW.2     7
## 7   Alison     HW.3     8
## 8  Brandon     HW.3     6
## 9  Charles     HW.3     9
## 10  Alison     HW.4     4
## 11 Brandon     HW.4     9
## 12 Charles     HW.4    10
```

To spread the key:value pairs out into a matrix, we use the `spread()` command. 


```r
# Turn the Homework/Score pair of columns into one column per factor level of Homework
tidy.scores %>% spread( key=Homework, value=Score )
```

```
##      name HW.1 HW.2 HW.3 HW.4
## 1  Alison    8    5    8    4
## 2 Brandon    5    3    6    9
## 3 Charles    9    7    9   10
```

One way to keep straight which is the `key` column is that the key is the category, while `value` is the numerical value or response. 

Often times, the long format of the data is most helpful for graphing or doing data analysis. Because of this, we often refer to this as the *tidy* form of the data. Hadley has a nice article about messy data vs tidy data and his [article](https://vita.had.co.nz/papers/tidy-data.pdf) is well worth your time to read, although `dplyr` and `tidyr` have matured since he wrote this article. The main point can be summarized by:

    Tidy data has one observation per row and each column is a variable. - Hadley Wickham

There are a variety of reasons why data might be stored in a non-tidy wide format, or entered in a wide format, but it is important to make sure that it is easy to transform it into a tidy format.

## Storing Data in Multiple Tables
In many data sets it is common to store data across multiple tables, usually with the goal of minimizing memory used as well as providing minimal duplication of information so any change that must be made is only made in a single place.

To see the rational why we might do this, consider building a data set of blood donations by a variety of donors across several years. For each blood donation, we will perform some assay and measure certain qualities about the blood and the patients health at the donation. But should we contain the donor's address, phone number, and email address in the same data table that holds the information about the blood donated.

I would like to include additional information about the donor where that information doesn't change overtime. For example we might want to have information about the donor's birthdate, sex, blood type.  However, I don't want that information in _every single donation line_.  Otherwise if I mistype a birthday and have to correct it, I would have to correct it _everywhere_. For information about the donor, should live in a `donors` table, while information about a particular donation should live in the `donations` table.

Furthermore, there are many Jeffs and Dereks in the world and to maintain a unique identifier (without using Social Security numbers) I will just create a `Donor_ID` code that will uniquely identify a person.  Similarly I will create a `Blood_ID` that will uniquely identify a blood donation.



```r
Donors
```

```
## # A tibble: 3 x 7
##   Donor_ID Name   Blood_Type Birthday   Street       City      State
##   <chr>    <chr>  <chr>      <chr>      <chr>        <chr>     <chr>
## 1 D1       Derek  O+         1976-09-17 7392 Willard Flagstaff AZ   
## 2 D2       Jeff   A-         1974-06-23 873 Vine     Bozeman   MT   
## 3 D3       Aubrey O+         1976-09-17 7392 Willard Flagstaff AZ
```




```r
Blood_Donations 
```

```
## # A tibble: 5 x 6
##   Blood_ID Donor_ID Date       Hemoglobin Systolic Diastolic
##   <chr>    <chr>    <chr>           <dbl>    <dbl>     <dbl>
## 1 B_1      D1       2017-04-14       17.4      120        79
## 2 B_2      D1       2017-06-20       16.5      121        80
## 3 B_3      D2       2017-08-14       16.9      145       101
## 4 B_4      D1       2017-08-26       17.6      120        79
## 5 B_5      D3       2017-08-26       16.1      137        90
```

If we have a new donor walk in and give blood, then we'll have to create a new entry in the `donors` table as well as a new entry in the `donations` table. If an experienced donor gives again, we just have to create a new entry in the donations table.

Given this data structure, we can now easily create new donations as well as store donor information. In the event that we need to change something about a donor, there is only _one_ place to make that change.

However, having data spread across multiple tables is challenging because I often want that information squished back together.  For example, if during routine testing we discover that a blood sample is HIV positive. Then we *need* to be able to join the blood donations table to the donors table in some sensible manner.

## Table Joins

There are four different types of joins: outer, left, right, and inner joins. Consider the following example tables. Here we consider that there is some *key* column that is common to both tables.

| Join Type            | Result                           |
|:--------------------:|:---------------------------------|
|  `inner_join(A,B)`   | Include rows if the key value is in *both* tables.   |
|  `left_join(A,B)`    | Include all rows of `A`, and if the match in `B` doesn't exist, just insert a `NA`. |
|  `right_join(A,B)`   | Include all rows of `B`, and if the match in `A` doesn't exist, just insert a `NA`. |    
|  `full_join(A,B)`    | Include all rows of `A` and `B` and if the necessary match doesn't exist, insert `NA` values. |

For a practical example

```r
A <- tribble(
  ~ID, ~x,
  'a', 34,    # Notice that A doesn't have ID = d
  'b', 36,
  'c', 38)
B <- tribble(
  ~ID, ~y,
  'b', 56,   # Notice that B doesn't have ID = a
  'c', 57,
  'd', 59)
```



```r
# only include rows with IDs that are in both tables
inner_join(A,B)
```

```
## # A tibble: 2 x 3
##   ID        x     y
##   <chr> <dbl> <dbl>
## 1 b        36    56
## 2 c        38    57
```

```r
# All the rows in table A, insert NA if the B info is missing
left_join(A,B)
```

```
## # A tibble: 3 x 3
##   ID        x     y
##   <chr> <dbl> <dbl>
## 1 a        34    NA
## 2 b        36    56
## 3 c        38    57
```

```r
# All the rows in table B, insert NA if the A info is missing
right_join(A,B)
```

```
## # A tibble: 3 x 3
##   ID        x     y
##   <chr> <dbl> <dbl>
## 1 b        36    56
## 2 c        38    57
## 3 d        NA    59
```

```r
# All the rows possible, insert NA if the matching info is missing
full_join(A,B)
```

```
## # A tibble: 4 x 3
##   ID        x     y
##   <chr> <dbl> <dbl>
## 1 a        34    NA
## 2 b        36    56
## 3 c        38    57
## 4 d        NA    59
```


Consider the case where we have a data frame of observations of fish and a separate data frame that contains information about lake (perhaps surface area, max depth, pH, etc). I want to store them as two separate tables so that when I have to record a lake level observation, I only input it *one* place. This decreases the chance that I make a copy/paste error. 

To illustrate the different types of table joins, we'll consider two different tables.

```r
# tibbles are just data.frames that print a bit nicer and don't automatically
# convert character columns into factors.  They behave a bit more consistently
# in a wide variety of situations compared to data.frames.
Fish.Data <- tibble(
  Lake_ID = c('A','A','B','B','C','C'), 
  Fish.Weight=rnorm(6, mean=260, sd=25) ) # make up some data
Lake.Data <- tibble(
  Lake_ID = c(    'B','C','D'),   
  Lake_Name = c('Lake Elaine', 'Mormon Lake', 'Lake Mary'),   
  pH=c(6.5, 6.3, 6.1),
  area = c(40, 210, 240),
  avg_depth = c(8, 10, 38))
```


```r
Fish.Data
```

```
## # A tibble: 6 x 2
##   Lake_ID Fish.Weight
##   <chr>         <dbl>
## 1 A              232.
## 2 A              320.
## 3 B              283.
## 4 B              297.
## 5 C              237.
## 6 C              229.
```

```r
Lake.Data
```

```
## # A tibble: 3 x 5
##   Lake_ID Lake_Name      pH  area avg_depth
##   <chr>   <chr>       <dbl> <dbl>     <dbl>
## 1 B       Lake Elaine   6.5    40         8
## 2 C       Mormon Lake   6.3   210        10
## 3 D       Lake Mary     6.1   240        38
```

Notice that each of these tables has a column labeled `Lake_ID`. When we join these two tables, the row that describes lake `A` should be duplicated for each row in the `Fish.Data` that corresponds with fish caught from lake `A`.


```r
full_join(Fish.Data, Lake.Data)
```

```
## Joining, by = "Lake_ID"
```

```
## # A tibble: 7 x 6
##   Lake_ID Fish.Weight Lake_Name      pH  area avg_depth
##   <chr>         <dbl> <chr>       <dbl> <dbl>     <dbl>
## 1 A              232. <NA>         NA      NA        NA
## 2 A              320. <NA>         NA      NA        NA
## 3 B              283. Lake Elaine   6.5    40         8
## 4 B              297. Lake Elaine   6.5    40         8
## 5 C              237. Mormon Lake   6.3   210        10
## 6 C              229. Mormon Lake   6.3   210        10
## 7 D               NA  Lake Mary     6.1   240        38
```

Notice that because we didn't have any fish caught in lake `D` and we don't have any Lake information about lake `A`, when we join these two tables, we end up introducing missing observations into the resulting data frame.



```r
left_join(Fish.Data, Lake.Data)
```

```
## Joining, by = "Lake_ID"
```

```
## # A tibble: 6 x 6
##   Lake_ID Fish.Weight Lake_Name      pH  area avg_depth
##   <chr>         <dbl> <chr>       <dbl> <dbl>     <dbl>
## 1 A              232. <NA>         NA      NA        NA
## 2 A              320. <NA>         NA      NA        NA
## 3 B              283. Lake Elaine   6.5    40         8
## 4 B              297. Lake Elaine   6.5    40         8
## 5 C              237. Mormon Lake   6.3   210        10
## 6 C              229. Mormon Lake   6.3   210        10
```


```r
inner_join(Fish.Data, Lake.Data)
```

```
## Joining, by = "Lake_ID"
```

```
## # A tibble: 4 x 6
##   Lake_ID Fish.Weight Lake_Name      pH  area avg_depth
##   <chr>         <dbl> <chr>       <dbl> <dbl>     <dbl>
## 1 B              283. Lake Elaine   6.5    40         8
## 2 B              297. Lake Elaine   6.5    40         8
## 3 C              237. Mormon Lake   6.3   210        10
## 4 C              229. Mormon Lake   6.3   210        10
```

The above examples assumed that the column used to join the two tables was named the same in both tables.  This is good practice to try to do, but sometimes you have to work with data where that isn't the case.  In that situation you can use the `by=c("ColName.A"="ColName.B")` syntax where `ColName.A` represents the name of the column in the first data frame and `ColName.B` is the equivalent column in the second data frame.


## Row summations
Finally, the combination of `gather` and `join` allows me to do some very complex calculations across many columns of a data set.  For example, I might gather up a set of columns, calculate some summary statistics, and then join the result back to original data set.  


```r
grade.book %>%
  group_by(name) %>%
  gather( key=Homework, value=Score, HW.1:HW.4 ) %>%
  summarise( HW.avg = mean(Score) ) %>%
  left_join( grade.book, . )
```

```
## Joining, by = "name"
```

```
##      name HW.1 HW.2 HW.3 HW.4 HW.avg
## 1  Alison    8    5    8    4   6.25
## 2 Brandon    5    3    6    9   5.75
## 3 Charles    9    7    9   10   8.75
```


## Exercises

1. Suppose we are given information about the maximum daily temperature from a weather station in Flagstaff, AZ. The file is available at the GitHub site that this book is hosted on.

    
    ```r
    FlagTemp <-  read.csv(
      'https://github.com/dereksonderegger/570L/raw/master/data-raw/FlagMaxTemp.csv',
       header=TRUE, sep=',')
    ```
    This file is in a wide format, where each row represents a month and the columns X1, X2, ..., X31 represent the day of the month the observation was made. 
    a. Convert data set to the long format where the data has only four columns: `Year`, `Month`, `Day`, `Tmax`.
    b. Calculate the average monthly maximum temperature for each Month in the dataset (So there will be 365 mean maximum temperatures). *You'll probably have some issues taking the mean because there are a number of values that are missing and by default R refuses to take means and sums when there is missing data. The argument `na.rm=TRUE` to `mean()` allows you to force R to remove the missing observations before calculating the mean. Alternatively at some point in your workflow, you could remove rows that include a missing values using `dplyr::drop_na`.* 
    c. Convert the average month maximums back to a wide data format where each line represents a year and there are 12 columns of temperature data (one for each month) along with a column for the year. *There will be a couple of months that still have missing data because the weather station was out of commission for those months and there was NO data for the entire month.*
    
2. A common task is to take a set of data that has multiple categorical variables and create a table of the number of cases for each combination. An introductory statistics textbook contains a dataset summarizing student surveys from several sections of an intro class. The two variables of interest for us are `Gender` and `Year` which are the students gender and year in college.
    a. Download the dataset and correctly order the `Year` variable using the following:
        
        ```r
        Survey <- read.csv('http://www.lock5stat.com/datasets/StudentSurvey.csv', na.strings=c('',' ')) 
        ```
    b. Using some combination of `dplyr` functions, produce a data set with eight rows that contains the number of responses for each gender:year combination. Make sure your table orders the `Year` variable in the correct order of `First Year`, `Sophmore`, `Junior`, and then `Senior`. *You might want to look at the following functions: `dplyr::count` and `dplyr::drop_na`.* 
    c. Using `tidyr` commands, produce a table of the number of responses in the following form:
    
        |   Gender    |  First Year  |  Sophmore  |  Junior   |  Senior   |
        |:-----------:|:------------:|:----------:|:---------:|:---------:|
        |  **Female** |              |            |           |           |  
        |  **Male**   |              |            |           |           | 
    

3. We often are given data in a table format that is easy for a human to parse, but annoying a program. In the following example we have 
[data](https://github.com/dereksonderegger/444/raw/master/data-raw/US_Gov_Budget_1962_2020.xls) 
of US government expenditures from 1962 to 2015. (I downloaded this data from https://obamawhitehouse.archives.gov/omb/budget/Historicals (Table 3.2) on Sept 22, 2019.) 
Our goal is to end up with a data frame with columns for `Function`, `Subfunction`, `Year`, and `Amount`. We'll ignore the "On-budget" and "Off-budget" distinction.
    a) Download the data file, inspect it, and read in the data using the `readxl` package.
    b) Rename the `Function or subfunction` column to `Department`.
    b) Remove any row with Total, Subtotal, On-budget or Off-budget. Also remove the row at the bottom that defines what NA means.
    c) Create a new column for `ID_number` and parse the `Department` column for it.
    d) If all (or just 2015?) the year values are missing, then the `Department` corresponds to `Function` name. Otherwise `Department` corresponds to the `Subfunction`. Create columns for `Function` and `Subfunction`. *Hint: Directly copy `Department` to `Subfunction`. Then using an `ifelse` statement to copy either `NA` or `Department` to `Function` depending on if the 2015 column is an `NA` (use the function `is.na()`). Once you have `Function` with either the `Function` name or an `NA`, you can use the `tidyr::fill` command to replace the NA values with whatever is on the row above. Check out the help files to see how to use it.* 
    e) Remove rows that corresponded to the Function name that have no data. *Hint, you can just check if the `2015` column is `NA`.*
    f) Reshape the data into four columns for Function, Subfunction, Year, and Amount.
    g) Remove rows that have Amount value of `..........`.
    h) Make sure that Year and Amount are numeric. *Hint: it is OK to get rid of the estimate rows for 2016+*
    h) Make a line graph that compares spending for National Defense, Health, Medicare, Income Security, and Social Security for each of the years 2001 through 2015. *Notice you'll have to sum up the sub-functions within each function.*


4. Data table joins are extremely common because effective database design almost always involves having multiple tables for different types of objects. To illustrate both the table joins and the usefulness of multiple tables we will develop a set of data frames that will represent a credit card company's customer data base. We will have tables for Customers, Retailers, Cards, and Transactions.  Below is code that will create and populate these tables.
    
    ```r
    Customers <- tribble(
      ~PersonID, ~Name, ~Street, ~City, ~State,
      1, 'Derek Sonderegger',  '231 River Run', 'Flagstaff', 'AZ',
      2, 'Aubrey Sonderegger', '231 River Run', 'Flagstaff', 'AZ',
      3, 'Robert Buscaglia', '754 Forest Heights', 'Flagstaff', 'AZ',
      4, 'Roy St Laurent', '845 Elk View', 'Flagstaff', 'AZ')
    
    Retailers <- tribble(
      ~RetailID, ~Name, ~Street, ~City, ~State,
      1, 'Kickstand Kafe', '719 N Humphreys St', 'Flagstaff', 'AZ',
      2, 'MartAnnes', '112 E Route 66', 'Flagstaff', 'AZ',
      3, 'REI', '323 S Windsor Ln', 'Flagstaff', 'AZ' )
    
    Cards <- tribble(
      ~CardID, ~PersonID, ~Issue_DateTime, ~Exp_DateTime,
      '9876768717278723',  1,  '2019-9-20 0:00:00', '2022-9-20 0:00:00',
      '5628927579821287',  2,  '2019-9-20 0:00:00', '2022-9-20 0:00:00',
      '7295825498122734',  3,  '2019-9-28 0:00:00', '2022-9-28 0:00:00',
      '8723768965231926',  4,  '2019-9-30 0:00:00', '2022-9-30 0:00:00' ) 
    
    Transactions <- tribble(
      ~CardID, ~RetailID, ~DateTime, ~Amount,
      '9876768717278723', 1, '2019-10-1 8:31:23',    5.68,
      '7295825498122734', 2, '2019-10-1 12:45:45',  25.67,
      '9876768717278723', 1, '2019-10-2 8:26:31',    5.68,
      '9876768717278723', 1, '2019-10-2 8:30:09',    9.23,
      '5628927579821287', 3, '2019-10-5 18:58:57',  68.54,
      '7295825498122734', 2, '2019-10-5 12:39:26',  31.84,
      '8723768965231926', 2, '2019-10-10 19:02:20', 42.83) 
    
    Cards <- Cards %>% 
      mutate( Issue_DateTime = lubridate::ymd_hms(Issue_DateTime),
              Exp_DateTime   = lubridate::ymd_hms(Exp_DateTime) )
    Transactions <- Transactions %>% 
      mutate( DateTime = lubridate::ymd_hms(DateTime))
    ```
    a) Create a table that gives the credit card statement for Derek. It should give all the transactions, the amounts, and the store name. Write your code as if the only initial information you have is the customer's name. *Hint: Do a bunch of table joins, and then filter for the desired customer name.*
    b) Aubrey has lost her credit card on Oct 15, 2019. Close her credit card at 4:28:21 PM and issue her a new credit card in the `Cards` table. *Hint: Using the Aubrey's name, get necessary CardID and PersonID and save those as `cardID` and `personID`. Then update the `Cards` table row that corresponds to the `cardID` so that the expiration date is set to the time that the card is closed. Then insert a new row with the `personID` for Aubrey and a new `CardID` number that you make up.* 
    c) Aubrey is using her new card at Kickstand Kafe on Oct 16, 2019 at 2:30:21 PM for coffee with a charge of $4.98. Generate a new transaction for this action. *Hint: create temporary variables `card`,`retailid`,`datetime`, and `amount` that contain the information for this transaction and then write your code to use those. This way in the next question you can just use the same code but modify the temporary variables. Alternatively, you could write a function that takes in these four values and manipulates the tables in the GLOBAL environment using the `<<-` command to assign a result to a variable defined in the global environment. The reason this is OK is that in a real situation, these data would be stored in a database and we would expect the function to update that database.*
    d) On Oct 17, 2019, some nefarious person is trying to use her OLD credit card at REI. Make sure your code in part (c) first checks to see if the credit card is active before creating a new transaction. Using the same code, verify that the nefarious transaction at REI is denied. *Hint: your check ought to look something like this:*
        
        ```r
        card <- '9876768717278723'
        redailid <- 2
        datetime <- ymd_hms('2019-10-16 14:30:21')
        amount <- 4.98
        
        # If the card is currently valid, this should return exactly 1 row.
        Valid_Cards <- Cards %>% 
          filter(CardID == card, Issue_DateTime <= datetime, datetime <= Exp_DateTime)
        
        # If the transaction is valid, insert the transaction into the table
        if( nrows(Valid_Cards) == 1){
          # Some code to insert the transaction
        }else{
          print('Card Denied')
        }
        ```
    e) Generate a table that gives the credit card statement for Aubrey. It should give all the transactions, amounts, and retailer name for both credit cards she had during this period.


    
  
5. The package `nycflights13` contains information about all the flights that arrived in or left from New York City in 2013. This package contains five data tables, but there are three data tables we will work with. The data table `flights` gives information about a particular flight, `airports` gives information about a particular airport, and `airlines` gives information about each airline. Create a table of all the flights on February 14th by Virgin America that has columns for the carrier, destination, departure time, and flight duration. Join this table with the airports information for the destination. Notice that because the column for the destination airport code doesn't match up between `flights` and `airports`, you'll have to use the `by=c("TableA.Col"="TableB.Col")` argument where you insert the correct names for `TableA.Col` and `TableB.Col`.


