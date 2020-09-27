# (PART\*) Introduction {-}
# Familiarization



As always, there is a [Video Lecture](https://youtu.be/7_kK4QdoA4k) that accompanies this chapter.

R is a open-source program that is commonly used in statistics and machine learning. It runs on almost every platform and is completely free and is available at [www.r-project.org](www.r-project.org). Most cutting-edge statistical research is first available on R. 

The basic editor that comes with R works fairly well, but but it is *strongly* recommended that you run R through the program RStudio which is available at [rstudio.com](http://www.rstudio.org). This is a completely free Integrated Development Environment that works on Macs, Windows and a couple of flavors of Linux. It simplifies a bunch of more annoying aspects of the standard R GUI and supports useful things like tab completion.

R is a script based language, and there isn't a point-and-click interface for data wrangling and statistical modeling. While initially painful, writing scripts leaves a clear and reproducible description of exactly what steps were performed. This is a critical aspect of sharing your methods and results with other students, colleagues, and the world at-large.

## Working within an Rmarkdown File

The first step in any new analysis or project is to create a new Rmarkdown file. This can be done by selecting the 
`File -> New File -> R Markdown...` dropdown option and a menu will appear asking you for the document title, author, and preferred output type. In order to create a PDF, you'll need to have LaTeX installed, but the HTML output nearly always works and I've had good luck with the MS Word output as well.

![](images/RStudio_NewRmarkdown_File.gif)

Once you've created a new Rmarkdown file, you'll be presented with four different panes that you can interact with. 

|  Pane          | Location   | Description                 |
|:-----|:----|------------------------------|
|  Editor        | Top Left    | Where you edit the script. This is where you should write most all of your R code. You should write your code, then execute it from this pane. Because nobody writes code correctly the first time, you'll inevitably make some change, and then execute the code again. This will be repeated until the code finally does what you want.   |
|  Console       | Bottom Left | You can execute code directly in this pane, but the code you write won't be saved. I recommend only writing stuff here if you don't want to keep it. I only type commands in the console when using R as a calculator and I don't want to refer to the result ever again. | 
| Environment    | Top Right   | This displays the current objects that are available to you. I typically keep the `data.frame` I'm working with opened here so that I can see the column names.
|  Miscellaneous | Bottom Left | This pane gives access to the help files, the files in your current working directory, and your plots (if you have it set up to show here.) |


![](images/RStudio_Pane_Descriptions.gif)


The R Markdown is an implementation of the Markdown syntax. It is reasonable to think of a Markdown document as just a text file with some basic structure so that it can easily be converted into either a webpage, pdf, or MS Word document. This syntax was extended to allow use to embed R commands directly into the document. 

Whenever you create a new Rmarkdown document, it is populated with code and comments that attempts to teach new users how to work with Rmarkdown. Critically there are two types of regions:

| Region Type |  Description      |
|:-----------:|:--------------------------------|
| Commentary  | These are the areas with a white background. You can write nearly anything here and in your final document it will be copied over. I typically use these spaces to write commentary and interpretation of my data analysis project.  |
| Code Chunk  |  These are the grey areas. This is where your R code will go. When knitting the document, each code chunk will be run sequentially and the code in each chunk must run. |






The R code in my document is nicely separated from my regular text using the three backticks and an instruction that it is R code that needs to be evaluated. The output of this document looks good as a HTML, PDF, or MS Word document. I have actually created this entire book using RMarkdown. To see what the the Rmarkdown file looks like for any chapter, just click on the pencil icon at the top of the online notes.

While writing an Rmarkdown file, each of the code chunks can be executed in a couple of different ways. 

1. Press the green arrow at the top of the code chunk to run the entire chunk.
2. The run button has several options has several options.
3. There are keyboard shortcuts, on the Mac it is Cmd-Return.

To insert a new code chunk, a user can type it in directly, use the green Insert button, or the keyboard shortcut.

Often we want to produce a nice output document that combines the code, output, and commentary. To do this, you'll "knit" the document which causes all of the R code to be run in a new R session, and then weave together the output into your document. This can be done using the knit button at the top of the Editor Window.




## R file Types

One of the worst things about a pocket calculator is there is no good way to go several steps and easily see what you did or fix a mistake (there is nothing more annoying than re-typing something because of a typo. To avoid these issues I always work with RMarkdown (or script) files instead of typing directly into the console. You will quickly learn that it is impossible to write R code correctly the first time and you'll save yourself a huge amount of work by just embracing this from the beginning. Furthermore, having an R file fully documents how you did your analysis, which can help when writing the methods section of a paper. Finally, having a file makes it easy to re-run an analysis after a change in the data (additional data values, transformed data, or removal of outliers).

There are three common ways to store R commands in some file: scripts, notebooks, and Rmarkdown files. The distinction between the R scripts and the other two is substantial as R scripts just store R commands, but don't make any attempt to save the results in any distinct format.  Both notebooks and Rmarkdown files save the results of an analysis and present the results in a nice readable fashion. I encourage people to use Rmarkdown files over notebooks because the Rmarkdown knitting enforces a reproducible work-flow whereas notebooks can be run out of order. Rmarkdown files are written in a way to combine the R commands, commentary, and the command outputs all together into one coherent document. For most people that use R to advance their research, using Rmarkdown is the most useful.


### R Scripts (.R files)

The first type of file that we'll discuss is a traditional script file. To create a new .R script in RStudio go to `File -> New File -> R Script`. This opens a new window in RStudio where you can type commands and functions as a common text editor. Type whatever you like in the script window and then you can execute the code line by line (using the run button or its keyboard shortcut to run the highlighted region or whatever line the curser is on) or the entire script (using the source button). Other options for what piece of code to run are available under the Code dropdown box.

It often makes your R files more readable if you break a single command up into multiple lines. R scripts will disregard all whitespace (including line breaks) so you can safely spread your command over as multiple lines. Finally, it is useful to leave comments in the script for things such as explaining a tricky step, who wrote the code and when, or why you chose a particular name for a variable. The `#` sign will denote that the rest of the line is a comment and R will ignore it.

An R script for a homework assignment might look something like this:


```r
# Problem 1 
# Calculate the log of a couple of values and make a plot
# of the log function from 0 to 3
log(0)
log(1)
log(2)
x <- seq(.1,3, length=1000)
plot(x, log(x))

# Problem 2
# Calculate the exponential function of a couple of values
# and make a plot of the function from -2 to 2
exp(-2)
exp(0)
exp(2)
x <- seq(-2, 2, length=1000)
plot(x, exp(x))
```
This looks perfectly acceptable as a way of documenting what you did, but this script file doesn't contain the actual results of commands I ran, nor does it show you the plots. Also anytime I want to comment on some output, it needs to be offset with the commenting character `#`. It would be nice to have both the commands and the results merged into one document. This is what the R Markdown file does for us.


### R Markdown (.Rmd files)

When I was a graduate student, I had to tediously copy and past tables of output from the R console and figures I had made into my Microsoft Word document. Far too often I would realize I had made a small mistake in part (b) of a problem and would have to go back, correct my mistake, and then redo all the laborious copying. I often wished that I could write both the code for my statistical analysis and the long discussion about the interpretation all in the same document so that I could just re-run the analysis with a click of a button and all the tables and figures would be updated by magic. Fortunately that magic now exists.

To create a new R Markdown document, we use the `File -> New File -> R Markdown...` dropdown option and a menu will appear asking you for the document title, author, and preferred output type. In order to create a PDF, you'll need to have LaTeX installed, but the HTML output nearly always works and I've had good luck with the MS Word output as well.

The R Markdown is an implementation of the Markdown syntax that makes it extremely easy to write webpages and give instructions for how to do typesetting sorts of things. This syntax was extended to allow use to embed R commands directly into the document. Perhaps the easiest way to understand the syntax is to look at an at the [RMarkdown website](http://rmarkdown.rstudio.com).

The R code in my document is nicely separated from my regular text using the three backticks and an instruction that it is R code that needs to be evaluated. The output of this document looks good as a HTML, PDF, or MS Word document. I have actually created this entire book using RMarkdown. To see what the the Rmarkdown file looks like for any chapter, just click on the pencil icon at the top of the online notes.

While writing an Rmarkdown file, each of the code chunks can be executed in a couple of different ways. 

    1. Press the green arrow at the top of the code chunk to run the entire chunk.
    2. The run button has several options has several options.
    3. There are keyboard shortcuts, on the Mac it is Cmd-Return.

To insert a new code chunk, a user can type it in directly, use the green Insert button, or the keyboard shortcut.

To produce a final output document that you'll present to your boss/colleagues/client where you want to combine the code, output, and commentary you'll "knit" the document which causes all of the R code to be run in a new R session, and then weave together the output into your document. This can be done using the knit button at the top of the Editor Window.


### R Notebooks (.Rmd files)

Notebooks are just very specialized types of Rmarkdown file. Here, the result of each code chunk that is run manually is saved, but when previewing the output, all of the R code is NOT re-run. Therefore it is possible to run the code, then modify the code, and then produce a document where the written code and output do not match up. As a result of this "feature" I strongly discourage the use of notebooks in favor of the standard Rmarkdown files.





## R as a simple calculator

Assuming that you have started R on whatever platform you like, you can use R as a simple calculator. In either your Rmarkdown file code chunk (or just run this in the console), run the following

```r
# Some simple addition
2+3
```

```
## [1] 5
```

In this fashion you can use R as a very capable calculator.


```r
6*8
```

```
## [1] 48
```

```r
4^3
```

```
## [1] 64
```

```r
exp(1)   # exp() is the exponential function
```

```
## [1] 2.718282
```

R has most constants and common mathematical functions you could ever want. `sin()`, `cos()`, and other trigonometry functions are available, as are the exponential and log functions `exp()`, `log()`. The absolute value is given by `abs()`, and `round()` will round a value to the nearest integer. 


```r
pi     # the constant 3.14159265...
```

```
## [1] 3.141593
```

```r
sin(0)
```

```
## [1] 0
```

```r
log(5) # unless you specify the base, R will assume base e
```

```
## [1] 1.609438
```

```r
log(5, base=10)  # base 10
```

```
## [1] 0.69897
```

Whenever I call a function, there will be some arguments that are mandatory, and some that are optional and the arguments are separated by a comma. In the above statements the function `log()` requires at least one argument, and that is the number(s) to take the log of. However, the base argument is optional. If you do not specify what base to use, R will use a default value. You can see that R will default to using base $e$ by looking at the help page (by typing `help(log)` or `?log` at the command prompt).

Arguments can be specified via the order in which they are passed or by naming the arguments. So for the `log()` function which has arguments `log(x, base=exp(1))`. If I specify which arguments are which using the named values, then order doesn't matter.


```r
# Demonstrating order does not matter if you specify
# which argument is which
log(x=5, base=10)   
```

```
## [1] 0.69897
```

```r
log(base=10, x=5)
```

```
## [1] 0.69897
```

But if we don't specify which argument is which, R will decide that `x` is the first argument, and `base` is the second.


```r
# If not specified, R will assume the second value is the base...
log(5, 10)
```

```
## [1] 0.69897
```

```r
log(10, 5)
```

```
## [1] 1.430677
```

When I specify the arguments, I have been using the `name=value` notation and a student might be tempted to use the `<-` notation here. Don't do that as the `name=value` notation is making an association mapping and not a permanent assignment.

## Assignment

We need to be able to assign a value to a variable to be able to use it later. R does this by using an arrow `<-` or an equal sign `=`. While R supports either, for readability, I suggest people pick one assignment operator and stick with it. I personally prefer to use the arrow. Variable names cannot start with a number, may not include spaces, and are case sensitive.


```r
tau <- 2*pi       # create two variables
my.test.var = 5   # notice they show up in 'Environment' tab in RStudio!
tau
```

```
## [1] 6.283185
```

```r
my.test.var
```

```
## [1] 5
```

```r
tau * my.test.var
```

```
## [1] 31.41593
```

As your analysis gets more complicated, you'll want to save the results to a variable so that you can access the results later. *If you don't assign the result to a variable, you have no way of accessing the result.* 

## Vectors

While single values are useful, it is very important that we are able to make groups of values. The most fundamental aggregation of values is called a *vector*. In R, we will require vectors to always be of the same type (e.g. all integers or all character strings). To create a vector, we just need to use the *collection* function `c()`.


```r
x <- c('A','A','B','C')
x
```

```
## [1] "A" "A" "B" "C"
```

```r
y <- c( 4, 3, 8, 10 )
y
```

```
## [1]  4  3  8 10
```

It is very common to have to make sequences of integers, and R has a shortcut to do this. The notation `A:B` will produce a vector starting with A and incrementing by one until we get to B.


```r
2:6
```

```
## [1] 2 3 4 5 6
```

## Packages
One of the greatest strengths about R is that so many people have devloped add-on packages to do some additional function. For example, plant community ecologists have a large number of multivariate methods that are useful but were not part of R.  So Jari Oksanen got together with some other folks and put together a package of functions that they found useful.  The result is the package `vegan`. 

To download and install the package from the Comprehensive R Archive Network (CRAN), you just need to ask RStudio it to install it via the menu `Tools` -> `Install Packages...`. Once there, you just need to give the name of the package and RStudio will download and install the package on your computer. 

Many major analysis types are available via downloaded packages as well as problem sets from various books (e.g. `Sleuth3` or `faraway`) and can be easily downloaded and installed from CRAN via the menu.

Once a package is downloaded and installed on your computer, it is available, but it is not loaded into your current R session by default. The reason it isn't loaded is that there are thousands of packages, some of which are quite large and only used occasionally. So to improve overall performance only a few packages are loaded by default and the you must explicitly load packages whenever you want to use them. You only need to load them once per session/script.


```r
library(vegan)   # load the vegan library
```

For a similar performance reason, many packages do not automatically load their datasets unless explicitly asked. Therefore when loading datasets from a package, you might need to do a *two-step* process of loading the package and then loading the dataset.


```r
library(faraway)       # load the package into memory
```

```
## 
## Attaching package: 'faraway'
```

```
## The following object is masked from 'package:lattice':
## 
##     melanoma
```

```r
data("butterfat")      # load the dataset into memory
```

If you don't need to load any functions from a package and you just want the datasets, you can do it in one step.


```r
data('butterfat', package='faraway')   # just load the dataset, not anything else
butterfat[1:6, ]                       # print out the first 6 rows of the data
```

```
##   Butterfat    Breed    Age
## 1      3.74 Ayrshire Mature
## 2      4.01 Ayrshire  2year
## 3      3.77 Ayrshire Mature
## 4      3.78 Ayrshire  2year
## 5      4.10 Ayrshire Mature
## 6      4.06 Ayrshire  2year
```

Similarly, if I am not using many functions from a package, I might choose call the functions using the notation `package::function()`. This is particularly important when two packages both have functions with the same name and it gets confusing which function you want to use. For example the packages `mosaic` and `dplyr` both have a function `tally`. So if I've already loaded the `dplyr` package but want to use the `mosaic::tally()` function I would use the following:

```r
mosaic::tally( c(0,0,0,1,1,1,1,2) )
```

```
## Registered S3 method overwritten by 'mosaic':
##   method                           from   
##   fortify.SpatialPolygonsDataFrame ggplot2
```

```
## X
## 0 1 2 
## 3 4 1
```

Finally, many researchers and programmers host their packages on GitHub (or equivalent site) and those packages can easily downloaded using tools from the `devtools` package, which can be downloaded from CRAN.


```r
devtools::install_github('dereksonderegger/SiZer')
```

## Finding Help

There are many complicated details about R and nobody knows everything about how each individual package works. As a result, a robust collection of resources has been developed and you are undoubtably not the first person to wonder how to do something. 

### How does this function work?
If you know the function you need, but just don't know how to use it, the built-in documentation is really quite good. Suppose I am interested in how the `rep` function works. We could access the `rep` help page by searching in the help window or from the console via `help(rep)`. The document that is displayed shows what arguments the function expects and what it will return. At the bottom of the help page is often a set of examples demonstrating different ways to use the function. As you get more proficient in R, these help files become quite handy, but initially they feel quite overwhelming. 

### How does this package work?
If a package author really wants their package to be used by a wide audience, they will provide a "vignette". These are a set of notes that explain enough of how a package works to get a user able to utilize the package effectively. This documentation is targetted towards people the know some R, but deep technical knowledge is not expected. Whenever I encounter a new package that might be applicable to me, the first thing I do is see if it has a vignette, and if so, I start reading it. If a package doesn't have a vignette, I'll google "R package XXXX" and that will lead to documentation on CRAN that gives a list of functions in the package.

### How do I do XXX?
Often I find myself asking how to do something but I don't know the function or package to use. In those cases, I will use the coding question and answer site [stackoverflow](http://stackoverflow.com). This is particularly effective and I encourage students to spend some time to understand the solutions presented instead of just copying working code. By digging into why a particular code chunk works, you'll learn all sorts of neat tricks and you'll find yourself utilizing the site less frequently.





## Exercises {#Exercises_Familiarization}

Create an RMarkdown file that solves the following exercises.

1. Calculate $\log\left(6.2\right)$ first using base $e$ and second using base $10$. To figure out how to do different bases, it might be helpful to look at the help page for the `log` function.

2. Calculate the square root of 2 and save the result as the variable named sqrt2. Have R display the decimal value of sqrt2. *Hint: use Google to find the square root function. Perhaps search on the keywords  "R square root function".*

3. This exercise walks you through installing a package with all the datasets used in the textbook *The Statistical Sleuth*.
    a) Install the package `Sleuth3` on your computer using RStudio. 
    b) Load the package using the `library()` command.
    c) Print out the dataset `case0101`

