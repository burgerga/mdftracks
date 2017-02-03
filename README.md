mdftracks
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/burgerga/mdftracks.svg?branch=master)](https://travis-ci.org/burgerga/mdftracks) [![codecov](https://codecov.io/gh/burgerga/mdftracks/branch/master/graph/badge.svg)](https://codecov.io/gh/burgerga/mdftracks)

Reads and writes '.mdf' (MTrackJ Data Format) files. Supports clusters, 2D data, and channel information. If desired, generates unique track identifiers based on cluster and id data from the '.mdf' file.

Usage
=====

``` r
library(mdftracks)
data <- read.mdf('~/mdftracks.mdf', drop.Z = T)
head(data, 10)
```

    #>        cluster id time   x   y
    #> 1.1.1        1  1    1 782  43
    #> 1.1.2        1  1    2 784  45
    #> 1.1.3        1  1    3 780  47
    #> 1.1.4        1  1    4 786  56
    #> 1.1.5        1  1    5 794  65
    #> 1.1.6        1  1    6 800  69
    #> 1.1.7        1  1    7 805  88
    #> 1.1.8        1  1    8 804 100
    #> 1.1.9        1  1    9 814 110
    #> 1.1.10       1  1   10 823 125

Installation
============

With the `devtools` package installed:

``` r
install_github('burgerga/mdftracks')
```
