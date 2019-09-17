
# Factors
In R we can store categorical information as either strings or as factors. To a casual user, it often doesn't matter how the information is stored because the modeling and graphing programs happily convert strings into factors whenever necessary. However a deeper understanding of how factors are stored and manipulated allows a user much finer control in the modeling and graphing.

We will be interested in the following broad classes of manipulations:

#### Edit Factor Labels{-}

| Goal                             |  `forcats` function                                  |
|:---------------------------------|:-----------------------------------------------------|
| Manually change the label(s)     | `fct_recode(f, new_label = "old_label")`             |
| Systematically change all labels | `fct_relabel(f, function)`                           |


#### Reorder Levels {-}

| Goal                             |  `forcats` function                                  |
|:---------------------------------|:-----------------------------------------------------|
| Set order manually                                  | `fct_relevel(f, c('b', 'a', 'c'))`  |
| Set order based on another vector                        | `fct_reorder(f, x)`          |
| Set order based on which category is most frequent       | `fct_infreq(f)`              |
| Set order based on when they first appear                | `fct_inorder(f)`             |
| Reverse factor order                                     | `fct_rev(f)`                 |
| Rotate order left or right                               | `fct_shift(f, steps)`        |


#### Add or Subtract Levels {-}

| Goal                             |  `forcats` function                                    |
|:---------------------------------|:-------------------------------------------------------|
| Manually select categories to collapse into one |  `fct_collapse(f, other = c('a','b')) ` |
| 



## Creation and Structure
R stores factors as a combination of a vector of category labels and vector of integers representing which category a data value belongs to. For example, lets create a vector of data relating to what soft drinks my siblings prefer.

```r
# A vector of character strings.
drinks <- c('Coke', 'Coke', 'Sprite', 'Pepsi', 'DietCoke')
str(drinks)
```

```
##  chr [1:5] "Coke" "Coke" "Sprite" "Pepsi" "DietCoke"
```

```r
# convert the vector of character strings into a factor vector
drinks <- factor(drinks)
str(drinks)        # Show the structure of the factor
```

```
##  Factor w/ 4 levels "Coke","DietCoke",..: 1 1 4 3 2
```

```r
levels(drinks)     # Print out the categories, notice the order matters!
```

```
## [1] "Coke"     "DietCoke" "Pepsi"    "Sprite"
```

```r
as.integer(drinks) # Print the category assigments
```

```
## [1] 1 1 4 3 2
```

Notice that the factor has levels "Coke", "DietCoke", "Pepsi", and "Sprite" and that the order of these levels is very important because each observation is saved as an *integer* which denotes which category the observation belongs to. Because it takes less memory to store a single integer instead of potentially very long character string, factors are much more space efficient than storing the same data as strings.

Because the factor has both a character string representation as well as numeric value, we can convert a factor to either one.

```r
as.character(drinks)
```

```
## [1] "Coke"     "Coke"     "Sprite"   "Pepsi"    "DietCoke"
```

```r
as.integer(drinks)
```

```
## [1] 1 1 4 3 2
```

## Change Labels

## Reorder Levels

## Add or substract Levels


