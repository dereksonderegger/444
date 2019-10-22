# Web API Data Queries




```r
library(tidyverse)
library(censusapi)
library(jsonlite)  
```


With a standard database connection, there is quite a lot we can do. For example we could insert incorrect rows into tables, or even [delete whole tables](https://xkcd.com/327/). Many organizations that deliver data to clients require a way to minimize the types of data base actions that are allowed.  For example, consider Twitter. Twitter clients need to connect to the Twitter database, sign in, and download the latest tweets from whomever they follow and accept a database input that adds a tweet from the signed in user. However, the client must not be able to update or insert tweets from somebody else, and to prevent Denial-Of-Service attacks, there should be some limit to the number of rows of information that we ask for. Furthermore, the client shouldn't have to remember the details of how the data is stored and changes to the database configuration should be completely invisible to clients.

Application Program Interfaces (APIs) are the specification for how two programs will interface. An API that is well thought out and documented is wonderful to use. In a data query situation, the API will define how we submit a query and the manner in which the result will be returned. Web API queries are usually designed so that the client visits some web page and includes as part of the address, additional arguments that will be used to create a query. The results of the query are then rendered as a very simple web page.


## Web Interface
We will consider an example from the US Census Bureau's web interface. The following web links will cause a query on the Census web site, and then result in some data. Go ahead and click on these!

http://api.census.gov/data/2018/pep/population?get=DATE_CODE,DATE_DESC,DENSITY,POP,GEONAME,STATE&for=state:*&DATE_CODE=1

http://api.census.gov/data/2018/pep/population?get=DATE_CODE,DATE_DESC,DENSITY,POP,GEONAME,STATE&in=state:01&for=county:*&DATE_CODE=1

1. The base website is http://api.census.gov/data/2018/pep/population. This is effectively specifying which table we want to query from. The `pep` part stands for the *Population Estimation Program*, which is one division of the Census Bureau. The 2018 part of the base address defines the *vintage* of the estimate. This page will produce estimates for the years 2010-2018, but the Census Bureau is constantly updating those estimates based on new information. So the this is specifying that we are to use the Census' 2018 estimate of the population.
2. Modifiers are included after the `?` and different modifiers are separated by `&`
3. `get=` section defines the variables that you want 
4. The `for=state:*` denotes that we want all of the states. `for=state:01` would have been just Alabama. If we want all the county populations we can use `for=county:*`. If we just want county populations within a particular state, we would use `in=state:01&for=county:*`
5. The `DATE_CODE=1` indicates that I just want the first estimate in the decadal time series of estimates. If I didn't include this, we'd end up with estimates for each year between 2010 and 2018. 

When you go to this website, the database will read the modifier list, do the appropriate database query, and return the result via a webpage that has a very simple structure that is easy to parse into a table.

The hard part about Web APIs is understanding which tables are available and what each covariate means. For the US Census Bureau, the [developers](https://www.census.gov/data/developers/) page is a great place to start. 


## R API Interfaces
While it is helpful to understand how the web API works, it would be nice to not have to worry about some of the fiddly aspects of parsing the result into a data frame. There are many R packages that provide a convenient interface to some database API. For our US Census Bureau example, we'll use the  R package `censusapi`. You should read the [documentation](https://github.com/hrecht/censusapi) as well.

The Census Bureau wants to identify which developers are accessing their data and you are required to sign up for a [Census Key](https://api.census.gov/data/key_signup.html). It is easy to give them your email and they'll email you a character string that you'll use for the rest of these examples.




```r
# I got a Census API key from https://api.census.gov/data/key_signup.html 
# and saved it as Census_Key and use that in all the following examples...
# 
# This query is the example query first given in the censusapi vignette.
getCensus(name = "timeseries/healthins/sahie",
	vars = c("NAME", "IPRCAT", "IPR_DESC", "PCTUI_PT"),      # Define the gets=
	region = "state:01",                                     # Define the for=
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


```r
# Code to grab county level population levels.
County_Populations <- getCensus(name = "pep/population",
  vars = c('STATE','COUNTY','GEONAME','DATE_CODE','DATE_DESC','POP'),
  vintage = '2018',
  regionin = 'state:04',  # Just Arizona, which is coded as 04. I don't know why...
  region = 'county:*',    # All the counties
  DATE_CODE=1,            # 2010, Leave this out to get each year 2010-2018
	key = Census_Key,
  )

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


I was looking for population divided up by Race and Sex and it took awhile to figure out that I want to use PEP's Demographic Characteristics Estimates by Age Groups tables `pep/charagegroups`. From there I looked at some of the examples and variables.


```r
County_Populations_by_AgeGender <- getCensus(name = "pep/charagegroups",
  vars = c('GEONAME','DATE_CODE','AGEGROUP','SEX','DATE_DESC','POP'),
  vintage = '2018',
  region = 'state:04', 
	key = Census_Key)

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

1. The Census Bureau is constantly running many different surveys and compiling the results. One of the most comprehensive and interesting of these is the [American Community Survey](https://www.census.gov/programs-surveys/acs/guidance.html). I'm interested in using the ACS to get information about educational attainment. The developers overview webpage for the 1 year ACS data is [here](https://www.census.gov/data/developers/data-sets/acs-1year.html) and we can get the desired information from the Subject table. Using the on-line documentation, figure out which columns you want and then using the API, download the latest information about educational attainment. Create map or graph summarizing educational attainment in either counties in Arizona or across states within the US. Or if you are feeling ambitious, create a graph or graphs summarizing this across all counties in the US.

2. Pick some API to investigate how to use. Utilizing your interests, pick an API and figure out how to use it.  Using the API, download some data and produce an interesting graphic. *I know that some social media apps such as Twitter, Reddit, and  Facebook have APIs. If you are a genomics person, the R interface to Kegg would be a fun choice. The Centers for Disease Control has an API, as well. Many municipalities are starting to create Open Data and some of them have web APIs. Explore your interests and see if there is an interface to that data!*
