# Matrices, Data Frames, and Lists



## Matrices

We often want to store numerical data in a square or rectangular format and mathematicians will call these “matrices”. These will have two dimensions, rows and columns. To create a matrix in R we can create it directly using the `matrix()` command which requires the data to fill the matrix with, and optionally, some information about the number of rows and columns:


```r
W <- matrix( c(1,2,3,4,5,6), nrow=2, ncol=3 )
W
```

```
##      [,1] [,2] [,3]
## [1,]    1    3    5
## [2,]    2    4    6
```
Notice that because we only gave it six values, the information the number of columns is redundant and could be left off and R would figure out how many columns are needed.  Next notice that the order that R chose to fill in the matrix was to fill in the first column then the second, and then the third. If we wanted to fill the matrix in order of the rows first, then we'd use the optional `byrow=TRUE` argument.


```r
W <- matrix( c(1,2,3,4,5,6), nrow=2, byrow=TRUE )
W
```

```
##      [,1] [,2] [,3]
## [1,]    1    2    3
## [2,]    4    5    6
```


The alternative to the `matrix()` command  is we could create two columns as individual vectors and just push them together. Or we could have made three rows and lump them by rows instead. To do this we'll use a group of functions that bind vectors together. To join two column vectors together, we'll use `cbind` and to bind rows together we'll use the `rbind` function 

```r
a <- c(1,2,3)
b <- c(4,5,6)
cbind(a,b)  # Column Bind:  a,b are columns in resultant matrix 
```

```
##      a b
## [1,] 1 4
## [2,] 2 5
## [3,] 3 6
```

```r
rbind(a,b)  # Row Bind:     a,b are   rows  in resultant matrix    
```

```
##   [,1] [,2] [,3]
## a    1    2    3
## b    4    5    6
```


Notice that doing this has provided R with some names for the individual rows and columns. I can change these using the commands `colnames()` and `rownames()`. 


```r
M <- matrix(1:6, nrow=3, ncol=2, byrow=TRUE) 
colnames(M) <- c('Column1', 'Column2')       # set column labels
rownames(M) <- c('Row1', 'Row2','Row3')      # set row labels
M
```

```
##      Column1 Column2
## Row1       1       2
## Row2       3       4
## Row3       5       6
```

This is actually a pretty peculiar way of setting the *attributes* of the object `M` because it looks like we are evaluating a function and assigning some value to the function output.  Yes it is weird, but R was developed in the 70s and it seemed like a good idea at the time.

Accessing a particular element of a matrix is done in a similar manner as with vectors, using the `[ ]` notation, but this time we must specify which row and which column. Notice that this scheme always is `[row, col]`.


```r
M1 <- matrix(1:6, nrow=3, ncol=2)
M1
```

```
##      [,1] [,2]
## [1,]    1    4
## [2,]    2    5
## [3,]    3    6
```

```r
M1[1,2]     # Grab row 1, column 2 value
```

```
## [1] 4
```

```r
M1[1, 1:2]  # Grab row 1, and columns 1 and 2.
```

```
## [1] 1 4
```


I might want to grab a single row or a single column out of a matrix, which is sometimes referred to as taking a slice of the matrix. I could figure out how long that vector is, but often I'm too lazy. Instead I can just specify the specify the particular row or column I want.


```r
M1
```

```
##      [,1] [,2]
## [1,]    1    4
## [2,]    2    5
## [3,]    3    6
```

```r
M1[1, ]    # grab the 1st row 
```

```
## [1] 1 4
```

```r
M1[ ,2]    # grab second column (the spaces are optional...)
```

```
## [1] 4 5 6
```


## Data Frames

Matrices are great for mathematical operations, but I also want to be able to store data that is numerical. For example I might want to store a categorical variable such as manufacturer brand. To generalize our concept of a matrix to include these types of data, we will create a structure called a `data.frame`. These are very much like a simple Excel spreadsheet where each column represents a different trait or measurement type and each row will represent an individual.

Perhaps the easiest way to create a data frame is to just type the columns of data


```r
data <- data.frame(
  Name  = c('Bob','Jeff','Mary'), 	
  Score = c(90, 75, 92)
)
# Show the data.frame 
data
```

```
##   Name Score
## 1  Bob    90
## 2 Jeff    75
## 3 Mary    92
```

Because a data frame feels like a matrix, R also allows matrix notation for accessing particular values. 

  Format  |   Result
--------- | --------------------------------------
`[a,b]`   |  Element in row `a` and column `b`
`[a,]`    |  All of row `a`
`[,b]`    |  All of column `b`

Because the columns have meaning and we have given them column names, it is desirable to want to access an element by the name of the column as opposed to the column number.In large Excel spreadsheets I often get annoyed trying to remember which column something was in and muttering “Was total biomass in column P or Q?” A system where I could just name the column Total.Biomass and be done with it is much nicer to work with and I make fewer dumb mistakes.


```r
data$Name       # The $-sign means to reference a column by its label
```

```
## [1] Bob  Jeff Mary
## Levels: Bob Jeff Mary
```

```r
data$Name[2]    # Notice that data$Name results in a vector, which I can manipulate
```

```
## [1] Jeff
## Levels: Bob Jeff Mary
```

I can mix the `[ ]` notation with the column names. The following is also acceptable:


```r
data[, 'Name']   # Grab the column labeled 'Name'
```

```
## [1] Bob  Jeff Mary
## Levels: Bob Jeff Mary
```


The next thing we might wish to do is add a new column to a preexisting data frame. There are two ways to do this. First, we could use the `cbind()` function to bind two data frames together. Second we could reference a new column name and assign values to it.


```r
Second.score <- data.frame(Score2=c(41,42,43))  # another data.frame
data <-  cbind( data, Second.score )            # squish them together
data
```

```
##   Name Score Score2
## 1  Bob    90     41
## 2 Jeff    75     42
## 3 Mary    92     43
```

```r
# if you assign a value to a column that doesn't exist, R will create it
data$Score3 <- c(61,62,63) # the Score3 column will created
data
```

```
##   Name Score Score2 Score3
## 1  Bob    90     41     61
## 2 Jeff    75     42     62
## 3 Mary    92     43     63
```

Data frames are very commonly used and many commonly used functions will take a `data=` argument and all other arguments are assumed to be in the given data frame. Unfortunately this is not universally supported by all functions and you must look at the help file for the function you are interested in.

Data frames are also very restricive in that the shape of the data must be rectangular. If I try to create a new column that doesn't have enough rows, R will complain.


```r
data$Score4 <- c(1,2)
```

```
## Error in `$<-.data.frame`(`*tmp*`, Score4, value = c(1, 2)): replacement has 2 rows, data has 3
```



## Lists

Data frames are quite useful for storing data but sometimes we'll need to store a bunch of different pieces of information and it won't fit neatly as a data frame. The most general form of a data structure is called a list. This can be thought of as a vector of objects where there is no requirement for each element to be the same type of object.

Consider that I might need to store information about person. For example, suppose that I want make an object that holds information about my immediate family. This object should have my spouse's name (just one name) as well as my siblings. But because I have many siblings, I want the siblings to be a vector of names. Likewise I might also include my pets, but we don't want any requirement that the number of pets is the same as the number of siblings (or spouses!). 


```r
wife <- 'Aubrey'
sibs <- c('Tina','Caroline','Brandon','John')
pets <- c('Beau','Tess','Kaylee')
Derek <- list(Spouse=wife, Siblings=sibs, Pets=pets) # Create the list
str(Derek) # show the structure of object
```

```
## List of 3
##  $ Spouse  : chr "Aubrey"
##  $ Siblings: chr [1:4] "Tina" "Caroline" "Brandon" "John"
##  $ Pets    : chr [1:3] "Beau" "Tess" "Kaylee"
```

Notice that the object `Derek` is a list of three elements. The first is the single string containing my wife's name. The next is a vector of my siblings' names and it is a vector of length four. Finally the vector of pets' names is only of length three.

To access any element of this list we can use an indexing scheme similar to matrices and vectors. The only difference is that we'll use two square brackets instead of one.


```r
Derek[[ 1 ]]    # First element of the list is Spouse!
```

```
## [1] "Aubrey"
```

```r
Derek[[ 3 ]]    # Third element of the list is the vector of pets
```

```
## [1] "Beau"   "Tess"   "Kaylee"
```


There is a second way I can access elements. For data frames it was convenient to use the notation `DataFrame$ColumnName` and we will use the same convention for lists. Actually a data frame is just a list with the requirement that each list element is a vector and all vectors are of the same length. To access my pets names we can use the following notation:


```r
Derek$Pets         # Using the '$' notation
```

```
## [1] "Beau"   "Tess"   "Kaylee"
```

```r
Derek[[ 'Pets' ]]  # Using the '[[ ]]' notation
```

```
## [1] "Beau"   "Tess"   "Kaylee"
```


To add something new to the list object, we can just make an assignment in a similar fashion as we did for `data.frame` and just assign a value to a slot that doesn't (yet!) exist.


```r
Derek$Spawn <- c('Elise', 'Casey')
```


We can also add extremely complicated items to my list. Here we'll add a `data.frame` as another list element.


```r
# Recall that we previous had defined a data.frame called "data"
Derek$RandomDataFrame <- data  # Assign it to be a list element
str(Derek)
```

```
## List of 5
##  $ Spouse         : chr "Aubrey"
##  $ Siblings       : chr [1:4] "Tina" "Caroline" "Brandon" "John"
##  $ Pets           : chr [1:3] "Beau" "Tess" "Kaylee"
##  $ Spawn          : chr [1:2] "Elise" "Casey"
##  $ RandomDataFrame:'data.frame':	3 obs. of  4 variables:
##   ..$ Name  : Factor w/ 3 levels "Bob","Jeff","Mary": 1 2 3
##   ..$ Score : num [1:3] 90 75 92
##   ..$ Score2: num [1:3] 41 42 43
##   ..$ Score3: num [1:3] 61 62 63
```

Now we see that the list `Derek` has five elements and some of those elements are pretty complicated.  In fact, I could happily have lists of lists and have a very complicated nesting structure.

The place that most users will run into lists is that the output of many statistical procedures will return the results in a list object. When a user asks R to perform a regression, the output returned is a list object, and we'll need to grab particular information from that object afterwards. For example, the output from a t-test in R is a list:


```r
x <- c(5.1, 4.9, 5.6, 4.2, 4.8, 4.5, 5.3, 5.2)   # some toy data
results <- t.test(x, alternative='less', mu=5)   # do a t-test
str(results)                                     # examine the resulting object
```

```
## List of 9
##  $ statistic  : Named num -0.314
##   ..- attr(*, "names")= chr "t"
##  $ parameter  : Named num 7
##   ..- attr(*, "names")= chr "df"
##  $ p.value    : num 0.381
##  $ conf.int   : num [1:2] -Inf 5.25
##   ..- attr(*, "conf.level")= num 0.95
##  $ estimate   : Named num 4.95
##   ..- attr(*, "names")= chr "mean of x"
##  $ null.value : Named num 5
##   ..- attr(*, "names")= chr "mean"
##  $ alternative: chr "less"
##  $ method     : chr "One Sample t-test"
##  $ data.name  : chr "x"
##  - attr(*, "class")= chr "htest"
```


We see that result is actually a list with 9 elements in it. To access the p-value we could use:

```r
results$p.value
```

```
## [1] 0.3813385
```

If I ask R to print the object `results`, it will hide the structure from you and print it in a “pretty” fashion because there is a `print` function defined specifically for objects created by the `t.test()` function.


```r
results
```

```
## 
## 	One Sample t-test
## 
## data:  x
## t = -0.31399, df = 7, p-value = 0.3813
## alternative hypothesis: true mean is less than 5
## 95 percent confidence interval:
##      -Inf 5.251691
## sample estimates:
## mean of x 
##      4.95
```



## Exercises

1. In this problem, we will work with the matrix 

    \[ \left[\begin{array}{ccccc}
    2 & 4 & 6 & 8 & 10\\
    12 & 14 & 16 & 18 & 20\\
    22 & 24 & 26 & 28 & 30
    \end{array}\right]\]
    
    a) Create the matrix in two ways and save the resulting matrix as `M`.
        i. Create the matrix using some combination of the `seq()` and `matrix()` commands.
        ii. Create the same matrix by some combination of multiple `seq()` commands and either the `rbind()` or `cbind()` command. 

    b) Extract the second row out of `M`.
    c) Extract the element in the third row and second column of `M`.

2. Create and manipulate a data frame.
    a) Create a `data.frame` named `my.trees` that has the following columns:
        + Girth = c(8.3, 8.6, 8.8, 10.5, 10.7, 10.8, 11.0)
        + Height= c(70, 65, 63, 72, 81, 83, 66)
        + Volume= c(10.3, 10.3, 10.2, 16.4, 18.8, 19.7, 15.6)
    b) Extract the third observation (i.e. the third row)
    c) Extract the Girth column referring to it by name (don't use whatever order you placed the columns in).
    d) Print out a data frame of all the observations *except* for the fourth observation. (i.e. Remove the fourth observation/row.)
    e) Use the `which()` command to create a vector of row indices that have a `girth` greater than 10. Call that vector `index`.
    f) Use the `index` vector to create a small data set with just the large girth trees.
    g) Use the `index` vector to create a small data set with just the small girth trees.
    
3. Create and manipulate a list.
    a) Create a list named my.test with elements
        + x = c(4,5,6,7,8,9,10)
        + y = c(34,35,41,40,45,47,51)
        + slope = 2.82
        + p.value = 0.000131
    b) Extract the second element in the list.
    c) Extract the element named `p.value` from the list.

4. The function `lm()` creates a linear model, which is a general class of model that includes both regression and ANOVA. We will call this on a data frame and examine the results. For this problem, there isn't much to figure out, but rather the goal is to recognize the data structures being used in common analysis functions.

    a) There are many data sets that are included with R and its packages. One of which is the `trees` data which is a data set of $n=31$ cherry trees. Load this dataset into your current workspace using the command:
    
    ```r
    data(trees)     # load trees data.frame
    ```
    b) Examine the data frame using the `str()` command. Look at the help file for the data using the command `help(trees)` or `?trees`.

    c) Perform a regression relating the volume of lumber produced to the girth and height of the tree using the following command
    
    ```r
    m <- lm( Volume ~ Girth + Height, data=trees)
    ```

    d) Use the str() command to inspect `m`. Extract the model coefficients from this list.

    e) The list m can be passed to other functions. For example, the function `summary()` will take the list and recognize that it was produced by the `lm()` function and produce a summary table in the manner that we are used to seeing. Produce that summary table using the command
    
    ```r
    summary(m)
    ```
    
    ```
    ## 
    ## Call:
    ## lm(formula = Volume ~ Girth + Height, data = trees)
    ## 
    ## Residuals:
    ##     Min      1Q  Median      3Q     Max 
    ## -6.4065 -2.6493 -0.2876  2.2003  8.4847 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) -57.9877     8.6382  -6.713 2.75e-07 ***
    ## Girth         4.7082     0.2643  17.816  < 2e-16 ***
    ## Height        0.3393     0.1302   2.607   0.0145 *  
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 3.882 on 28 degrees of freedom
    ## Multiple R-squared:  0.948,	Adjusted R-squared:  0.9442 
    ## F-statistic:   255 on 2 and 28 DF,  p-value: < 2.2e-16
    ```



