# Data Types




There are some basic data types that are commonly used. 

1. Integers - These are the integer numbers $\left(\dots,-2,-1,0,1,2,\dots\right)$. To convert a numeric value to an integer you may use the function `as.integer()`.

2. Numeric - These could be any number (whole number or decimal). To convert another type to numeric you may use the function `as.numeric()`.

3. Strings - These are a collection of characters (example: Storing a student's last name). To convert another type to a string, use `as.character()`.

4. Factors - These are strings that can only values from a finite set. For example we might wish to store a variable that records home department of a student. Since the department can only come from a finite set of possibilities, I would use a factor. Factors are categorical variables, but R calls them factors instead of categorical variable. A vector of values of another type can always be converted to a factor using the `as.factor()` command. For converting numeric values to factors, I will often use the function `cut()`.

5. Logicals - This is a special case of a factor that can only take on the values `TRUE` and `FALSE`. (Be careful to always capitalize `TRUE` and `FALSE`. Because R is case-sensitive, TRUE is not the same as true.) Using the function `as.logical()` you can convert numeric values to `TRUE` and `FALSE` where `0` is `FALSE` and anything else is `TRUE`.

Depending on the command, R will coerce your data if necessary, but it is a good habit to do the coercion yourself. If a variable is a number, R will automatically assume that it is continuous numerical variable. If it is a character string, then R will assume it is a factor when doing any statistical analysis. 

To find the type of an object, the `str()` command gives the type, and if the type is complicated, it describes the structure of the object.

## Integers and Numerics

Integers and numerics are exactly what they sound like. Integers can take on whole number values, while numerics can take on any decimal value. The reason that there are two separate data types is that integers require less memory to store than numerics. For most users, the distinction can be ignored.


```r
x <- c(1,2,1,2,1)
# show that x is of type 'numeric'
str(x)   # the str() command show the STRucture of the object
```

```
##  num [1:5] 1 2 1 2 1
```

## Character Strings

In R, we can think of collections of letters and numbers as a single entity called a string. Other programming languages think of strings as vectors of letters, but R does not so you can't just pull off the first character using vector tricks. In practice, there are no limits as to how long string can be.


```r
x <- "Goodnight Moon"

# Notice x is of type character (chr)
str(x)
```

```
##  chr "Goodnight Moon"
```

```r
# R doesn't care if I use single quotes or double quotes, but don't mix them...
y <- 'Hop on Pop!'

# we can make a vector of character strings
Books <- c(x, y, 'Where the Wild Things Are')
Books
```

```
## [1] "Goodnight Moon"            "Hop on Pop!"              
## [3] "Where the Wild Things Are"
```

Character strings can also contain numbers and if the character string is in the correct format for a number, we can convert it to a number.


```r
x <- '5.2'
str(x)     # x really is a character string
```

```
##  chr "5.2"
```

```r
x
```

```
## [1] "5.2"
```

```r
as.numeric(x)
```

```
## [1] 5.2
```

If we try an operation that only makes sense on numeric types (like addition) then R complain unless we first convert it. There are places where R will try to coerce an object to another data type but it happens inconsistently and you should just do the conversion yourself


```r
x+1
```

```
## Error in x + 1: non-numeric argument to binary operator
```

```r
as.numeric(x) + 1
```

```
## [1] 6.2
```

## Factors

Factors are how R keeps track of categorical variables. R does this in a two step pattern. First it figures out how many categories there are and remembers which category an observation belongs two and second, it keeps a vector character strings that correspond to the names of each of the categories. 


```r
# A charater vector
y <- c('B','B','A','A','C')
y
```

```
## [1] "B" "B" "A" "A" "C"
```

```r
# convert the vector of characters into a vector of factors 
z <- factor(y)
str(z)
```

```
##  Factor w/ 3 levels "A","B","C": 2 2 1 1 3
```

Notice that the vector `z` is actually the combination of group assignment vector `2,2,1,1,3` and the group names vector `“A”,”B”,”C”`. So we could convert z to a vector of numerics or to a vector of character strings.

```r
as.numeric(z)
```

```
## [1] 2 2 1 1 3
```

```r
as.character(z)
```

```
## [1] "B" "B" "A" "A" "C"
```

Often we need to know what possible groups there are, and this is done using the `levels()` command.


```r
levels(z)
```

```
## [1] "A" "B" "C"
```

Notice that the order of the group names was done alphabetically, which we did not chose. This ordering of the levels has implications when we do an analysis or make a plot and R will always display information about the factor levels using this order. It would be nice to be able to change the order. Also it would be really nice to give more descriptive names to the groups rather than just the group code in my raw data. I find it is usually easiest to just convert the vector to a character vector, and then convert it back using the `levels=` argument to define the order of the groups, and labels to define the modified names. 


```r
z <- factor(z,                       # vector of data levels to convert 
            levels=c('B','A','C'),   # Order of the levels
            labels=c("B Group", "A Group", "C Group")) # Pretty labels to use
z
```

```
## [1] B Group B Group A Group A Group C Group
## Levels: B Group A Group C Group
```

For the Iris data, the species are ordered alphabetically.  We might want to re-order how they appear in a graphs to place Versicolor first. The `Species` names are not capitalized, and perhaps I would like them to begin with a capital letter. 


```r
iris$Species <- factor( iris$Species,
                        levels = c('versicolor','setosa','virginica'),
                        labels = c('Versicolor','Setosa','Virginica'))
boxplot( Sepal.Length ~ Species, data=iris)
```

<img src="04_DataTypes_files/figure-html/unnamed-chunk-10-1.png" width="672" />

Often we wish to take a continuous numerical vector and transform it into a factor. The function `cut()` takes a vector of numerical data and creates a factor based on your give cut-points. 


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
# Notice that the the outside breakpoints must include all the data points.
# That is, the smallest break must be smaller than all the data, and the largest
# must be larger (or equal) to all the data.
cut(x, breaks = c(0, 2.5, 5.0, 7.5, 10))
```

```
##  [1] (0,2.5]  (0,2.5]  (2.5,5]  (2.5,5]  (2.5,5]  (5,7.5]  (5,7.5] 
##  [8] (7.5,10] (7.5,10] (7.5,10]
## Levels: (0,2.5] (2.5,5] (5,7.5] (7.5,10]
```

```r
# divide x into 3 groups, but give them a nicer
# set of group names
cut(x, breaks=3, labels=c('Low','Medium','High'))
```

```
##  [1] Low    Low    Low    Low    Medium Medium Medium High   High   High  
## Levels: Low Medium High
```

## Logicals

Often I wish to know which elements of a vector are equal to some value, or are greater than something. R allows us to make those tests at the vector level. 

Very often we need to make a comparison and test if something is equal to something else, or if one thing is bigger than another. To test these, we will use the `<`, `<=`, `==`, `>=`, `>`, and `!=` operators. These can be used similarly to 


```r
6 < 10    # 6 less than 10?
```

```
## [1] TRUE
```

```r
6 == 10   # 6 equal to 10?
```

```
## [1] FALSE
```

```r
6 != 10   # 6 not equal to 10?
```

```
## [1] TRUE
```

where we used 6 and 10 just for clarity. The result of each of these is a logical value (a `TRUE` or `FALSE`). In most cases these would be variables you had previously created and were using. 

Suppose I have a vector of numbers and I want to get all the values greater than 16. Using the `>` comparison, I can create a vector of logical values that tells me if the specified value is greater than 16. The `which()` takes a vector of logicals and returns the indices that are true. 


```r
x <- -10:10     # a vector of 20 values, (11th element is the 0)
x
```

```
##  [1] -10  -9  -8  -7  -6  -5  -4  -3  -2  -1   0   1   2   3   4   5   6
## [18]   7   8   9  10
```

```r
x > 0           # a vector of 20 logicals
```

```
##  [1] FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE
## [12]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE
```

```r
which( x > 0 )  # which vector elements are > 0
```

```
##  [1] 12 13 14 15 16 17 18 19 20 21
```

```r
x[ which(x>0) ] # Grab the elements > 0 
```

```
##  [1]  1  2  3  4  5  6  7  8  9 10
```


On function I find to be occasionally useful is the `is.element(el, set)` function which allows me to figure out which elements of a vector are one of a set of possibilities. For example, I might want to know which elements of the `letters` vector are vowels.


```r
letters  # this is all 26 english lowercase letters
```

```
##  [1] "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q"
## [18] "r" "s" "t" "u" "v" "w" "x" "y" "z"
```

```r
vowels <- c('a','e','i','o','u')
which( is.element(letters, vowels) )
```

```
## [1]  1  5  9 15 21
```

This shows me the vowels occur at the 1st, 5th, 9th, 15th, and 21st elements of the alphabet.

Often I want to make multiple comparisons. For example given a bunch of students and a vector of their GPAs and another vector of their major, maybe I want to find all undergraduate Forestry majors with a GPA greater than 3.0. Then, given my set of university students, I want ask two questions: Is their major Forestry, and is their GPA greater than 3.0. So I need to combine those two logical results into a single logical that is true if both questions are true. 

The command `&` means “and” and `|` means “or”. We can combine two logical values using these two similarly: 

```r
TRUE  & TRUE     # both are true so combo so result is true
```

```
## [1] TRUE
```

```r
TRUE  & FALSE    # one true and one false so result is false
```

```
## [1] FALSE
```

```r
FALSE & FALSE    # both are false so the result is false
```

```
## [1] FALSE
```

```r
TRUE  | TRUE     # at least one is true -> TRUE
```

```
## [1] TRUE
```

```r
TRUE  | FALSE    # at least one is true -> TRUE
```

```
## [1] TRUE
```

```r
FALSE | FALSE    # neither is true -> FALSE
```

```
## [1] FALSE
```

## Exercises
1. Create a vector of character strings with six elements
    
    ```r
    test <- c('red','red','blue','yellow','blue','green')
    ```
    and then
    a. Transform the `test` vector just you created into a factor.
    b. Use the `levels()` command to determine the levels (and order) of the factor you just created. 
    c. Transform the factor you just created into integers. Comment on the relationship between the integers and the order of the levels you found in part (b).
    d. Use some sort of comparison to create a vector that identifies which factor elements are the red group.

2. Given the vector of ages, 
    
    ```r
    ages <- c(17, 18, 16, 20, 22, 23)
    ```
    create a factor that has levels `Minor` or `Adult` where any observation greater than or equal to 18 qualifies as an adult. Also, make sure that the order of the levels is `Minor` first and `Adult` second.

3. Suppose we vectors that give a students name, their GPA, and their major. We want to come up with a list of forestry students with a GPA of greater than 3.0.
    
    ```r
    Name <- c('Adam','Benjamin','Caleb','Daniel','Ephriam', 'Frank','Gideon')
    GPA <- c(3.2, 3.8, 2.6, 2.3, 3.4, 3.7, 4.0)
    Major <- c('Math','Forestry','Biology','Forestry','Forestry','Math','Forestry')
    ```
    a) Create a vector of TRUE/FALSE values that indicate whether the students GPA is greater than 3.0.
    b) Create a vector of TRUE/FALSE values that indicate whether the students' major is forestry.
    c) Create a vector of TRUE/FALSE values that indicates if a student has a GPA greater than 3.0 and is a forestry major.
    d) Convert the vector of TRUE/FALSE values in part (c) to integer values using the `as.numeric()` function. Which numeric value corresponds to TRUE?
    e) Sum (using the `sum()` function) the vector you created to count the number of students with GPA > 3.0 and are a forestry major.

4. Make two variables, and call them `a` and `b` where `a=2` and `b=10`. I want to think of these as defining an interval. 
    a. Define the vector `x <- c(-1, 5, 12)`
    b. Using the `&`, come up with a comparison that will test if the value of `x` is in the interval $[a,b]$. (We want the test to return `TRUE` if $a\le x\le b$). That is, test if `a` is less than `x` and if `x` is less than `b`. Confirm that for x defined above you get the correct vector of logical values. 
    c. Similarly make a comparison that tests if `x` is outside the interval $[a,b]$ using the `|` operator. That is, test if `x < a` or `x > b`. I want the test to return TRUE is x is less than a or if x is greater than b. Confirm that for x defined above you get the correct vector of logical values. 
    
    
