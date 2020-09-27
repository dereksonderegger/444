# Importing Data



Reading data from external sources is necessary. It is most common for data to be in a data-frame like storage, such as a MS Excel workbook, so we will concentrate on reading data into a `data.frame`. 

In the typical way data is organized, we think of each column of data representing some trait or variable that we might be interested in. In general, we might wish to investigate the relationship between variables. In contrast, the rows of our data represent a single object on which the column traits are measured. For example, in a grade book for recording students scores throughout the semester, their is one row for every student and columns for each assignment. A greenhouse experiment dataset will have a row for every plant and columns for treatment type and biomass.


## Working directory
One concept that will be important is to recognize that every time you start up RStudio, it picks an appropriate working directory. This is the directory where it will first look for script files or data files. By default when you double click on an R script or Rmarkdown file to launch RStudio, it will set the working directory to be the directory that the file was in. Similarly, when you knit an Rmarkdown file, the working directory will be set to the directory where the Rmarkdown file is. For both of these reasons, I always program my scripts assuming that paths to any data files will be relative to where where my Rmarkdown file is. To set the working directory explicitly, you can use the GUI tools `Session -> Set Working Directory...`.

The functions that we will use in this lab all accept a character string that denotes the location of the file. This location could be a web address, it could be an absolute path on your computer, or it could be a path relative to the location of your Rmarkdown file.

+-------------------------+----------------------------------------------------+
| `'MyFile.csv'`          | Look in the working directory for `MyFile.csv`.    |
+-------------------------+----------------------------------------------------+
| `'MyFolder/Myfile.csv'` | In the working directory, there is a subdirectory  |
|                         | called `MyFolder` and inside that folder there is  |
|                         | a filed called `MyFile.csv`.                       |
+-------------------------+----------------------------------------------------+


## Comma Separated Data

To consider how data might be stored, we first consider the simplest file format... the comma separated values file. In this file time, each of the “cells” of data are separated by a comma. For example, the data file storing scores for three students might be as follows:

    Able, Dave, 98, 92, 94
    Bowles, Jason, 85, 89, 91
    Carr, Jasmine, 81, 96, 97

Typically when you open up such a file on a computer with Microsoft Excel installed, Excel will open up the file assuming it is a spreadsheet and put each element in its own cell. However, you can also open the file using a more primitive program (say Notepad in Windows, TextEdit on a Mac) you'll see the raw form of the data.

Having just the raw data without any sort of column header is problematic (which of the three exams was the final??). Ideally we would have column headers that store the name of the column.  

    LastName, FirstName, Exam1, Exam2, FinalExam
    Able, Dave, 98, 92, 94
    Bowles, Jason, 85, 89, 91
    Carr, Jasmine, 81, 96, 97


To see another example, open the “Body Fat” dataset from the Lock$^{5}$ introductory text book at the website [http://www.lock5stat.com/datasets/BodyFat.csv]. 
The first few rows of the file are as follows:

    Bodyfat,Age,Weight,Height,Neck,Chest,Abdomen,Ankle,Biceps,Wrist
    32.3,41,247.25,73.5,42.1,117,115.6,26.3,37.3,19.7
    22.5,31,177.25,71.5,36.2,101.1,92.4,24.6,30.1,18.2
    22,42,156.25,69,35.5,97.8,86,24,31.2,17.4
    12.3,23,154.25,67.75,36.2,93.1,85.2,21.9,32,17.1
    20.5,46,177,70,37.2,99.7,95.6,22.5,29.1,17.7

To make R read in the data arranged in this format, we need to tell R three things:

1. Where does the data live? Often this will be the name of a file on your computer, but the file could just as easily live on the internet (provided your computer has internet access).

2. Is the first row data or is it the column names? 

3. What character separates the data? Some programs store data using tabs to distinguish between elements, some others use white space. R's mechanism for reading in data is flexible enough to allow you to specify what the separator is.

The primary function that we'll use to read data from a file and into R is the function `read.table()`. This function has many optional arguments but the most commonly used ones are outlined in the table below.

|  Argument    |     Default       |    What it does                                   |
|:------------:|:-----------------:|:--------------------------------------------------|
| `file`       |                   | A character string denoting the file location     |
| `header`     |   FALSE           | Is the first line column headers?                 |
| `sep`        |    " "            | What character separates columns.  " " == any whitespace |
| `skip`       |    0             | The number of lines to skip before reading data. This is useful when there are lines of text that describe the data or aren't actual data           |
| `na.strings` |  'NA'             | What values represent missing data. Can have multiple. E.g.  `c('NA', -9999)`                  |
|  `quote`     |  "  and '         | For character strings, what characters represent quotes.           |


To read in the “Body Fat” dataset we could run the R command:


```r
BodyFat <- read.table( 
  file   = 'http://www.lock5stat.com/datasets/BodyFat.csv',  # where the data lives
  header = TRUE,                                             # first line is column names
  sep    = ',' )                                             # Data is sparated by commas

str(BodyFat)
```

```
## 'data.frame':	100 obs. of  10 variables:
##  $ Bodyfat: num  32.3 22.5 22 12.3 20.5 22.6 28.7 21.3 29.9 21.3 ...
##  $ Age    : int  41 31 42 23 46 54 43 42 37 41 ...
##  $ Weight : num  247 177 156 154 177 ...
##  $ Height : num  73.5 71.5 69 67.8 70 ...
##  $ Neck   : num  42.1 36.2 35.5 36.2 37.2 39.9 37.9 35.3 42.1 39.8 ...
##  $ Chest  : num  117 101.1 97.8 93.1 99.7 ...
##  $ Abdomen: num  115.6 92.4 86 85.2 95.6 ...
##  $ Ankle  : num  26.3 24.6 24 21.9 22.5 22 23.7 21.9 24.8 25.2 ...
##  $ Biceps : num  37.3 30.1 31.2 32 29.1 35.9 32.1 30.7 34.4 37.5 ...
##  $ Wrist  : num  19.7 18.2 17.4 17.1 17.7 18.9 18.7 17.4 18.4 18.7 ...
```

Looking at the help file for `read.table()` we see that there are variants such as `read.csv()` that sets the default arguments to header and sep more intelligently. Also, there are many options to customize how R responds to different input.

## MS Excel

Commonly our data is stored as a MS Excel file. There are two approaches you could use to import the data into R.

1. From within Excel, export the worksheet that contains your data as a comma separated values (.csv) file and proceed using the tools in the previous section.

2. Use functions within R that automatically convert the worksheet into a .csv file and read it in. One package that works nicely for this is the `readxl` package. 

I generally prefer using option 2 because all of my collaborators can't live without Excel and I've resigned myself to this. However if you have complicated formulas in your Excel file, it is often times safer to export it as a .csv file to guarantee the data imported into R is correct. Furthermore, other spreadsheet applications (such as Google sheets) requires you to export the data as a .csv file so it is good to know both paths.

Because R can only import a complete worksheet, the desired data worksheet must be free of notes to yourself about how the data was collected, preliminary graphics, or other stuff that isn't the data. I find it very helpful to have a worksheet in which I describe the sampling procedure and describe what each column means (and give the units!), then a second worksheet where the actual data is, and finally a third worksheet where my “Excel Only” collaborators have created whatever plots and summary statistics they need. 

The simplest package for importing Excel files seems to be the package `readxl`. Another package that does this is the XLConnect which does the Excel -> .csv conversion using Java. Another package the works well is the `xlsx` package, but it also requires Java to be installed. The nice thing about these two packages is that they also allow you to write Excel files as well. The RODBC package allows R to connect to various databases and it is possible to make it consider an Excel file as an extremely crude database. 

The `readxl` package provides a function `read_exel()` that allows us to specify which sheet within the Excel file to read and what character specifies missing data (it assumes a blank cell is missing data if you don't specifying anything). For the most part, the arguments are the same as `read.csv` but below are the most important changes and additions.

|  Argument     |     Meaning                 |
|:-------------:|:----------------------------|
| `path`        | The file argument is called `path` instead. |
| `sheet`       | Which sheet to read. Either the sheet name or sheet number.|
| `range`       | The cell range to read from. E.g. "A5:G98"  |

From GitHub, download the files `Example_1.xls`, through `Example_5.xls`, from the directory [https://github.com/dereksonderegger/444/tree/master/data-raw]. Place these files in the same directory that you store your course work or make a subdirectory data to store the files in. Make sure that the working directory that RStudio is using is that same directory (Session -> Set Working Directory). 


```r
# load the library that has the read.xls function. 
library(readxl)

# Where does the data live relative to my current working location? 
#
# In my directory where this Rmarkdown file lives, I have made a subdirectory 
#    named 'data-raw' to store all the data files. So the path to my data
#    file will be 'data-raw/Example_1.xls'.
# If you stored the files in the same directory as your RMarkdown script, you
#    don't have to add any additional information and you can just tell it the
#    file name 'Example_1.xls'
# Alternatively I could give the full path to this file starting at the root
#    directory which, for me, is '~/GitHub/444/data-raw/Example_1.xls'
#    but for Windows users it might be 'Z:/444/Lab9/Example_1.xls'. This looks
#    odd because Windows usually uses a backslash to represent the directory
#    structure, but a backslash has special meaning in R and so it wants 
#    to separate directories via forward slashes.

# read the first worksheet of the Example_1 file
data.1 <- read_excel( 'data-raw/Example_1.xls'  )   # relative to this Rmarkdown file
data.1 <- read_excel('~/GitHub/444/data-raw/Example_1.xls')  # absolute path

# read the second worksheet where the second worksheet is named 'data'
data.2 <- read_excel('data-raw/Example_2.xls', sheet=2     )   
data.2 <- read_excel('data-raw/Example_2.xls', sheet='data')   
```


There is one additional problem that shows up while reading in Excel files. Blank columns often show up in Excel files because at some point there was some text in a cell that got deleted but a space remains and Excel still thinks there is data in the column. To fix this, you could find the cell with the space in it, or you can select a bunch of columns at the edge and delete the entire columns. Alternatively, you could remove the column after it is read into R using typical data frame manipulation tools.

Open up the file `Example_4.xls` in Excel and confirm that the data sheet has name columns out to carb. Read in the data frame using the following code:


```r
data.4 <- read_excel('./data-raw/Example_4.xls', sheet='data')   # Extra Column Example
```

```
## New names:
## * `` -> ...13
## * `` -> ...14
```

```r
str(data.4)
```

```
## tibble [34 × 14] (S3: tbl_df/tbl/data.frame)
##  $ model: chr [1:34] "Mazda RX4" "Mazda RX4 Wag" "Datsun 710" "Hornet 4 Drive" ...
##  $ mpg  : num [1:34] 21 21 22.8 21.4 18.7 18.1 14.3 24.4 22.8 19.2 ...
##  $ cyl  : num [1:34] 6 6 4 6 8 6 8 4 4 6 ...
##  $ disp : num [1:34] 160 160 108 258 360 ...
##  $ hp   : num [1:34] 110 110 93 110 175 105 245 62 95 123 ...
##  $ drat : num [1:34] 3.9 3.9 3.85 3.08 3.15 2.76 3.21 3.69 3.92 3.92 ...
##  $ wt   : num [1:34] 2.62 2.88 2.32 3.21 3.44 ...
##  $ qsec : num [1:34] 16.5 17 18.6 19.4 17 ...
##  $ vs   : num [1:34] 0 0 1 1 0 1 0 1 1 1 ...
##  $ am   : num [1:34] 1 1 1 0 0 0 0 0 0 0 ...
##  $ gear : num [1:34] 4 4 4 3 3 3 3 4 4 4 ...
##  $ carb : num [1:34] 4 4 1 1 2 1 4 2 2 4 ...
##  $ ...13: logi [1:34] NA NA NA NA NA NA ...
##  $ ...14: logi [1:34] NA NA NA NA NA NA ...
```

We notice that after reading in the data, there is an additional column that just has missing data (the NA stands for not available which means that the data is missing) and a row with just a single blank. Go back to the Excel file and go to row 4 column N and notice that the cell isn't actually blank, there is a space. Delete the space, save the file, and then reload the data into R. You should notice that the extra columns are now gone. 

## Multiple files
There are several cases where our data is stored in multiple files and we want to read them in.  If the data sources all have an identical column format, we can just stack the data frames together using the `rbind` command.


```r
files <- c('file1.csv', 'file2.csv', 'file3.csv')  # Files to be read in.
data <- NULL   # what will the output data frame be named
for( file in files){  # for each element of our files vector
  temp.data <- read.csv(file)     # read in the file 
  data <- rbind(data, temp.data)  # Append it to our final data set
}
```

In the example above, we might need to modify the `read.csv()` command, but fortunately it isn't too hard to combine a `for` loop with set of statements to read in the dataset. 

## Exercises  {#Exercises_DataImport}

1. Download from GitHub the data file [Example_5.xls](https://github.com/dereksonderegger/444/raw/master/data-raw/Example_5.xls). Open it in Excel and figure out which sheet of data we should import into R. At the same time figure out how many initial rows need to be skipped. Import the data set into a data frame and show the structure of the imported data using the `str()` command. Make sure that your data has $n=31$ observations and the three columns are appropriately named. 


2. Download from GitHub the data file [Example_3.xls](https://github.com/dereksonderegger/444/raw/master/data-raw/Example_3.xls). Import the data set into a data frame and show the structure of the imported data using the `tail()` command which shows the last few rows of a data table. Make sure the Tesla values are `NA` where appropriate.


