# API Data Queries




```r
library(tidyverse)
library(censusapi)
library(jsonlite) 
library(tidycensus)
```

## Introduction

As usual, I have a YouTube [Video Lecture](https://youtu.be/BlWk25GI3HY) for the chapter.

With a standard database connection, there is quite a lot we can do. For example we could insert incorrect rows into tables, or even [delete whole tables](https://xkcd.com/327/). Many organizations that deliver data to clients require a way to minimize the types of data base actions that are allowed.  For example, consider Twitter. Twitter clients need to connect to the Twitter database, sign in, and download the latest tweets from whomever they follow and accept a database input that adds a tweet from the signed in user. However, the client must not be able to update or insert tweets from somebody else, and to prevent Denial-Of-Service attacks, there should be some limit to the number of rows of information that we ask for. Furthermore, the client shouldn't have to remember the details of how the data is stored and changes to the database configuration should be completely invisible to clients.

Application Program Interfaces (APIs) are the specification for how two programs will interface. An API that is well thought out and documented is wonderful to use. In a data query situation, the API will define how we submit a query and the manner in which the result will be returned. 

As the internet has become more sophisticated and companies have begun to understand the economics and risks associated with releasing their data, APIs have generally become more restrictive and [Tom Scott](https://www.youtube.com/watch?v=BxV14h0kFs0) has a great video about this change, titled "This Video Has XXX,XXX,XXX Views".


The US Census Bureau has a really nice Web Page interface to their data and arguable, these is the easiest way to get data from the Census Bureau.

The tool we'll be using next is still in beta version, so it might change, but using the search function at [https://data.census.gov/cedsci/](https://data.census.gov/cedsci/) we can search for whatever we want. For example we might be interested in the percent of residents that have health insurance and so we'll search for 'health insurance'.  Several tables show up and we can look through all of the results for a table that gives us what we'd like.  Note the table name!

From there we could customize the table and download it.


## Census Bureau API 

The US Census Bureau's API interface works by having users visit websites with extremely carfully craften URL strings. The following web links will cause a query on the Census web site, and then result in some data. Go ahead and click on these!

[http://api.census.gov/data/2018/pep/population?get=DATE_CODE,DATE_DESC,DENSITY,POP,GEONAME,STATE&for=state:*&DATE_CODE=1](http://api.census.gov/data/2018/pep/population?get=DATE_CODE,DATE_DESC,DENSITY,POP,GEONAME,STATE&for=state:*&DATE_CODE=1)


[http://api.census.gov/data/2018/pep/population?get=DATE_CODE,DATE_DESC,DENSITY,POP,GEONAME,STATE&in=state:01&for=county:*&DATE_CODE=1](http://api.census.gov/data/2018/pep/population?get=DATE_CODE,DATE_DESC,DENSITY,POP,GEONAME,STATE&in=state:01&for=county:*&DATE_CODE=1)

1. The base website is http://api.census.gov/data/2018/pep/population. This is effectively specifying which table we want to query from. The `pep` part stands for the *Population Estimation Program*, which is one division of the Census Bureau. The 2018 part of the base address defines the *vintage* of the estimate. This page will produce estimates for the years 2010-2018, but the Census Bureau is constantly updating those estimates based on new information. So the this is specifying that we are to use the Census' 2018 estimate of the population.
2. Modifiers are included after the `?` and different modifiers are separated by `&`
3. `get=` section defines the variables that you want 
4. The `for=state:*` denotes that we want all of the states. `for=state:01` would have been just Alabama. If we want all the county populations we can use `for=county:*`. If we just want county populations within a particular state, we would use `in=state:01&for=county:*`
5. The `DATE_CODE=1` indicates that I just want the first estimate in the decadal time series of estimates. If I didn't include this, we'd end up with estimates for each year between 2010 and 2018. 

When you go to this website, the database will read the modifier list, do the appropriate database query, and return the result via a webpage that has a very simple structure that is easy to parse into a table.

The hard part about Web APIs is understanding which tables are available and what each covariate means. For the US Census Bureau, the [developers](https://www.census.gov/data/developers/) page is a great place to start. 


## Package `censusapi`
While it is helpful to understand how the web API works, it would be nice to not have to worry about some of the fiddly aspects of parsing the result into a data frame. There are many R packages that provide a convenient interface to some database API. For our US Census Bureau example, we'll use the  R package `censusapi`. You should read the [documentation](https://github.com/hrecht/censusapi) as well. It looks like there is another package, `tidycensus` that might be even better.

The Census Bureau wants to identify which developers are accessing their data and you are required to sign up for a [Census Key](https://api.census.gov/data/key_signup.html). It is easy to give them your email and they'll email you a character string that you'll use for the rest of these examples.




```r
# I got a Census API key from https://api.census.gov/data/key_signup.html 
# and saved it as Census_API_Key in my .Rprofile file in my home directory. 
CENSUS_API_KEY = Sys.getenv('CENSUS_API_KEY')
 
# This query is the example query first given in the censusapi vignette.
censusapi::getCensus(name = "timeseries/healthins/sahie",
	vars = c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT"),      # Define the gets=
	region = "state:01",                                     # Define the for=
	time = 2017,                                         
	key = CENSUS_API_KEY)
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


```r
# Code to grab county level population levels.
County_Populations <- getCensus(name = "pep/population",
  vars = c('STATE','COUNTY','GEONAME','DATE_CODE','DATE_DESC','POP'),
  vintage = '2018',
  regionin = 'state:04',  # Just Arizona, which is coded as 04. I don't know why...
  region = 'county:*',    # All the counties
  DATE_CODE=1,            # 2010, Leave this out to get each year 2010-2018
  key = CENSUS_API_KEY)   # If key is missing, it will look in System Environment 

County_Populations %>% head(6)  
```

```
##   state county STATE COUNTY                  GEONAME DATE_CODE
## 1    04    001    04    001   Apache County, Arizona         1
## 2    04    003    04    003  Cochise County, Arizona         1
## 3    04    005    04    005 Coconino County, Arizona         1
## 4    04    007    04    007     Gila County, Arizona         1
## 5    04    009    04    009   Graham County, Arizona         1
## 6    04    011    04    011 Greenlee County, Arizona         1
##                    DATE_DESC    POP DATE_CODE_1
## 1 4/1/2010 Census population  71518           1
## 2 4/1/2010 Census population 131346           1
## 3 4/1/2010 Census population 134421           1
## 4 4/1/2010 Census population  53597           1
## 5 4/1/2010 Census population  37220           1
## 6 4/1/2010 Census population   8437           1
```


I was looking for population divided up by Age and Sex and it took awhile to figure out that I want to use PEP's Demographic Characteristics Estimates by Age Groups tables `pep/charagegroups`. From there I looked at some of the examples and variables.


```r
County_Populations_by_AgeGender <- getCensus(name = "pep/charagegroups",
  vars = c('GEONAME','DATE_CODE','AGEGROUP','SEX','DATE_DESC','POP'),
  vintage = '2018',
  region = 'state:04', 
	key = CENSUS_API_KEY)

County_Populations_by_AgeGender %>% head(6)
```

```
##   state GEONAME DATE_CODE AGEGROUP SEX                  DATE_DESC     POP
## 1    04 Arizona         1        0   0 4/1/2010 Census population 6392017
## 2    04 Arizona         1        0   1 4/1/2010 Census population 3175823
## 3    04 Arizona         1        0   2 4/1/2010 Census population 3216194
## 4    04 Arizona         1        1   0 4/1/2010 Census population  455715
## 5    04 Arizona         1        1   1 4/1/2010 Census population  232562
## 6    04 Arizona         1        1   2 4/1/2010 Census population  223153
```

As I played around with it, it seems that I can grab Race and Sex information as well. But unfortunately the categories are numerically coded so somehow we have to figure out which are which. It looks like `SEX=0` is both but I have no idea which is men and which is women. Still looking at the [Census Population API page](https://www.census.gov/data/developers/data-sets/popest-popproj/popest.html) and following the link about the variables for demographic characteristics, we can click through each variable to see the .json file that defines the factor levels.

We can also import those into R directly

```r
# What variables are Available?
censusapi::listCensusMetadata(name='pep/charagegroups', vintage=2018)
```

```
##          name                             label          required predicateType
## 1   DATE_CODE                              Date default displayed           int
## 2      SUMLEV                     Summary Level              <NA>        string
## 3         SEX                               Sex default displayed           int
## 4       STATE                   State FIPS code              <NA>          <NA>
## 5     GEONAME All geo names seperated by commas              <NA>          <NA>
## 6    DIVISION              Census Division Code              <NA>           int
## 7      REGION              Census Regional Code              <NA>           int
## 8      GEO_ID        Geographic identifier code              <NA>        string
## 9         POP                        Population              <NA>          <NA>
## 10 LASTUPDATE                       Last Update              <NA>        string
## 11     NATION                            Nation              <NA>          <NA>
## 12   AGEGROUP                         Age Group default displayed           int
## 13       RACE                              Race default displayed           int
## 14  DATE_DESC        Description of DATE values              <NA>        string
## 15   UNIVERSE                          Universe              <NA>        string
## 16     COUNTY                  County FIPS code              <NA>          <NA>
## 17       HISP                   Hispanic Origin default displayed           int
##    group limit concept
## 1    N/A     0    <NA>
## 2    N/A     0    <NA>
## 3    N/A     0    <NA>
## 4    N/A     0    <NA>
## 5    N/A     0    <NA>
## 6    N/A     0    <NA>
## 7    N/A     0    <NA>
## 8    N/A     0    <NA>
## 9    N/A     0    <NA>
## 10   N/A     0    <NA>
## 11   N/A     0    <NA>
## 12   N/A     0    <NA>
## 13   N/A     0    <NA>
## 14   N/A     0    <NA>
## 15   N/A     0    <NA>
## 16   N/A     0    <NA>
## 17   N/A     0    <NA>
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

```r
CensusFactorLevels('pep/charagegroups', 2018, 'AGEGROUP') 
```

```
## # A tibble: 32 x 2
##    AGEGROUP AGEGROUP_DESC    
##    <chr>    <chr>            
##  1 31       Median age       
##  2 30       15 to 44 years   
##  3 29       18 years and over
##  4 28       16 years and over
##  5 27       85 years and over
##  6 26       65 years and over
##  7 25       45 to 64 years   
##  8 24       25 to 44 years   
##  9 23       18 to 24 years   
## 10 22       18 to 64 years   
## # … with 22 more rows
```

Using these factor levels, we can add the description onto our county populations by AGE and SEX by simply doing some table joins.


```r
County_Populations_by_AgeGender %>%
  left_join(CensusFactorLevels('pep/charagegroups', 2018, 'SEX')) %>%
  left_join(CensusFactorLevels('pep/charagegroups', 2018, 'AGEGROUP')) %>%
  head(6)
```

```
## Joining, by = "SEX"
```

```
## Joining, by = "AGEGROUP"
```

```
##   state GEONAME DATE_CODE AGEGROUP SEX                  DATE_DESC     POP
## 1    04 Arizona         1        0   0 4/1/2010 Census population 6392017
## 2    04 Arizona         1        0   1 4/1/2010 Census population 3175823
## 3    04 Arizona         1        0   2 4/1/2010 Census population 3216194
## 4    04 Arizona         1        1   0 4/1/2010 Census population  455715
## 5    04 Arizona         1        1   1 4/1/2010 Census population  232562
## 6    04 Arizona         1        1   2 4/1/2010 Census population  223153
##     SEX_DESC    AGEGROUP_DESC
## 1 Both Sexes         All Ages
## 2       Male         All Ages
## 3     Female         All Ages
## 4 Both Sexes Age 0 to 4 years
## 5       Male Age 0 to 4 years
## 6     Female Age 0 to 4 years
```



## Package `tidycensus`
The `tidycensus` package is a little easier to work with. By default, `tidycensus` functions will look for the API Key in the System Environment.


```r
# The tidycensus package has a nice way of installing the 
# API key in your .Rprofile file. 
tidycensus::census_api_key('adoiYOURadsKEYmcvGOESsdljHERE', install=TRUE)
```

There are three major functions that will get used. The 

| Function  |    Description   |
|:---------:|:-------------------------|
|`get_estimates()` | Gives information from the Population Estimates Program. |
|`get_acs()`       | Gives information from the American Community Survey     |
|`load_variables()`| Gives the mapping between the variable code and the description |


For our first example, we'll grab the county population totals in Arizona broken down by sex and ethnicity. 


```r
AZ_County_Populations <- tidycensus::get_estimates(
  geography = "county",
  state=c('AZ'),  # leave this out for all state/county combinations
  product = "characteristics",
  breakdown = c('SEX','HISP'),
  breakdown_labels = TRUE)      # Give the variable labels, not the Census Variable code 

head(AZ_County_Populations)
```

```
## # A tibble: 6 x 5
##   GEOID NAME                   value SEX        HISP                 
##   <chr> <chr>                  <dbl> <chr>      <chr>                
## 1 04001 Apache County, Arizona 71818 Both sexes Both Hispanic Origins
## 2 04001 Apache County, Arizona 67228 Both sexes Non-Hispanic         
## 3 04001 Apache County, Arizona  4590 Both sexes Hispanic             
## 4 04001 Apache County, Arizona 35310 Male       Both Hispanic Origins
## 5 04001 Apache County, Arizona 32902 Male       Non-Hispanic         
## 6 04001 Apache County, Arizona  2408 Male       Hispanic
```



For our next example, we'll grab the number of people with or without Insurance in each state.

```r
# We want to get the Number of people with or without Insurance in each state
US_State_Health_Insurance <- 
  tidycensus::get_acs(
    table = 'B27003',        # Found the table from Census Website
    geography = "state",
    cache_table=TRUE)        # On multiple runs, don't ask Census Bureau over and over.
```

```
## Getting data from the 2014-2018 5-year ACS
```

```
## Loading ACS5 variables for 2018 from table B27003 and caching the dataset for faster future access.
```

```r
# Grab the Variable Names so we can convert from the variable codes
# to variable labels, i.e., something I can understand by reading.  
ACS_Variables <- tidycensus::load_variables(2018, 'acs1', cache = TRUE)
head(ACS_Variables)
```

```
## # A tibble: 6 x 3
##   name       label                           concept                            
##   <chr>      <chr>                           <chr>                              
## 1 B00001_001 Estimate!!Total                 UNWEIGHTED SAMPLE COUNT OF THE POP…
## 2 B00002_001 Estimate!!Total                 UNWEIGHTED SAMPLE HOUSING UNITS    
## 3 B01001_001 Estimate!!Total                 SEX BY AGE                         
## 4 B01001_002 Estimate!!Total!!Male           SEX BY AGE                         
## 5 B01001_003 Estimate!!Total!!Male!!Under 5… SEX BY AGE                         
## 6 B01001_004 Estimate!!Total!!Male!!5 to 9 … SEX BY AGE
```

```r
# Join the data with the readable variable names
US_State_Health_Insurance <- US_State_Health_Insurance %>%
  left_join( ACS_Variables, by=c('variable' = 'name') )

# Now for some cleaning
US_State_Health_Insurance %>%
  tidyr::separate(label, c('Estimate','Total','Gender','Age','Insurance'), sep ='!!') %>%
  tidyr::drop_na() %>%
  select(NAME, Gender, Age, Insurance, estimate, moe)
```

```
## Warning: Expected 5 pieces. Missing pieces filled with `NA` in 1092 rows [1, 2,
## 3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 31, 34, 37, 40, 43, 46, 49, 52, ...].
```

```
## # A tibble: 1,872 x 6
##    NAME    Gender Age            Insurance            estimate   moe
##    <chr>   <chr>  <chr>          <chr>                   <dbl> <dbl>
##  1 Alabama Male   Under 6 years  With public coverage    88350  1955
##  2 Alabama Male   Under 6 years  No public coverage      89308  1894
##  3 Alabama Male   6 to 18 years  With public coverage   173031  2754
##  4 Alabama Male   6 to 18 years  No public coverage     241916  3076
##  5 Alabama Male   19 to 25 years With public coverage    20568  1165
##  6 Alabama Male   19 to 25 years No public coverage     209313  2169
##  7 Alabama Male   26 to 34 years With public coverage    30831  1350
##  8 Alabama Male   26 to 34 years No public coverage     229595  2077
##  9 Alabama Male   35 to 44 years With public coverage    32959  1429
## 10 Alabama Male   35 to 44 years No public coverage     244980  1613
## # … with 1,862 more rows
```



## Exercises  {#Exercises_APIs}

1. The Census Bureau is constantly running many different surveys and compiling the results. One of the most comprehensive and interesting of these is the [American Community Survey](https://www.census.gov/programs-surveys/acs/guidance.html). I'm interested in using the ACS to get information about educational attainment. Use the Census Bureau's Data  [search page](https://data.census.gov/cedsci/), find a table that gives you information about educational attainment. With this table information, use the `tidycensus` package to 
download the latest information about educational attainment. Create map or graph summarizing educational attainment in either counties in Arizona or across states within the US. Or if you are feeling ambitious, create a graph or graphs summarizing this across all counties in the US. *Perhaps you could break the educational level into high school, some college, bachelors, advanced degree. Then maybe make a map of counties/states colored by percent with BS or higher. Or maybe stacked barcharts ordered by percent BS or higher.*

2. Pick some API to investigate how to use. Utilizing your interests, pick an API and figure out how to use it.  Using the API, download some data and produce an interesting graphic. *Many government agencies have data API as well. For example, Centers for Disease Control mortality and disease information at the county level, the National Oceanic and Atmospheric Administration has weather data accessible. If you are a genomics person, the R interface to Kegg would be a fun choice. Many social media apps such as Twitter, Reddit, and  Facebook have APIs. Many municipalities are starting to create Open Data and some of them have web APIs. Explore your interests and see if there is an interface to that data!*
