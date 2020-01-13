# Data Wrangling Process



```r
# Chapter packages we will use
library(tidyverse)
```

## Introduction
The process of data wrangling often seems very situation dependent and there isn't a unifying process. However this isn't completely true. The process can be thought of as having four distinct steps.

| **Step**  |  **Result Name** | Description                    |
|:---------:|:-----------:|:------------------------------------------------------------------------|
| Import    | `data_raw`   | Get the data into R somehow. The structure of the data is just however it came in. |
| Tidy      | `data_tidy`  | Restructure the data so that each row is an observation, and each column is a variable.|
| Clean     | `data`       | Correct variable types, consistent and useful labels, validation and correction.   |
| Use       | `data_small` | Sub-setting the full data into a smaller set that addresses a particular question. |


I tend to break my data cleaning scripts into three chunks and the cleaning script looks something like this:

```r
# Script for reading in Flagstaff Weather Data
Weather_raw <- read_csv('~/GitHub/444/data-raw/Flagstaff_Temp.csv')

Weather_tidy <- Weather_raw %>% ...

Weather <- Weather_tidy %>% ...
```

In the above script the `...` represent a bunch commands that I pipe together. The clean data set doesn't include any `_modifier` tag because that clean data set is the one that I want to save and then subsequently use in any analysis. 

In many real world examples, the data wrangling work is concentrated in only one first three steps. Typically you might be able to skip one or more steps, but I would encourage using the naming convention above so that it is clear where the skipped steps are and what step you are on.

## Tidying 

The terminology of "tidy data" popularized by Hadley Wickham and his introduction to the concept lives in a [vignette](https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html) in the `tidyr` package. I highly recommend reading Hadley's introduction as well as what I present here. 

Data is usually described as "tidy" if it satisfies the following:

1. Each row represents an observation.
2. Each column represents a variable.
3. Each table of data represents a different type of observational unit.

The difficult part is recognizing what constitutes an observation and what constitutes a variable. Often I like to think that the observations represent a noun and each now has multiple variables that adjectives that describe the noun. In particular I think that the attributes should be applicable to every single observation. If your data has a large number of `NA` values, that is a symptom of storing the data in a messy (non-tidy) format. 

Suppose I have an address book where I keep email addresses, phone numbers, and other contact information.  However, because different people have several different types of contact information, it would be a bad idea to have one row per person because then we'd need a column for work email, personal email, home phone, work phone, cell phone, twitter handle, reddit user name, etc. Instead, store the information with a single row representing a particular contact.


```
## # A tibble: 5 x 3
##   Person Type       Value                    
##   <chr>  <chr>      <chr>                    
## 1 Derek  Work Email derek.sonderegger@nau.edu
## 2 Derek  Cell Phone 970-867-5309             
## 3 Derek  Twitter    @D_Sonderegger           
## 4 Derek  Github     dereksonderegger         
## 5 Mom    Home Phone 555-867-5309
```

For a more challenging example, suppose we have grade book where we've stored students scores for four different homework assignments.


```
##      name HW.1 HW.2 HW.3 HW.4
## 1  Alison    8    5    8    4
## 2 Brandon    5    3    6    9
## 3 Charles    9    7    9   10
```

In this case we are considering each row to represent a student and each variable represents homework score. An alternative representation would be for each row to represent a single score.


```
##       name Assignment Score
## 1   Alison       HW.1     8
## 2  Brandon       HW.1     5
## 3  Charles       HW.1     9
## 4   Alison       HW.2     5
## 5  Brandon       HW.2     3
## 6  Charles       HW.2     7
## 7   Alison       HW.3     8
## 8  Brandon       HW.3     6
## 9  Charles       HW.3     9
## 10  Alison       HW.4     4
## 11 Brandon       HW.4     9
## 12 Charles       HW.4    10
```

Either representation is fine in this case, because each student should have the same number of assignments. However, if I was combining grade books from multiple times I've taught the course, the first option won't work because sometimes I assign projects and sometimes not. So the tidy version of the data would be to have a table `scores` where each row represents a single assignment from a particular student.

## Cleaning

The cleaning step is usually highly dependent on the data set content. This step involves 

1. Making sure every variable has the right type. For example, make sure that dates are dates, not character strings. 
2. Fix factor labels and sort order.
3. Verify numeric values are reasonable.
4. Create any calculated variables we need.

Most of our data frame manipulation tools are designed to work with tidy data. As a result, cleaning is most easily done after the data set structure has been tidied. Therefore,I recommend first performing the reshaping tidying step and *then* perform the cleaning. 



