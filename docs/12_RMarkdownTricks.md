# Rmarkdown Tricks{-}


We have been using RMarkdown files to combine the analysis and discussion into one nice document that contains all the analysis steps so that your research is  reproducible. 

There are many resources on the web about Markdown and the variant that RStudio uses (called RMarkdown), but the easiest reference is to just use the RStudio help tab to access the help.  I particular like `Help -> Cheatsheets -> RMarkdown Reference Guide` because it gives me the standard Markdown information but also a bunch of information about the options I can use to customize the behavior of individual R code chunks.

Most of what is presented here isn't primarily about how to use R, but rather how to work with tools in RMarkdown so that the final product is neat and tidy. While you could print out your RMarkdown file and then clean it up in MS Word, sometimes there is a good to want as nice a starting point as possible. 

## Chunk Options{-}

## Verbatim & List Environments{-} 

## Mathematical expressions{-}

The primary way to insert a mathematical expression is to use a markup language 
called LaTeX. This is a very powerful system and it is what most Mathematicians 
use to write their documents. The downside is that there is a lot to learn. 
However, you can get most of what you need pretty easily. 

For RMarkdown to recognize you are writing math using LaTeX, you need to 
enclose the LaTeX with dollar signs ($). Some examples of common LaTeX patterns 
are given below:

|   Goal       |   LaTeX      |   Output    |   LaTeX       |  Output        |
|:------------:|:----------------:|:-----------:|:-------------:|:--------------:|
|   power      | ``` $x^2$ ```    |  $x^2$      |  ``` $y^{0.95}$ ``` |  $y^{0.95}$    |
|  Subscript   | ``` $x_i$ ```        |  $x_i$  |  ``` $t_{24}$ ```       | $t_{24}$       |
|  Greek       | ``` $\alpha$ $\beta$ ``` | $\alpha$ $\beta$ | ``` $\theta$ $\Theta$ ``` | $\theta$ $\Theta$ |
|  Bar         | ``` $\bar{x}$ ```      | $\bar{x}$    | ``` $\bar{mu}_i$ ```    | $\bar{\mu}_i$    |
|  Hat         | ``` $\hat{mu}$ ```     | $\hat{\mu}$   | ``` $\hat{y}_i$ ```     | $\hat{y}_i$     |
| Star         | ``` $y^*$ ```           | $y^*$         | ``` $\hat{\mu}^*_i$ ```   | $\hat{\mu}^*_i$  |
| Centered Dot | ``` $\cdot$ ```        | $\cdot$       | ``` $\bar{y}_{i\cdot}$ ``` | $\bar{y}_{i\cdot}$ |
| Sum          | ``` $\sum x_i$ ```     | $\sum x_i$    | ``` $\sum_{i=0}^N x_i$ ``` | $\sum_{i=0}^N x_i$ |
||||||
| Square Root  | ``` $\sqrt{a}$ ```     | $\sqrt{a}$    | ``` $\sqrt{a^2 + b^2}$ ``` | $\sqrt{a^2 + b^2}$  |
||||||
| Fractions    | ``` $\frac{a}{b}$ ```  | $\frac{a}{b}$ | ``` $\frac{x_i - \bar{x}{s/\sqrt{n}$ ```| $\frac{x_i - \bar{x}}{s/\sqrt{n}}$ |

Within your RMarkdown document, you can include LaTeX code by enclosing it with 
dollar signs. So you might write ``` $\alpha=0.05$ ```  in your text, but 
after it is knitted to a pdf, html, or Word, you'll see $\alpha=0.05$.
If you want your mathematical equation to be on its own line, all by itself, 
enclose it with double dollar signs. So 

``` $$z_i = \frac{z_i-\bar{x}}{\sigma / \sqrt{n}}$$ ``` 

would be displayed as 

$$ z_{i}=\frac{x_{i}-\bar{X}}{\sigma/\sqrt{n}} $$
 
Unfortunately RMarkdown is a little picky about spaces near the `$` and `$$` signs 
and you can't have any spaces between them and the LaTeX command. For a more 
information about all the different symbols you can use, google 
'LaTeX math symbols'.

## Tables {-}
For the following descriptions of the simple, grid, and pipe tables, I've 
shamelessly stolen from the Pandoc documentation. 
[http://pandoc.org/README.html#tables]

One way to print a table is to just print in in R and have the table presented 
in the code chunk. For example, suppose I want to print out the first 4 rows 
of the trees dataset.


```r
data <- trees[1:4, ]
data
```

```
##   Girth Height Volume
## 1   8.3     70   10.3
## 2   8.6     65   10.3
## 3   8.8     63   10.2
## 4  10.5     72   16.4
```

Usually this is sufficient, but suppose you want something a bit nicer because 
you are generating tables regularly and you don't want to have to clean them up 
by hand. Tables in RMarkdown follow the table conventions from the Markdown class 
with a few minor exceptions. Markdown provides 4 ways to define a table and 
RMarkdown supports 3 of those.

### Simple Tables
Simple tables look like this (Notice I don't wrap these dollar signs or anything,
just a blank line above and below the table): 


```r
Right   Left     Center   Default 
------- ------ ---------- ------- 
     12 12        hmmm        12 
    123 123        123       123 
      1 1            1         1
```

and would be rendered like this:

Right   Left     Center   Default 
------- ------ ---------- ------- 
     12 12        hmmm        12 
    123 123        123       123 
      1 1            1         1

The headers and table rows must each fit on one line. Column alignments are 
determined by the position of the header text relative to the dashed line below
it.

If the dashed line is flush with the header text on the right side but extends 
beyond it on the left, the column is right-aligned. If the dashed line is flush
with the header text on the left side but extends beyond it on the right, the 
column is left-aligned. If the dashed line extends beyond the header text on 
both sides, the column is centered. If the dashed line is flush with the header 
text on both sides, the default alignment is used (in most cases, this will be 
left). The table must end with a blank line, or a line of dashes followed by a 
blank line.

### Grid Tables
Grid tables are a little more flexible and each cell can take an arbitrary 
Markdown block elements (such as lists).


```r
+---------------+---------------+--------------------+
| Fruit         | Price         | Advantages         |
+===============+===============+====================+
| Bananas       | $1.34         | - built-in wrapper |
|               |               | - bright color     |
+---------------+---------------+--------------------+
| Oranges       | $2.10         | - cures scurvy     |
|               |               | - tasty            |
+---------------+---------------+--------------------+
```
which is rendered as the following:

+---------------+---------------+--------------------+
| Fruit         | Price         | Advantages         |
+===============+===============+====================+
| Bananas       | $1.34         | - built-in wrapper |
|               |               | - bright color     |
+---------------+---------------+--------------------+
| Oranges       | $2.10         | - cures scurvy     |
|               |               | - tasty            |
+---------------+---------------+--------------------+

Grid table doesn't support Left/Center/Right alignment. Both Simple tables and 
Grid tables require you to format the blocks nicely inside the RMarkdown file and 
that can be a bit annoying if something changes and you have to fix the spacing 
in the rest of the table. Both Simple and Grid tables don't require column headers.

### Pipe Tables
Pipe tables look quite similar to grid tables but Markdown isn't as picky about the 
pipes lining up. However, it does require a header row (which you could leave
the elements blank in).


```r
| Right | Left | Default | Center |
|------:|:-----|---------|:------:|
|   12  |  12  |    12   |    12  |
|  123  |  123 |   123   |   123  |
|    1  |    1 |     1   |     1  |
```
which will render as the following:

| Right | Left | Default | Center |
|------:|:-----|---------|:------:|
|   12  |  12  |    12   |    12  |
|  123  |  123 |   123   |   123  |
|    1  |    1 |     1   |     1  |

In general I prefer to use the pipe tables because it seems a little less
picky about getting everything correct. However it is still pretty
annoying to get the table laid out correctly.

In all of these tables, you can use the regular RMarkdown formatting tricks
for italicizing and bolding. So I could have a table such as the following:


```r
|   Source    |  df  |   Sum of Sq   |    Mean Sq    |    F   |  $Pr(>F_{1,29})$    |
|:------------|-----:|--------------:|--------------:|-------:|--------------------:|
|  Girth      |  *1* |  7581.8       |  7581.8       | 419.26 |  **< 2.2e-16**      |
|  Residual   |  29  |  524.3        |   18.1        |        |                     |
```
and have it look like this:

|   Source    |  df  |   Sum of Sq   |    Mean Sq    |    F   |  $Pr(>F_{1,29})$    |
|:------------|-----:|--------------:|--------------:|-------:|--------------------:|
|  Girth      |  *1* |  7581.8       |  7581.8       | 419.26 |  **< 2.2e-16**      |
|  Residual   |  29  |  524.3        |   18.1        |        |                     |

The problem with all of this is that I don't want to create these by hand. Instead
I would like functions that take a data frame or matrix and spit out the RMarkdown
code for the table.

## R functions to produce table code.{-}
There are a couple of different packages that convert a data frame to 
simple/grid/pipe table.  We will explore a couple of these, starting with the
most basic and moving to the more complicated. The general idea is that we'll 
produce the appropriate simple/grid/pipe table syntax in R, and when it gets
knitted, then RMarkdown will turn our simple/grid/pipe table into something pretty.


### `knitr::kable`{-}
The `knitr` package includes a function that produces simple tables. It doesn't
have much customizability, but it gets the job done. One nice aspect about `kable` compared to `pander` is that we don't need to set any additional chunk options.


```r
knitr::kable( data )
```



 Girth   Height   Volume
------  -------  -------
   8.3       70     10.3
   8.6       65     10.3
   8.8       63     10.2
  10.5       72     16.4

### Package `pander`{-}
The package `pander` seems to be a nice compromise between customization
and not having to learn too much. It is relatively powerful in that it will
take `summary()` and `anova()` output and produce tables for them. By default 
`pander` will produce simple tables, but you can ask for Grid or Pipe tables.

To use `pander` results, we need to add the chunk option `results='hold'` to chunk so that the knitting process doesn't try to convert the output into 


```r
pander::pander( data, style='rmarkdown' )   # style is pipe tables...
```



| Girth | Height | Volume |
|:-----:|:------:|:------:|
|  8.3  |   70   |  10.3  |
|  8.6  |   65   |  10.3  |
|  8.8  |   63   |  10.2  |
| 10.5  |   72   |  16.4  |

The `pander` package deals with summary and anova tables from
a variety of different analyses. So you can simply ask for a
nice looking version using the following:


```r
model <- lm( Volume ~ Girth, data=trees )    # a simple regression
pander::pander( summary(model) )    # my usual summary table
pander::pander( anova( model ) )    # my usual anova table
```


---------------------------------------------------------------
     &nbsp;        Estimate   Std. Error   t value   Pr(>|t|)  
----------------- ---------- ------------ --------- -----------
 **(Intercept)**    -36.94      3.365      -10.98    7.621e-12 

    **Girth**       5.066       0.2474      20.48    8.644e-19 
---------------------------------------------------------------


--------------------------------------------------------------
 Observations   Residual Std. Error   $R^2$    Adjusted $R^2$ 
-------------- --------------------- -------- ----------------
      31               4.252          0.9353       0.9331     
--------------------------------------------------------------

Table: Fitting linear model: Volume ~ Girth


-------------------------------------------------------------
    &nbsp;       Df   Sum Sq   Mean Sq   F value    Pr(>F)   
--------------- ---- -------- --------- --------- -----------
   **Girth**     1     7582     7582      419.4    8.644e-19 

 **Residuals**   29   524.3     18.08      NA         NA     
-------------------------------------------------------------

Table: Analysis of Variance Table
