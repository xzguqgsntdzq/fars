https://travis-ci.org/xzguqgsntdzq/fars.svg?branch=master

# fars

fars is a project aimed to streamline plotting and creating summaries of fatal road accidents data. Given a vector of years it is able to create a table of numbers of accidents in each month in each  year using fars_summarize_years function. Maps are created with fars_map_state function which accepts state number and a year as arguments. 

## Installation

You can install fars from github with:


``` r
# install.packages("devtools")
devtools::install_github("xzguqgsntdzq/fars")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
fars_summarize_years(c(2013,2015))
```
