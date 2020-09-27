
# CheatSheet {-}

The goal of this appendix is to give a easy reference to basic manipulation functions that are often used and should always be readily accessible.

## Importing Data and Loading Packages
| Function   |   Meaning                            |
|:------------------------------------------|:-------------------------------------|
| `data("DataName", package="PackageName")` | Load the data set `DataName` which is found in the package `PackageName` |
| `library(PackageName)`                    | Load the package `PackageName` to be used.                               |
| `read.csv("filename.csv")`                | Read a .csv file. This result needs to be saved or else it is just printed |


## Useful vectorized functions
| Function   |   Meaning                            |
|:-------------------------------------------------|:-------------------------------------|
| `ifelse( logicalTest, TrueResult, FalseResult )` | Creates a vector of output, where elements are either the `TrueResult` or `FalseResult` based on the corresponding outcome in the `logicalTest` vector |


## Data frame (tibble) manipulation
In the examples below, `df` stands for an arbitrary data frame that we are applying the functions to.

| Function   |   Meaning                            |
|:-----------------------|:-------------------------------------|
| `data.frame(x= , y=.)`         | Creates a data frame "by hand" with one column per input. |
| `tibble(x= , y= )`                | Creates a tibble "by hand" with one column per input. |
| `tribble( ~x, ~y, 1,  2)`  | Creates a tibble "by hand", but with row-wise specification. |
| `df %>% add_row(x=3, y=5)`   | Add a single row to the `df` data frame. Any column with unspecified data is filled with `NA`. |
| `df1 %>% bind_rows(df2)`     | Stack data frames `df1` and `df2` |
| `df %>% select(ColumnNames)` | Subset `df` and return a data frame with the *columns* specified. |
| `df %>% filter(logicalTest)`     | Subset `df` and return a data frame with the *rows* that satisfy the logical expression |
| `df %>% mutate( New= )`  | Create (or update) a column `New` with some manipulation of `Old` column. A common manipulation is to use an `ifelse()` command to update only particular rows.|


## Data frame (tibble) reshaping
These functions will modify an input data frame `df`

| Function   |   Meaning                            |
|:--------------------------------------------|:-------------------------------------|
| `group_by(df, Column1, Column2)` | Create a grouped tibble with groups defined by all unique combinations of `Column1` and `Column2` |
| `summarize(df, Function(Column1))` | Apply `Function` to `Column1` and return a data frame with just a single row. This is quite powerful when applied to a grouped tibble as it will result in a single row per group. |
| `df %>% pivot_wider(names_from=, values_from=)` | Create a _wide_ data set from a _long_ format |
| `df %>% pivot_longer(names_to, values_to)`      | Create a _long_ data set from a _wide_ format |




