# Databases




```r
library(tidyverse)
library(DBI)         # DataBase Interface Package
library(dbplyr)      # dplyr with databases!
```


As our data grows larger and is being updated more frequently, we need to stop using static input files and instead learn to interact with databases. There are a many reasons for using a database, but these are my favorite:

1. Data Freshness. Because the database holds the definitive copy of the data, there isn't a problem of using a .csv file that is months (or years) old. That means my results are constantly being updated with new data.
2. No Local Storage. Because the data lives on the database, I don't have to occupy gigabytes of space on my laptop to hold an out-of-date copy of the data.
3. Database actions are atomic. Whenever I update the database, the action either happens or it doesn't and the database should never be left in an inconsistent state. This extremely important when processing financial transactions, for example.

Fortunately, reading information from a database instead of an in-memory table won't change our current work flow and superficially the change is trivial. However, the impact can be quite profound in the timeliness and re-usability of our work. 

The great people at Rstudio have created a [great website](https://db.rstudio.com/overview/) for using databases using their `dbplyr` package.

However, the package `dbplyr` is really only intended for *reading* from the data base and does not support *writing* to the data base. 

## Tutorial Set-Up

Databases should be run on a server that is ALWAYS on and available via an internet connection. To connect to a database, we'll need to know the internet address and be able to authenticate with a username/password combination.

To demonstrate how a database works, we unfortunately need to have a live database to connect to. In real situations this would already be done (probably by somebody else) and you would just need to install some DataBase Interface (DBI) package that will negotiate creating a connection between your R-session and the database.

However for this example, we need to start up a data base before we can start working with.


```r
# Normally, a database connection looks something like this:
con <- DBI::dbConnect(RMariaDB::MariaDB(), 
  host = "database.rstudio.com",
  user = "hadley",
  password = rstudioapi::askForPassword("Database password")
)

# For a Postgres database, it might look like this:
con <- DBI::dbConnect(dbDriver("PostgresSQL"), dbname = "postgres",
  host = "database.nau.edu", port = 5432,
  user = "dls354", 
  password = rstudioapi::askForPassword("Database password"))
```


```r
# For our little toy example, we'll use a database I'll create right now.
# Establish a connection
con <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
```

Our final step involves populating our new database with some data so that we can play with it. For this example, we'll go back to the credit card data example from the data reshaping chapter. I have it available on the book's GitHub data-raw directory.

```r
# Read in some data for the Credit Card example
stem <- 'https://raw.githubusercontent.com/dereksonderegger/444/master/data-raw/CreditCard'
stem <- '~/GitHub/444/data-raw/CreditCard'

Cards        <- read_csv(paste(stem, 'Cards.csv',        sep='_'), 
                         col_types = cols(CardID=col_character(),
                                          PersonID=col_character()))
Customers    <- read_csv(paste(stem, 'Customers.csv',    sep='_'),
                         col_types = cols(PersonID=col_character()))
Retailers    <- read_csv(paste(stem, 'Retailers.csv',    sep='_'),
                         col_types = cols(RetailID=col_character()))
Transactions <- read_csv(paste(stem, 'Transactions.csv', sep='_'),
                         col_types = cols(CardID=col_character(),
                                          RetailID=col_character()))

# Because the EXTREMELY simple RSQLite database doesn't support dates natively,
# we need to convert all the Date/Time values to be character strings. Notice
# because they are sorted as Year-Month-Day Hour:Minute:Second, sorting will
# still work.
# convert the Dates to character strings 
Cards <- Cards %>% 
  mutate(Issue_DateTime = as.character(Issue_DateTime),
         Exp_DateTime   = as.character(Exp_DateTime))
Transactions <- Transactions %>%
  mutate(DateTime = as.character(DateTime))
```

So that we remember what the data we are working with looks like:

```r
head(Customers)    # Key  is  PersonID
```

```
## # A tibble: 4 x 5
##   PersonID Name               Street             City      State
##   <chr>    <chr>              <chr>              <chr>     <chr>
## 1 1        Derek Sonderegger  231 River Run      Flagstaff AZ   
## 2 2        Aubrey Sonderegger 231 River Run      Flagstaff AZ   
## 3 3        Robert Buscaglia   754 Forest Heights Flagstaff AZ   
## 4 4        Roy St Laurent     845 Elk View       Flagstaff AZ
```

```r
head(Cards)        # Keys are PersonID and CardID  
```

```
## # A tibble: 5 x 4
##   CardID           PersonID Issue_DateTime      Exp_DateTime       
##   <chr>            <chr>    <chr>               <chr>              
## 1 9876768717278723 1        2019-09-20 00:00:00 2022-09-20 00:00:00
## 2 9876765798212987 2        2019-09-20 00:00:00 2019-10-15 16:28:21
## 3 9876765498122734 3        2019-09-28 00:00:00 2022-09-28 00:00:00
## 4 9876768965231926 4        2019-09-30 00:00:00 2022-09-30 00:00:00
## 5 9876765798212988 2        2019-10-15 16:28:45 2022-10-15 00:00:00
```

```r
head(Transactions) # Keys are CardID and RetailID
```

```
## # A tibble: 6 x 4
##   CardID           RetailID DateTime            Amount
##   <chr>            <chr>    <chr>                <dbl>
## 1 9876768717278723 1        2019-10-01 08:31:23   5.68
## 2 9876765498122734 2        2019-10-01 12:45:45  25.7 
## 3 9876768717278723 1        2019-10-02 08:26:31   5.68
## 4 9876768717278723 1        2019-10-02 08:30:09   9.23
## 5 9876765798212987 3        2019-10-05 18:58:57  68.5 
## 6 9876765498122734 2        2019-10-05 12:39:26  31.8
```

```r
head(Retailers)    # Key  is  RetailID
```

```
## # A tibble: 3 x 5
##   RetailID Name           Street             City      State
##   <chr>    <chr>          <chr>              <chr>     <chr>
## 1 1        Kickstand Kafe 719 N Humphreys St Flagstaff AZ   
## 2 2        MartAnnes      112 E Route 66     Flagstaff AZ   
## 3 3        REI            323 S Windsor Ln   Flagstaff AZ
```

Critically, using the ID columns, we can take an individual transaction figure out what customer executed it. Finally I'll take these tables and load them into my RSQLite database.


```r
# Copy the tables to our newly set up database. The dbWriteTable() function is intended
# for database examples and is NOT how you would in practice create a database.
DBI::dbWriteTable(con, 'Cards', Cards,
                  field.types=c(CardID='character',PersonID='character',
                                Issue_DateTime='time',Exp_DateTime='time') )
DBI::dbWriteTable(con, 'Customers', Customers,
                  field.types=c(PersonID='character'))
DBI::dbWriteTable(con, 'Retailers', Retailers,
                  field.types=c(RetailID='character'))
DBI::dbWriteTable(con, 'Transactions', Transactions,
                  field.types=c(CardID='character', RetailID='character',
                                DateTime='time'))

rm(Cards, Customers, Retailers, Transactions)     # Remove all the setup except `con`
```


## SQL

The traditional way to interact with a database is by using SQL syntax. SQL stands for Structured Query Language and some understanding of SQL is mandatory for anyone that interacts with databases.  There are many good introduction to SQL but we'll cover a few basics here.

To begin, lets run a simple SQL query.


```r
sql_cmd <- 'SELECT * FROM Transactions'
transactions <- DBI::dbGetQuery(con, sql_cmd)
transactions
```

```
##             CardID RetailID            DateTime Amount
## 1 9876768717278723        1 2019-10-01 08:31:23   5.68
## 2 9876765498122734        2 2019-10-01 12:45:45  25.67
## 3 9876768717278723        1 2019-10-02 08:26:31   5.68
## 4 9876768717278723        1 2019-10-02 08:30:09   9.23
## 5 9876765798212987        3 2019-10-05 18:58:57  68.54
## 6 9876765498122734        2 2019-10-05 12:39:26  31.84
## 7 9876768965231926        2 2019-10-10 19:02:20  42.83
## 8 9876765798212988        1 2019-10-16 14:30:21   4.98
```

We can examine the SQL command as follows:

|  SQL Function    |  Description                                |
|:----------------:|:--------------------------------------------|
| `SELECT`         |  A keyword that denotes that the following is a *query*. |
|  `*`             | A placeholder meaning all columns. This could be any column name(s). |
| `FROM`           | A keyword indicating that whatever follows is the table (or tables) being selected from. Any table joins need to be constrained in the WHERE clause to tell us what columns need to match.  |
| `WHERE`          | A keyword indicating the following logical statements will be used to filter rows. Boolean operators `AND`, `OR`, and `NOT` can be used to create complex filter statements. |


There is a way to insert a SQL code chunk and have it appropriately run when knitting the document together. I don't really like that method because I've found it difficult to use while working with the Rmarkdown file interactively, so I generally don't recommend doing that.



Typical SQL statements can be quite long and sometimes difficult to read because the table join instructions are mixed in with the filtering instructions. For example, the following is the SQL command to generate my credit card statement, and then saves the resulting table to the R object `DereksTransactions`.



```r
# given some other R object that specifies part of the SQL command, I can 
# generate the full SQL command string by pasting the parts together
customer = "'Derek Sonderegger'"  # Notice the quotes inside so that there are
                                  # quotes surrounding the name inside the SQL

sql_cmd <- paste('
SELECT Customers.Name, Transactions.DateTime, Retailers.Name, Transactions.Amount
  FROM Customers, Cards, Transactions, Retailers
  WHERE Customers.PersonID = Cards.PersonID AND 
        Cards.CardID = Transactions.CardID AND
        Transactions.RetailID = Retailers.RetailID AND
        Customers.Name = ', customer) 

DereksTransactions <- DBI::dbGetQuery(con, sql_cmd)
DereksTransactions
```

```
##                Name            DateTime           Name Amount
## 1 Derek Sonderegger 2019-10-01 08:31:23 Kickstand Kafe   5.68
## 2 Derek Sonderegger 2019-10-02 08:26:31 Kickstand Kafe   5.68
## 3 Derek Sonderegger 2019-10-02 08:30:09 Kickstand Kafe   9.23
```



## `dbplyr`

There are a lot of good things about SQL, but for database queries, I would really like to pretend that the tables are in memory and use all of my favorite `dplyr` tools and pipelines. This would mean that I don't have to remember all the weird SQL syntax. However, the database interface `dbplyr` is ONLY intended for queries and NOT for updating or inserting rows into the tables.

The way this will work is that we will use the previously established database connection `con` to create a virtual link between the database table and some appropriately named R object.


```r
# connect the database tables to similarly named objects in R
Cards <-        tbl(con, 'Cards')
Customers <-    tbl(con, 'Customers')
Retailers <-    tbl(con, 'Retailers')
Transactions <- tbl(con, 'Transactions')
```

However, this does NOT download the whole table into R.  Instead it grabs only a couple of rows so that we can see the format. Notice that we don't know how many rows are in the Transactions table.

```r
Transactions %>% head(3)
```

```
## # Source:   lazy query [?? x 4]
## # Database: sqlite 3.30.1 [:memory:]
##   CardID           RetailID DateTime            Amount
##   <chr>            <chr>    <chr>                <dbl>
## 1 9876768717278723 1        2019-10-01 08:31:23   5.68
## 2 9876765498122734 2        2019-10-01 12:45:45  25.7 
## 3 9876768717278723 1        2019-10-02 08:26:31   5.68
```

```r
# Transactions %>% tail(3)  # not supported because we haven't yet downloaded much information.
```

The guiding principle of `dbplyr` is to delay as much work for as long as possible actually pulling the data from the database. The rational is that we spend a great deal of time figuring out what the query should look like and too often we write a query that accidentally downloads millions of lines of data and slows down our network connection. Instead `dbplyr` returns just the first few rows of whatever query we are working on until we finish the pipeline with a `collect()` command that will cause us to download ALL of the query results and save them as a local `data.frame`.


```r
CC_statement <- 
  Customers %>% 
  filter(Name == 'Derek Sonderegger') %>% select(PersonID) %>%
  left_join(Cards) %>% left_join(Transactions) %>% left_join(Retailers) %>%
  select(DateTime, Name, Amount) %>%
  rename(Retailer = Name) 

CC_statement
```

```
## # Source:   lazy query [?? x 3]
## # Database: sqlite 3.30.1 [:memory:]
##   DateTime            Retailer       Amount
##   <chr>               <chr>           <dbl>
## 1 2019-10-01 08:31:23 Kickstand Kafe   5.68
## 2 2019-10-02 08:26:31 Kickstand Kafe   5.68
## 3 2019-10-02 08:30:09 Kickstand Kafe   9.23
```

At this point, we *still* haven't downloaded all of the rows. Instead this is still a *lazy* query. To actually download everything, we'll pipe this into the `collect` function.


```r
CC_statement %>%
  collect()
```

```
## # A tibble: 3 x 3
##   DateTime            Retailer       Amount
##   <chr>               <chr>           <dbl>
## 1 2019-10-01 08:31:23 Kickstand Kafe   5.68
## 2 2019-10-02 08:26:31 Kickstand Kafe   5.68
## 3 2019-10-02 08:30:09 Kickstand Kafe   9.23
```


It can be fun to see what the SQL code that is being generated is.



```r
CC_statement %>% show_query()
```

```
## <SQL>
## SELECT `DateTime`, `Name` AS `Retailer`, `Amount`
## FROM (SELECT `LHS`.`PersonID` AS `PersonID`, `LHS`.`CardID` AS `CardID`, `LHS`.`Issue_DateTime` AS `Issue_DateTime`, `LHS`.`Exp_DateTime` AS `Exp_DateTime`, `LHS`.`RetailID` AS `RetailID`, `LHS`.`DateTime` AS `DateTime`, `LHS`.`Amount` AS `Amount`, `RHS`.`Name` AS `Name`, `RHS`.`Street` AS `Street`, `RHS`.`City` AS `City`, `RHS`.`State` AS `State`
## FROM (SELECT `LHS`.`PersonID` AS `PersonID`, `LHS`.`CardID` AS `CardID`, `LHS`.`Issue_DateTime` AS `Issue_DateTime`, `LHS`.`Exp_DateTime` AS `Exp_DateTime`, `RHS`.`RetailID` AS `RetailID`, `RHS`.`DateTime` AS `DateTime`, `RHS`.`Amount` AS `Amount`
## FROM (SELECT `LHS`.`PersonID` AS `PersonID`, `RHS`.`CardID` AS `CardID`, `RHS`.`Issue_DateTime` AS `Issue_DateTime`, `RHS`.`Exp_DateTime` AS `Exp_DateTime`
## FROM (SELECT `PersonID`
## FROM `Customers`
## WHERE (`Name` = 'Derek Sonderegger')) AS `LHS`
## LEFT JOIN `Cards` AS `RHS`
## ON (`LHS`.`PersonID` = `RHS`.`PersonID`)
## ) AS `LHS`
## LEFT JOIN `Transactions` AS `RHS`
## ON (`LHS`.`CardID` = `RHS`.`CardID`)
## ) AS `LHS`
## LEFT JOIN `Retailers` AS `RHS`
## ON (`LHS`.`RetailID` = `RHS`.`RetailID`)
## )
```

The algorithm used to convert my `dplyr` statement into a SQL statement doesn't mind nesting SQL statements and isn't the same as what I generated by hand, but it works.


The last step of a script should be to close the database connection.

```r
# Close our database connection when we are through...
dbDisconnect(con)
```

## Exercises
1. In this exercise, you'll create a database containing the `nycflights13` data. Make sure that you've already downloaded the `nycflights13` package.
    a. Create a SQLite database and connect to it using the following code: 
    
    ```r
    library(dplyr)
    
    # Start up a SQL-Lite database with the NYCFlights13 data pre-loaded
    # 
    ## This handy function to load up the nycflights13 dataset unfortunately
    ## causes an error when we try to close the connection.  I've submitted
    ## a bug report to Hadley. We'll see what happens.
    # con <- nycflights13_sqlite( )
    # 
    ## So instead we'll use this somewhat longer and more annoying startup
    ## set of code.
    con <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
    dplyr::copy_to(con, nycflights13::airlines)
    dplyr::copy_to(con, nycflights13::airports)
    dplyr::copy_to(con, nycflights13::flights)
    dplyr::copy_to(con, nycflights13::planes)
    dplyr::copy_to(con, nycflights13::weather)
    ```
    b. Through the `con` connection object, create links to the `flights` and `airlines` tables.
    c. From the `flights` table, summarize the percent of flights that are delayed by more than 10 minutes for each airline. Produce a table that gives the airline name (not the abbreviation) and the percent of flights that are late.
    d. Using the `dbDisconnect()` command to close the connection `con`. 
    
2. For this exercise, we'll start a SQLite database and see that the SQLite application stores the data in a very specialized file structure, which usually has a file extension of `.db` or `.sqlite`.
    a. Create the SQLite database file in your current working directory using the following:
    
    ```r
    con <- DBI::dbConnect(RSQLite::SQLite(), dbname = "TestSQLiteFile.db")
    
    # Create a table using the iris data
    dbCreateTable(con, 'IRIS', iris)
    dbListTables(con)
    dbDisconnect(con)
    ```
    b) Now check the files in your current working directory as there should now be a `TestSQLiteFile.db`. The SQLite file structure for data is extremely stable and works across platform types (Unix/Windows, 32/64 bit, big/little endian, etc).  As such, it is a good file type choice for storing lots of data in a compact format across different systems (e.g. applications that work on a mobile device vs a computer)

