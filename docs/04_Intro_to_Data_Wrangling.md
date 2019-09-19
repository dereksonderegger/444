# Data Wrangling 





```r
library(tidyverse, quietly = TRUE)   # loading ggplot2 and dplyr
```

  
Many of the tools to manipulate data frames in R were written without a consistent syntax and are difficult use together. To remedy this, Hadley Wickham (the writer of `ggplot2`) introduced a package called plyr which was quite useful. As with many projects, his first version was good but not great and he introduced an improved version that works exclusively with data.frames called `dplyr` which we will investigate. The package `dplyr` strives to provide a convenient and consistent set of functions to handle the most common data frame manipulations and a mechanism for chaining these operations together to perform complex tasks. 

The Dr Wickham has put together a very nice introduction to the package that explains in more detail how the various pieces work and I encourage you to read it at some point. [http://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html].

One of the aspects about the `data.frame` object is that R does some simplification for you, but it does not do it in a consistent manner. Somewhat obnoxiously character strings are always converted to factors and subsetting might return a `data.frame` or a `vector` or a `scalar`.  This is fine at the command line, but can be problematic when programming. Furthermore, many operations are pretty slow using `data.frame`. To get around this, Dr Wickham introduced a modified version of the `data.frame` called a `tibble`. A `tibble` is a `data.frame` but with a few extra bits. For now we can ignore the differences.

The pipe command `%>%` allows for very readable code. The idea is that the `%>%` operator works by translating the command `a %>% f(b)` to the expression `f(a,b)`. This operator works on any function and was introduced in the `magrittr` package. The beauty of this comes when you have a suite of functions that takes input arguments of the same type as their output. 

For example, if we wanted to start with `x`, and first apply function `f()`, then `g()`, and then `h()`, the usual R command would be `h(g(f(x)))` which is hard to read because you have to start reading at the *innermost* set of parentheses. Using the pipe command `%>%`, this sequence of operations becomes `x %>% f() %>% g() %>% h()`.


|     Written         |  Meaning       |
|:-------------------:|:--------------:|
| `a %>% f(b)`        |   `f(a,b)`     |
| `b %>% f(a, .)`     |   `f(a, b)`    |
| `x %>% f() %>% g()` |  `g( f(x) )`   |

In `dplyr`, all the functions below take a _data set as its first argument_ and _outputs an appropriately modified data set_. This will allow me to chain together commands in a readable fashion. The pipe command works with any function, not just the `dplyr` functions and I often find myself using it all over the place.


## Verbs

The foundational operations to perform on a data set are:

* Subsetting - Returns a  with only particular columns or rows

    – `select` - Selecting a subset of columns by name or column number.

    – `filter` - Selecting a subset of rows from a data frame based on logical expressions.

    – `slice` - Selecting a subset of rows by row number.

* `arrange` - Re-ordering the rows of a data frame.

* `mutate` - Add a new column that is some function of other columns.

* `summarise` - calculate some summary statistic of a column of data. This collapses a set of rows into a single row.

Each of these operations is a function in the package `dplyr`. These functions all have a similar calling syntax, the first argument is a data set, subsequent arguments describe what to do with the input data frame and you can refer to the columns without using the `df$column` notation. All of these functions will return a data set.

### Subsetting

These function allows you select certain columns and rows of a data frame.

#### `select()`

Often you only want to work with a small number of columns of a data frame and want to be able to *select* a subset of columns or perhaps remove a subset. The function to do that is `dplyr::select()`  

```r
# Create a tiny data frame that is easy to see what is happening
grades <- data.frame(
  l.name = c('Cox', 'Dorian', 'Kelso', 'Turk'),
  Exam1 = c(93, 89, 80, 70),
  Exam2 = c(98, 70, 82, 85),
  Final = c(96, 85, 81, 92) )

grades
```

```
##   l.name Exam1 Exam2 Final
## 1    Cox    93    98    96
## 2 Dorian    89    70    85
## 3  Kelso    80    82    81
## 4   Turk    70    85    92
```


I could select the columns Exam columns by hand, or by using an extension of the `:` operator

```r
# select( grades,  Exam1, Exam2 )   # from `grades`, select columns Exam1, Exam2
grades %>% select( Exam1, Exam2 )   # Exam1 and Exam2
```

```
##   Exam1 Exam2
## 1    93    98
## 2    89    70
## 3    80    82
## 4    70    85
```

```r
grades %>% select( Exam1:Final )    # Columns Exam1 through Final
```

```
##   Exam1 Exam2 Final
## 1    93    98    96
## 2    89    70    85
## 3    80    82    81
## 4    70    85    92
```

```r
grades %>% select( -Exam1 )         # Negative indexing by name drops a column
```

```
##   l.name Exam2 Final
## 1    Cox    98    96
## 2 Dorian    70    85
## 3  Kelso    82    81
## 4   Turk    85    92
```

```r
grades %>% select( 1:2 )            # Can select column by column position
```

```
##   l.name Exam1
## 1    Cox    93
## 2 Dorian    89
## 3  Kelso    80
## 4   Turk    70
```

The `select()` command has a few other tricks. There are functional calls that describe the columns you wish to select that take advantage of pattern matching. I generally can get by with `starts_with()`, `ends_with()`, and `contains()`, but there is a final operator `matches()` that takes a regular expression.

```r
grades %>% select( starts_with('Exam') )   # Exam1 and Exam2
```

```
##   Exam1 Exam2
## 1    93    98
## 2    89    70
## 3    80    82
## 4    70    85
```

```r
grades %>% select( starts_with('Exam'), starts_with('F') )
```

```
##   Exam1 Exam2 Final
## 1    93    98    96
## 2    89    70    85
## 3    80    82    81
## 4    70    85    92
```

The `dplyr::select` function is quite handy, but there are several other packages out there that have a `select` function and we can get into trouble with loading other packages with the same function names.  If I encounter the `select` function behaving in a weird manner or complaining about an input argument, my first remedy is to be explicit about it is the `dplyr::select()` function by appending the package name at the start. 

#### `filter()`

It is common to want to select particular rows where we have some logical expression to pick the rows. 

```r
# select students with Final grades greater than 90
grades %>% filter(Final > 90)
```

```
##   l.name Exam1 Exam2 Final
## 1    Cox    93    98    96
## 2   Turk    70    85    92
```

You can have multiple logical expressions to select rows and they will be logically combined so that only rows that satisfy all of the conditions are selected. The logicals are joined together using `&` (and) operator or the `|` (or) operator and you may explicitly use other logicals. For example a factor column type might be used to select rows where type is either one or two via the following: `type==1 | type==2`.

```r
# select students with Final grades above 90 and
# average score also above 90
grades %>% filter(Exam2 > 90, Final > 90)
```

```
##   l.name Exam1 Exam2 Final
## 1    Cox    93    98    96
```

```r
# we could also use an "and" condition
grades %>% filter(Exam2 > 90 & Final > 90)
```

```
##   l.name Exam1 Exam2 Final
## 1    Cox    93    98    96
```

#### `slice()`

When you want to filter rows based on row number, this is called slicing.

```r
# grab the first 2 rows
grades %>% slice(1:2)
```

```
##   l.name Exam1 Exam2 Final
## 1    Cox    93    98    96
## 2 Dorian    89    70    85
```

### `arrange()`

We often need to re-order the rows of a data frame. For example, we might wish to take our grade book and sort the rows by the average score, or perhaps alphabetically. The `arrange()` function does exactly that. The first argument is the data frame to re-order, and the subsequent arguments are the columns to sort on. The order of the sorting column determines the precedent... the first sorting column is first used and the second sorting column is only used to break ties.

```r
grades %>% arrange(l.name)
```

```
##   l.name Exam1 Exam2 Final
## 1    Cox    93    98    96
## 2 Dorian    89    70    85
## 3  Kelso    80    82    81
## 4   Turk    70    85    92
```

The default sorting is in ascending order, so to sort the grades with the highest scoring person in the first row, we must tell arrange to do it in descending order using `desc(column.name)`.

```r
grades %>% arrange(desc(Final))
```

```
##   l.name Exam1 Exam2 Final
## 1    Cox    93    98    96
## 2   Turk    70    85    92
## 3 Dorian    89    70    85
## 4  Kelso    80    82    81
```

In a more complicated example, consider the following data and we want to order it first by Treatment Level and secondarily by the y-value. I want the Treatment level in the default ascending order (Low, Medium, High), but the y variable in descending order.

```r
# make some data
dd <- data.frame(
  Trt = factor(c("High", "Med", "High", "Low"),        
               levels = c("Low", "Med", "High")),
  y = c(8, 3, 9, 9),      
  z = c(1, 1, 1, 2)) 
dd
```

```
##    Trt y z
## 1 High 8 1
## 2  Med 3 1
## 3 High 9 1
## 4  Low 9 2
```

```r
# arrange the rows first by treatment, and then by y (y in descending order)
dd %>% arrange(Trt, desc(y))
```

```
##    Trt y z
## 1  Low 9 2
## 2  Med 3 1
## 3 High 9 1
## 4 High 8 1
```

### mutate()

I often need to create a new column that is some function of the old columns. In the `dplyr` package, this is a `mutate` command. To do ths, we give a `mutate( NewColumn = Function of Old Columns )` command.


```r
# Modify the grades data frame and replace the old version with the new 
# that contains the newly created "average" column
grades <- grades %>% 
  mutate( average = (Exam1 + Exam2 + Final)/3 )
```

You can do multiple calculations within the same `mutate()` command, and you can even refer to columns that were created in the same `mutate()` command.

```r
grades %>% mutate( 
  average = (Exam1 + Exam2 + Final)/3,
  grade = cut(average, c(0, 60, 70, 80, 90, 100),  # cut takes numeric variable
                       c( 'F','D','C','B','A')) )  # and makes a factor
```

```
##   l.name Exam1 Exam2 Final  average grade
## 1    Cox    93    98    96 95.66667     A
## 2 Dorian    89    70    85 81.33333     B
## 3  Kelso    80    82    81 81.00000     B
## 4   Turk    70    85    92 82.33333     B
```



### summarise()

By itself, this function is quite boring, but will become useful later on. Its purpose is to calculate summary statistics using any or all of the data columns. Notice that we get to chose the name of the new column. The way to think about this is that we are collapsing information stored in multiple rows into a single row of values.

```r
# calculate the mean of exam 1
grades %>% summarise( mean.E1=mean(Exam1) )
```

```
##   mean.E1
## 1      83
```

We could calculate multiple summary statistics if we like.

```r
# calculate the mean and standard deviation 
grades %>% summarise( mean.E1=mean(Exam1), stddev.E1=sd(Exam1) )
```

```
##   mean.E1 stddev.E1
## 1      83  10.23067
```



## Split, apply, combine

Aside from unifying the syntax behind the common operations, the major strength of the `dplyr` package is the ability to split a data frame into a bunch of sub-data frames, apply a sequence of one or more of the operations we just described, and then combine results back together. We'll consider data from an experiment from spinning wool into yarn. This experiment considered two different types of wool (A or B) and three different levels of tension on the thread. The response variable is the number of breaks in the resulting yarn. For each of the 6 `wool:tension` combinations, there are 9 replicated observations per `wool:tension` level.

```r
data(warpbreaks)
str(warpbreaks)
```

```
## 'data.frame':	54 obs. of  3 variables:
##  $ breaks : num  26 30 54 25 70 52 51 26 67 18 ...
##  $ wool   : Factor w/ 2 levels "A","B": 1 1 1 1 1 1 1 1 1 1 ...
##  $ tension: Factor w/ 3 levels "L","M","H": 1 1 1 1 1 1 1 1 1 2 ...
```

<img src="04_Intro_to_Data_Wrangling_files/figure-html/unnamed-chunk-17-1.png" width="672" />

The first we must do is to create a data frame with additional information about how to break the data into sub-data frames. In this case, I want to break the data up into the 6 wool-by-tension combinations. Initially we will just figure out how many rows are in each wool-by-tension combination.

```r
# group_by:  what variable(s) shall we group on.
# n() is a function that returns how many rows are in the 
#   currently selected sub-dataframe
warpbreaks %>% 
  group_by( wool, tension) %>%    # grouping
  summarise(n = n() )             # how many in each group
```

```
## # A tibble: 6 x 3
## # Groups:   wool [2]
##   wool  tension     n
##   <fct> <fct>   <int>
## 1 A     L           9
## 2 A     M           9
## 3 A     H           9
## 4 B     L           9
## 5 B     M           9
## 6 B     H           9
```


The `group_by` function takes a data.frame and returns the same data.frame, but with some extra information so that any subsequent function acts on each unique combination defined in the `group_by`.  If you wish to remove this behavior, use `group_by()` to reset the grouping to have no grouping variable.

Using the same `summarise` function, we could calculate the group mean and standard deviation for each wool-by-tension group.

```r
warpbreaks %>% 
  group_by(wool, tension) %>%
  summarise( n           = n(),             # I added some formatting to show the
             mean.breaks = mean(breaks),    # reader I am calculating several
             sd.breaks   = sd(breaks))      # statistics.
```

```
## # A tibble: 6 x 5
## # Groups:   wool [2]
##   wool  tension     n mean.breaks sd.breaks
##   <fct> <fct>   <int>       <dbl>     <dbl>
## 1 A     L           9        44.6     18.1 
## 2 A     M           9        24        8.66
## 3 A     H           9        24.6     10.3 
## 4 B     L           9        28.2      9.86
## 5 B     M           9        28.8      9.43
## 6 B     H           9        18.8      4.89
```

If instead of summarizing each split, we might want to just do some calculation and the output should have the same number of rows as the input data frame. In this case I'll tell `dplyr` that we are mutating the data frame instead of summarizing it. For example, suppose that I want to calculate the residual value $$e_{ijk}=y_{ijk}-\bar{y}_{ij\cdot}$$ where $\bar{y}_{ij\cdot}$ is the mean of each `wool:tension` combination.

```r
warpbreaks %>% 
   group_by(wool, tension) %>%                 # group by wool:tension
   mutate(resid = breaks - mean(breaks)) %>%   # mean(breaks) of the group!
   head(  )                                    # show the first couple of rows
```

```
## # A tibble: 6 x 4
## # Groups:   wool, tension [1]
##   breaks wool  tension  resid
##    <dbl> <fct> <fct>    <dbl>
## 1     26 A     L       -18.6 
## 2     30 A     L       -14.6 
## 3     54 A     L         9.44
## 4     25 A     L       -19.6 
## 5     70 A     L        25.4 
## 6     52 A     L         7.44
```



## Exercises

1. The dataset `ChickWeight` tracks the weights of 48 baby chickens (chicks) feed four different diets.
    a. Load the dataset using  
        
        ```r
        data(ChickWeight)
        ```
    b. Look at the help files for the description of the columns.
    c) Remove all the observations except for observations from day 10 or day 20. The tough part in this instruction is disguishing between "and" and "or".  Obviously there are no observations that occur from both day 10 AND day 20.  Google 'R logical operators' to get an introducton to those.
    d) Calculate the mean and standard deviation of the chick weights for each diet group on days 10 and 20. 

2. The OpenIntro textbook on statistics includes a data set on body dimensions. 
    a) Load the file using 
        
        ```r
        Body <- read.csv('http://www.openintro.org/stat/data/bdims.csv')
        ```
    b) The column sex is coded as a 1 if the individual is male and 0 if female. This is a non-intuitive labeling system. Create a new column `sex.MF` that uses labels Male and Female. _Hint: the ifelse() command will be very convenient here. The ifelse() command in R functions similarly to the same command in Excel._
    c) The columns `wgt` and `hgt` measure weight and height in kilograms and centimeters (respectively). Use these to calculate the Body Mass Index (BMI) for each individual where 
    $$BMI=\frac{Weight\,(kg)}{\left[Height\,(m)\right]^{2}}$$ 
    d) Double check that your calculated BMI column is correct by examining the summary statistics of the column (e.g. `summary(Body)`). BMI values should be between 18 to 40 or so.  Did you make an error in your calculation?  
    e) The function `cut` takes a vector of continuous numerical data and creates a factor based on your give cut-points. 
        
        ```r
        # Define a continuous vector to convert to a factor
        x <- 1:10
        
        # divide range of x into three groups of equal length
        cut(x, breaks=3)
        ```
        
        ```
        ##  [1] (0.991,4] (0.991,4] (0.991,4] (0.991,4] (4,7]     (4,7]     (4,7]    
        ##  [8] (7,10]    (7,10]    (7,10]   
        ## Levels: (0.991,4] (4,7] (7,10]
        ```
        
        ```r
        # divide x into four groups, where I specify all 5 break points 
        cut(x, breaks = c(0, 2.5, 5.0, 7.5, 10))
        ```
        
        ```
        ##  [1] (0,2.5]  (0,2.5]  (2.5,5]  (2.5,5]  (2.5,5]  (5,7.5]  (5,7.5] 
        ##  [8] (7.5,10] (7.5,10] (7.5,10]
        ## Levels: (0,2.5] (2.5,5] (5,7.5] (7.5,10]
        ```
        
        ```r
        # (0,2.5] (2.5,5] means 2.5 is included in first group
        # right=FALSE changes this to make 2.5 included in the second  
        
        # divide x into 3 groups, but give them a nicer
        # set of group names
        cut(x, breaks=3, labels=c('Low','Medium','High'))
        ```
        
        ```
        ##  [1] Low    Low    Low    Low    Medium Medium Medium High   High   High  
        ## Levels: Low Medium High
        ```
        Create a new column of in the data frame that divides the age into decades (10-19, 20-29, 30-39, etc). Notice the oldest person in the study is 67.
        
        ```r
        Body <- Body %>%
          mutate( Age.Grp = cut(age,
                                breaks=c(10,20,30,40,50,60,70),
                                right=FALSE))
        ```
    f) Find the average BMI for each Sex-by-Age combination.
    
    