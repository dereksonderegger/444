# Web API Data Queries




```r
library(tidyverse)
library(censusapi)
library(jsonlite)  
```


With a standard database connection, there is quite a lot we can do. For example we could insert incorrect rows into tables, or even [delete whole tables](https://xkcd.com/327/). Many organizations that deliver data to clients require a way to minimize the types of data base actions that are allowed.  For example, consider Twitter. Twitter clients need to connect to the Twitter database, sign in, and download the latest tweets from whomever they follow and accept a database input that adds a tweet from the signed in user. However, the client must not be able to update or insert tweets from somebody else, and to prevent Denial-Of-Service attacks, there should be some limit to the number of rows of information that we ask for. Furthermore, the client shouldn't have to remember the details of how the data is stored and changes to the database configuration should be completely invisible to clients.

Application Program Interfaces (APIs) are the specification for how two programs will interface. An API that is well thought out and documented is wonderful to use. In a data query situation, the API will define how we submit a query and the manner in which the result will be returned. Web API queries are usually designed so that 


## Web Interface
An example from the US Census Bureau's web interface 

http://api.census.gov/data/2018/pep/population?get=DATE_CODE,DATE_DESC,DENSITY,POP,GEONAME,STATE&for=state:*&DATE_CODE=1

1. The base website is http://api.census.gov/data/2018/pep/population. This is effectively specifying which table we want to query from.
2. Modifiers are included after the `?` and different modifers are separated by `&`
3. `get=` section defines the variables that you want 
4. The `for=state:*` denotes that we want all of the states. `state:01` would have been just Alabama.
5. The `DATE_CODE=1` indicates that I just want the first estimate. 

When you go to this website, the database will read the modifier list, do the appropriate database query, and return the result via a webpage that has a very simple structure that is easy to parse into a table.

The hard part about Web APIs is understanding which tables are available, and what each covariate means. For the US Census Bureau, the [developers](https://www.census.gov/data/developers/) page is a great place to start. 


## R API Interfaces
While it is helpful to understand how the web API works, it would be nice to not have to worry about some of the fiddly aspects of parsing the result into a data frame. There are many R packages that provide a convenient interface to some database API. For our US Census Bureau example, we'll use the  R package `censusapi`. You should read the [documentation](https://github.com/hrecht/censusapi) as well.

The Census Bureau wants to identify which developers are accessing their data and you are required to sign up for a [Census Key](https://api.census.gov/data/key_signup.html). It is easy to give them your email and they'll email you a character string that you'll use for the rest of these examples.




```r
# I got a Census API key from https://api.census.gov/data/key_signup.html 
# and saved it as Census_Key and use that in all the following examples...
# 
# This query is the example query first given in the censusapi vignette.
library(censusapi)
getCensus(name = "timeseries/healthins/sahie",
	vars = c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT"), 
	region = "state:01",
	time = 2017,
	key = Census_Key)
```

```
##   time state    NAME IPRCAT                IPR_DESC PCTUI_PT
## 1 2017    01 Alabama      0             All Incomes     11.0
## 2 2017    01 Alabama      1      <= 200% of Poverty     18.3
## 3 2017    01 Alabama      2      <= 250% of Poverty     17.3
## 4 2017    01 Alabama      3      <= 138% of Poverty     19.4
## 5 2017    01 Alabama      4      <= 400% of Poverty     14.5
## 6 2017    01 Alabama      5 138% to 400% of Poverty     11.5
```

This is now super easy to query the Census database, except that I have NO IDEA what API names (ie tables) are available and I have no clue what variables I just downloaded. We need to get a better sense of what data sets are available.

A good place to start is the [developer datasets](https://www.census.gov/data/developers/data-sets.html). In particular I'm interested in both county are municipality level population estimates over time as well as information from the American Community Survey (ACS).

### Population Estimates 
The Census Bureau's Population Estimation Program (PEP) is responsible for population estimates. On the [Census Population API page](https://www.census.gov/data/developers/data-sets/popest-popproj/popest.html), it looks like I need to use the `pep/population` tables. 

http://api.census.gov/data/2018/pep/population?get=DATE_CODE,DATE_DESC,DENSITY,POP,GEONAME,STATE&for=state:*&DATE_CODE=1


```r
# Code to grab county level population levels.
County_Populations <- getCensus(name = "pep/population",
  vars = c('STATE','COUNTY','GEONAME','DATE_CODE','DATE_DESC','POP'),
  vintage = '2018',
  region = 'county:*', # States are in alphabetical order...
	key = Census_Key,
  DATE_CODE=1  # 1st year in the decade, leave this out to get each year 2010-2018
  )

County_Populations %>% head(6)  
```

```
##   state county STATE COUNTY                 GEONAME DATE_CODE
## 1    01    001    01    001 Autauga County, Alabama         1
## 2    01    003    01    003 Baldwin County, Alabama         1
## 3    01    005    01    005 Barbour County, Alabama         1
## 4    01    007    01    007    Bibb County, Alabama         1
## 5    01    009    01    009  Blount County, Alabama         1
## 6    01    011    01    011 Bullock County, Alabama         1
##                    DATE_DESC    POP DATE_CODE_1
## 1 4/1/2010 Census population  54571           1
## 2 4/1/2010 Census population 182265           1
## 3 4/1/2010 Census population  27457           1
## 4 4/1/2010 Census population  22915           1
## 5 4/1/2010 Census population  57322           1
## 6 4/1/2010 Census population  10914           1
```


I was looking for population divided up by Race and Sex and it took awhile to figure out that I want to use PEP's Demographic Characteristics Estimates by Age Groups tables `pep/charagegroups`. From there I looked at some of the examples and variables.


```r
County_Populations_by_AgeGender <- getCensus(name = "pep/charagegroups",
  vars = c('GEONAME','DATE_CODE','AGEGROUP','SEX','DATE_DESC','POP'),
  vintage = '2018',
  region = 'state:01', # States are in alphabetical order...
	key = Census_Key)

County_Populations_by_AgeGender %>% head(6)
```

```
##   state GEONAME DATE_CODE AGEGROUP SEX                  DATE_DESC     POP
## 1    01 Alabama         1        0   0 4/1/2010 Census population 4779736
## 2    01 Alabama         1        0   1 4/1/2010 Census population 2320188
## 3    01 Alabama         1        0   2 4/1/2010 Census population 2459548
## 4    01 Alabama         1        1   0 4/1/2010 Census population  304957
## 5    01 Alabama         1        1   1 4/1/2010 Census population  155265
## 6    01 Alabama         1        1   2 4/1/2010 Census population  149692
```

As I played around with it, it seems that I can grab Race and Sex information as well. But unfortunately the categories are numerically coded so somehow we have to figure out which are which. It looks like `SEX=0` is both but I have no idea which is men and which is women. Still looking at the [Census Population API page](https://www.census.gov/data/developers/data-sets/popest-popproj/popest.html) and following the link about the variables for demographic characteristics, we can click through each variable to see the .json file that defines the factor levels.

We can also import those into R directly

```r
# What variables are Available?
censusapi::listCensusMetadata(name='pep/charagegroups', vintage=2018)
```

```
##          name                             label          required
## 1   DATE_CODE                              Date default displayed
## 2      SUMLEV                     Summary Level              <NA>
## 3         SEX                               Sex default displayed
## 4       STATE                   State FIPS code              <NA>
## 5     GEONAME All geo names seperated by commas              <NA>
## 6    DIVISION              Census Division Code              <NA>
## 7      REGION              Census Regional Code              <NA>
## 8      GEO_ID        Geographic identifier code              <NA>
## 9         POP                        Population              <NA>
## 10 LASTUPDATE                       Last Update              <NA>
## 11     NATION                            Nation              <NA>
## 12   AGEGROUP                         Age Group default displayed
## 13       RACE                              Race default displayed
## 14  DATE_DESC        Description of DATE values              <NA>
## 15   UNIVERSE                          Universe              <NA>
## 16     COUNTY                  County FIPS code              <NA>
## 17       HISP                   Hispanic Origin default displayed
##    predicateType group limit concept
## 1            int   N/A     0    <NA>
## 2         string   N/A     0    <NA>
## 3            int   N/A     0    <NA>
## 4           <NA>   N/A     0    <NA>
## 5           <NA>   N/A     0    <NA>
## 6            int   N/A     0    <NA>
## 7            int   N/A     0    <NA>
## 8         string   N/A     0    <NA>
## 9           <NA>   N/A     0    <NA>
## 10        string   N/A     0    <NA>
## 11          <NA>   N/A     0    <NA>
## 12           int   N/A     0    <NA>
## 13           int   N/A     0    <NA>
## 14        string   N/A     0    <NA>
## 15        string   N/A     0    <NA>
## 16          <NA>   N/A     0    <NA>
## 17           int   N/A     0    <NA>
```

```r
# I can't figure out how to make the censusapi package import the factor levels. 
# So I'll just import the levels directly from the webpage .json file and then 
# clean it up into a nice data frame.
CensusFactorLevels <- function(name, vintage, variable){
  file <- str_c('https://api.census.gov/data/',vintage,'/',name,
                '/variables/',variable,'.json')
  Meta <- jsonlite::read_json(file) %>% 
    .[['values']] %>% .[['item']] %>% 
    unlist() %>% tibble::enframe() 
  colnames(Meta) <- c(variable, str_c(variable,'_DESC'))
  return(Meta)
}

CensusFactorLevels('pep/charagegroups', 2018, 'SEX') 
```

```
## # A tibble: 3 x 2
##   SEX   SEX_DESC  
##   <chr> <chr>     
## 1 0     Both Sexes
## 2 1     Male      
## 3 2     Female
```

```r
CensusFactorLevels('pep/charagegroups', 2018, 'RACE') 
```

```
## # A tibble: 12 x 2
##    RACE  RACE_DESC                                                         
##    <chr> <chr>                                                             
##  1 11    Native Hawaiian and Other Pacific Islander alone or in combination
##  2 10    Asian alone or in combination                                     
##  3 9     American Indian and Alaska Native alone or in combination         
##  4 8     Black alone or in combination                                     
##  5 7     White alone or in combination                                     
##  6 6     Two or more races                                                 
##  7 5     Native Hawaiian and Other Pacific Islander alone                  
##  8 4     Asian alone                                                       
##  9 3     American Indian and Alaska Native alone                           
## 10 2     Black alone                                                       
## 11 1     White alone                                                       
## 12 0     All races
```



## Exercises

1. I'm interested in information from the Census American Community Survey on demographics about educational attainment. This information can be found in ACS's Subject table. Using the API, download the latest information about educational attainment and create map or graph summarizing educational attainment. 


2. Pick some API to investigate how to use. I might suggest Twitter, Reddit, Facebook for social media apps. If you are a genomics person, the R interface to Kegg would be a fun choice. The Centers for Disease Control has an API, as well. Many municipalities are starting to create Open Data and some of them have web APIs.
