# Speeding up R




```r
library(microbenchmark)  # for measuring how long stuff takes

library(doMC)      # do multi-core stuff
library(foreach)   # parallelizable for loops

library(tidyverse) # dplyr, ggplot2, etc...

library(faraway)   # some examples
library(boot)
library(caret)
library(glmnet)
```


Eventually if you have large enough data sets, an R user eventually writes code that is slow to execute and needs to be sped up. This chapter tries to lay out common problems and bad habits and shows how to correct them.  However, the correctness and maintainability of code should take precedence over speed. Too often, misguided attempts to obtain efficient code results in an un-maintainable mess that is no faster that the initial code.

Hadley Wickham has a book aimed at advanced R user that describes many of the finer details about R. One section in the book describes his process for building fast, maintainable software projects and if you have the time, I highly suggest reading the on-line version, 
[Advanced R](http://adv-r.had.co.nz/Performance.html).

First we need some way of measuring how long our code took to run. For this we will use the package `microbenchmark`. The idea is that we want to evaluate two or three expressions that solve a problem.


```r
x <- runif(1000)
microbenchmark(
  sqrt(x),         # First expression to compare
  x^(0.5)          # second expression to compare
) %>% print(digits=3)
```

```
## Unit: microseconds
##     expr   min    lq  mean median    uq   max neval
##  sqrt(x)  2.33  2.45  2.81   2.54  2.66  14.4   100
##  x^(0.5) 23.88 24.04 28.66  24.15 25.67 123.1   100
```

What `microbenchmark` does is run the two expressions a number of times and then produces the 5-number summary of those times. By running it multiple times, we account for the randomness associated with a operating system that is also running at the same time.


## Faster for loops?
Often we need to perform some simple action repeatedly. It is natural to write a `for` loop to do the action and we wish to speed the up. In this first case, we will consider having to do the action millions of times and each chunk of computation within the `for` takes very little time.

Consider frame of 4 columns, and for each of $n$ rows, we wish to know which column has the largest value.


```r
make.data <- function(n){
  data <- cbind(
    rnorm(n, mean=5, sd=2),
    rpois(n, lambda = 5),
    rgamma(n, shape = 2, scale = 3),
    rexp(n, rate = 1/5))
  data <- data.frame(data)
  return(data)
}

data <- make.data(100)
```

The way that you might first think about solving this problem is to write a for loop and, for each row, figure it out.


```r
f1 <- function( input ){
  output <- NULL
  for( i in 1:nrow(input) ){
    output[i] <- which.max( input[i,] )
  }
  return(output)
}
```

We might consider that there are two ways to return a value from a function (using the `return` function and just printing it). In fact, I've always heard that using the `return` statement is a touch slower.


```r
f2.noReturn <- function( input ){
  output <- NULL
  for( i in 1:nrow(input) ){
    output[i] <- which.max( input[i,] )
  }
  output
}
```


```r
data <- make.data(100)
microbenchmark(
  f1(data),
  f2.noReturn(data)
) %>% print(digits=3)
```

```
## Unit: milliseconds
##               expr  min   lq mean median   uq  max neval
##           f1(data) 3.71 4.24 5.50   4.58 5.87 15.1   100
##  f2.noReturn(data) 3.69 4.20 5.38   4.73 6.03 10.5   100
```

In fact, it looks like it is a touch slower, but not massively compared to the run-to-run variability. I prefer to use the `return` statement for readability, but if we agree have the last line of code in the function be whatever needs to be returned, readability isn't strongly effected.

We next consider whether it would be faster to allocate the output vector once we figure out the number of rows needed, or just build it on the fly?


```r
f3.AllocOutput <- function( input ){
  n <- nrow(input)
  output <- rep(NULL, n)
  for( i in 1:nrow(input) ){
    output[i] <- which.max( input[i,] )
  }
  return(output)
}
```


```r
microbenchmark(
  f1(data),
  f3.AllocOutput(data)
) %>% print(digits=3)
```

```
## Unit: milliseconds
##                  expr  min   lq mean median   uq  max neval
##              f1(data) 3.63 4.17 5.19   4.77 5.79 13.4   100
##  f3.AllocOutput(data) 3.62 4.07 5.24   4.61 5.54 13.8   100
```
If anything, allocating the size of output first was slower. So given this, we shouldn't feel to bad being lazy and using `output <- NULL` to initiallize things.

## Vectorizing loops
In general, `for` loops in R are very slow and we want to avoid them as much as possible. The `apply` family of functions can be quite helpful for applying a function to each row or column of a matrix or data.frame or to each element of a list.

To test this, instead of a `for` loop, we will use `apply`.

```r
f4.apply <- function( input ){
  output <- apply(input, 1, which.max)
  return(output)
}
```


```r
microbenchmark(
  f1(data),
  f4.apply(data)
) %>% print(digits=3)
```

```
## Unit: microseconds
##            expr  min   lq mean median   uq   max neval
##        f1(data) 3638 4223 5169   4697 5506 10765   100
##  f4.apply(data)  282  340  478    391  516  2959   100
```

This is the type of speed up that matters.  We have a 10-fold speed up in execution time and particularly the maximum time has dropped impressively.

Unfortunately, I have always found the `apply` functions a little cumbersome and I prefer to use `dplyr` instead strictly for readability.


```r
f5.dplyr <- function( input ){
  output <- input %>% 
    mutate( max.col=which.max( c(X1, X2, X3, X4) ) ) 
  return(output$max.col)
}
```


```r
microbenchmark(
  f4.apply(data),
  f5.dplyr(data)
) %>% print(digits=3)
```

```
## Unit: microseconds
##            expr min  lq mean median   uq  max neval
##  f4.apply(data) 313 376  581    474  662 3118   100
##  f5.dplyr(data) 459 579  906    688 1005 5549   100
```

Unfortunately `dplyr` is a lot slower than `apply` in this case. I wonder if the dynamics would change with a larger `n`?


```r
data <- make.data(10000)
microbenchmark(
  f4.apply(data),
  f5.dplyr(data)
) %>% print(digits=3)
```

```
## Unit: microseconds
##            expr   min    lq  mean median    uq   max neval
##  f4.apply(data) 26109 28992 34380  32313 36794 68252   100
##  f5.dplyr(data)   630   948  1143   1097  1252  2593   100
```

```r
data <- make.data(100000)
microbenchmark(
  f4.apply(data),
  f5.dplyr(data)
) %>% print(digits=3)
```

```
## Unit: milliseconds
##            expr    min     lq   mean median     uq    max neval
##  f4.apply(data) 281.73 328.30 449.92 430.17 542.54 786.79   100
##  f5.dplyr(data)   1.97   2.56   3.06   2.82   3.08   9.05   100
```
What just happened? The package `dplyr` is designed to work well for large data sets, and utilizes a modified structure, called a `tibble`, which provides massive benefits for large tables, but at the small scale, the overhead of converting the `data.frame` to a `tibble` overwhelms any speed up.  But because the small sample case is already fast enough to not be noticable, we don't really care about the small `n` case.



## Parallel Processing
Most modern computers have multiple computing cores, and can run muliple processes at the same time. Sometimes this means that you can run multiple programs and switch back and forth easily without lag, but we are now interested in using as many cores as possible to get our statistical calculations completed by using muliple processing cores at the same time. This is referred to as running the process "in parallel" and there are many tasks in modern statistical computing that are "embarrasingly easily parallelized". In particular bootstrapping and cross validation techniques are extremely easy to implement in a parallel fashion.

However, running commands in parallel incurs some overhead cost in set up computation, as well as all the message passing from core to core. For example, to have 5 cores all perform an analysis on a set of data, all 5 cores must have access to the data, and not overwrite any of it. So parallelizing code only makes sense if the individual steps that we pass to each core is of sufficient size that the overhead incurred is substantially less than the time to run the job.

We should think of executing code in parallel as having three major steps:
1. Tell R that there are multiple computing cores available and to set up a useable cluster to which we can pass jobs to.
2. Decide what 'computational chunk' should be sent to each core and distribute all necessary data, libraries, etc to each core.
3. Combine the results of each core back into a unified object.


## Parallelizing for loops

There are a number of packages that allow you to tell R how many cores you have access to.  One of the easiest ways to parallelize a for loop is using a package called `foreach`. The registration of multiple cores is actually pretty easy.


```r
doMC::registerDoMC(cores = 2)  # my laptop only has two cores.
```

We will consider an example that is common in modern statistics. We will examine parallel computing utilizing a bootstrap example where we create bootstrap samples for calculating confidence intervals for regression coefficients.


```r
ggplot(trees, aes(x=Girth, y=Volume)) + geom_point() + geom_smooth(method='lm')
```

<img src="41_SpeedingUpR_files/figure-html/unnamed-chunk-16-1.png" width="672" />

```r
model <- lm( Volume ~ Girth, data=trees)
```


This is how we would do this previously.

```r
# f is a formula
# df is the input data frame
# M is the number of bootstrap iterations
boot.for <- function( f, df, M=999){
  output <- list()
  for( i in 1:100 ){
    # Do stuff
    model.star <- lm( f, data=df %>% sample_frac(1, replace=TRUE) )
    output[[i]] <- model.star$coefficients 
  }

  # use rbind to put the list of results together into a data.frame
  output <- sapply(output, rbind) %>% t() %>% data.frame()
  return(output)
}
```

We will first ask about how to do the same thing using the function `foreach`

```r
# f is a formula
# df is the input data frame
# M is the number of bootstrap iterations
boot.foreach <- function(f, df, M=999){
  output <- foreach( i=1:100 ) %dopar% {
    # Do stuff
    model.star <- lm( f, data=df %>% sample_frac(1, replace=TRUE) )
    model.star$coefficients 
  }
  
  # use rbind to put the list of results together into a data.frame
  output <- sapply(output, rbind) %>% t() %>% data.frame()
  return(output)
}
```
Not much has changed in our code. Lets see which is faster.


```r
microbenchmark(
  boot.for( Volume~Girth, trees ),
  boot.foreach( Volume~Girth, trees )
) %>% print(digits=3)
```

```
## Unit: milliseconds
##                                 expr min  lq mean median  uq max neval
##      boot.for(Volume ~ Girth, trees) 115 134  153    154 159 387   100
##  boot.foreach(Volume ~ Girth, trees) 159 178  209    184 220 733   100
```
In this case, the overhead associated with splitting the job across two cores, copying the data over, and then combining the results back together was more than we saved by using both cores. If the nugget of computation within each pass of the `for` loop was larger, then it would pay to use both cores.


```r
# massiveTrees has 31000 observations
massiveTrees <- NULL
for( i in 1:1000 ){
  massiveTrees <- rbind(massiveTrees, trees)
}
microbenchmark(
  boot.for( Volume~Girth, massiveTrees )  ,
  boot.foreach( Volume~Girth, massiveTrees )
) %>% print(digits=3)
```

```
## Unit: milliseconds
##                                        expr  min   lq mean median   uq
##      boot.for(Volume ~ Girth, massiveTrees) 1181 1270 1449   1439 1580
##  boot.foreach(Volume ~ Girth, massiveTrees)  721  758 1103   1232 1262
##   max neval
##  2179   100
##  2226   100
```

Because we often generate a bunch of results that we want to see as a data.frame, the `foreach` function includes and option to do it for us.

```r
output <- foreach( i=1:100, .combine=data.frame ) %dopar% {
  # Do stuff
  model.star <- lm( Volume ~ Girth, data= trees %>% sample_frac(1, replace=TRUE) )
  model$coefficients 
}
```

It is important to recognize that the data.frame `trees` was utilized inside the `foreach` loop. So when we called the `foreach` loop and distributed the workload across the cores, it was smart enough to distribute the data to each core.  However, if there were functions that we utilized inside the foor loop that came from a packege, we need to tell each core to load the function.


```r
output <- foreach( i=1:1000, .combine=data.frame, .packages='dplyr' ) %dopar% {
  # Do stuff
  model.star <- lm( Volume ~ Girth, data= trees %>% sample_frac(1, replace=TRUE) )
  model.star$coefficients 
}
```


## Parallel Aware Functions

There are many packages that address problems that are "embarassingly easily parallelized" and they will happily work with multiple cores. Methods that rely on resampling certainly fit into this category.

### `boot::boot`
Bootstrapping relys on resampling the dataset and calculating test statistics from each resample.  In R, the most common way to do this is using the package `boot` and we just need to tell the `boot` function, to use the multiple cores available. (Note, we have to have registered the cores first!) 


```r
model <- lm( Volume ~ Girth, data=trees)
my.fun <- function(df, index){
  model.star <- lm( Volume ~ Girth, data= trees[index,] )
  model.star$coefficients 
}
microbenchmark(
  serial   = boot::boot( trees, my.fun, R=1000 ),
  parallel = boot::boot( trees, my.fun, R=1000, 
                         parallel='multicore', ncpus=2 ) 
) %>% print(digits=3)
```

```
## Unit: milliseconds
##      expr min  lq mean median  uq  max neval
##    serial 681 706  790    790 810 1249   100
##  parallel 593 636  682    667 689 1325   100
```

In this case, we had a bit of a spead up, but not a factor of 2.  This is due to the overhead of splitting the job across both cores.

### `caret::train`
The statistical learning package `caret` also handles all the work to do cross validation in a parallel computing environment.  The functions in `caret` have an option `allowParallel` which by default is TRUE, which controls if we should use all the cores. Assuming we have already registered the number of cores, then by default `caret` will use them all. 


```r
library(faraway)
library(caret)
ctrl.serial <- trainControl( method='repeatedcv', number=5, repeats=4,  
                      preProcOptions = c('center','scale'),
                      allowParallel = FALSE)
ctrl.parallel <- trainControl( method='repeatedcv', number=5, repeats=4,  
                      preProcOptions = c('center','scale'),
                      allowParallel = TRUE)
grid <- data.frame( 
  alpha  = 1,  # 1 => Lasso Regression
  lambda = exp(seq(-6, 1, length=50)))

microbenchmark(
  model <- train( lpsa ~ ., data=prostate, method='glmnet',
                  trControl=ctrl.serial, tuneGrid=grid, 
                  lambda = grid$lambda ),
  model <- train( lpsa ~ ., data=prostate, method='glmnet',
                  trControl=ctrl.parallel, tuneGrid=grid, 
                  lambda = grid$lambda )
) %>% print(digits=3)
```

```
## Unit: seconds
##                                                                                                                                 expr
##    model <- train(lpsa ~ ., data = prostate, method = "glmnet",      trControl = ctrl.serial, tuneGrid = grid, lambda = grid$lambda)
##  model <- train(lpsa ~ ., data = prostate, method = "glmnet",      trControl = ctrl.parallel, tuneGrid = grid, lambda = grid$lambda)
##   min   lq mean median   uq  max neval
##  1.13 1.24 1.33   1.25 1.31 3.00   100
##  1.21 1.29 1.37   1.31 1.35 2.66   100
```

Again, we saw only moderate gains by using both cores, however it didn't really cost us anything. Because the `caret` package by default allows parallel processing, it doesn't hurt to just load the `doMC` package and register the number of cores. Even in just the two core case, it is a good habit to get into so that when you port your code to a huge computer with many cores, the only thing to change is how many cores you have access to.
