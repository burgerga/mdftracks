mdftracks
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->

[![R-CMD-check](https://github.com/burgerga/mdftracks/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/burgerga/mdftracks/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/burgerga/mdftracks/branch/master/graph/badge.svg)](https://codecov.io/gh/burgerga/mdftracks)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/mdftracks)](https://cran.r-project.org/package=mdftracks)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4692671.svg)](https://doi.org/10.5281/zenodo.4692671)
<!-- badges: end -->

## Overview

mdftracks reads and writes
**[MTrackJ](https://imagescience.org/meijering/software/mtrackj/) Data
Files**
([`.mdf`](https://imagescience.org/meijering/software/mtrackj/format/)).
Supports clusters, 2D data, and channel information. If desired,
generates unique track identifiers based on cluster and id data from the
`.mdf` file.

## Installation

``` r
install.packages('mdftracks')
```

### Development version

To get a bug fix or to use a feature from the development version, you
can install the development version from GitHub.

``` r
# install.packages("remotes")
remotes::install_github("burgerga/mdftracks")
```

## Usage

First load the package with

``` r
library(mdftracks)
```

### Reading 3D data

``` r
mdf.file <- system.file("extdata", "example.mdf", package = 'mdftracks')
data <- read.mdf(mdf.file)
head(data, 10)
#>        cluster id time   x   y z
#> 1.1.1        1  1    1 782  43 1
#> 1.1.2        1  1    2 784  45 1
#> 1.1.3        1  1    3 780  47 1
#> 1.1.4        1  1    4 786  56 1
#> 1.1.5        1  1    5 794  65 1
#> 1.1.6        1  1    6 800  69 1
#> 1.1.7        1  1    7 805  88 1
#> 1.1.8        1  1    8 804 100 1
#> 1.1.9        1  1    9 814 110 1
#> 1.1.10       1  1   10 823 125 1
```

### Dropping the z-coordinate for 2D data

``` r
data <- read.mdf(mdf.file, drop.Z = T)
head(data, 10)
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
```

### Writing data in `(id, t, x, y, z)` format (e.g., from [celltrackR](https://github.com/ingewortel/celltrackR))

``` r
library('celltrackR')
tracks.df <- as.data.frame(TCells)
```

``` r
head(tracks.df, 10)
```

    #>    id   t       x       y
    #> 1   1  48 90.8534 65.3943
    #> 2   1  72 89.5923 64.9042
    #> 3   1  96 88.6958 67.1125
    #> 4   1 120 87.3437 68.2392
    #> 5   1 144 86.2740 67.9236
    #> 6   1 168 84.0549 68.2502
    #> 7   1 192 85.9669 68.5470
    #> 8   1 216 86.5280 69.0346
    #> 9   1 240 84.6638 69.4034
    #> 10  1 264 81.7699 69.9115

``` r
write.mdf(head(tracks.df, 10), pos.columns = c(3,4))
```

    #> Using the following column mapping:
    #> cluster      id    time       x       y       z channel   point 
    #>      NA    "id"     "t"     "x"     "y"      NA      NA      NA

    #> Converting factor to numeric in columns: id

    #> MTrackJ 1.5.1 Data File
    #> Assembly 1
    #> Cluster 1
    #> Track 1
    #> Point 1 90.8534 65.3943 1 48 1
    #> Point 2 89.5923 64.9042 1 72 1
    #> Point 3 88.6958 67.1125 1 96 1
    #> Point 4 87.3437 68.2392 1 120 1
    #> Point 5 86.274 67.9236 1 144 1
    #> Point 6 84.0549 68.2502 1 168 1
    #> Point 7 85.9669 68.547 1 192 1
    #> Point 8 86.528 69.0346 1 216 1
    #> Point 9 84.6638 69.4034 1 240 1
    #> Point 10 81.7699 69.9115 1 264 1
    #> End of MTrackJ Data File

### Writing data with cluster, channel, and point information

``` r
print(mdftracks.example.data)
```

    #>    cl id p     x     y    z t ch uid
    #> 1   1  1 1 187.1 263.2 27.4 1  2   1
    #> 2   1  1 3 309.2 264.4 15.8 2  2   1
    #> 3   1  2 1  18.4 438.5 28.1 1  2   2
    #> 4   1  2 2 142.9  58.6 28.2 2  2   2
    #> 5   1  2 5 290.1 197.5 18.8 3  2   2
    #> 6   2  1 1 310.1  15.4  5.8 1  2   3
    #> 7   2  2 1  99.1  33.5 22.5 1  2   4
    #> 8   2  2 2 220.2 396.0 16.4 2  2   4
    #> 9   2  3 1   8.4 305.8 30.2 1  2   5
    #> 10  2  3 2  84.7 227.7 21.1 2  2   5

``` r
write.mdf(mdftracks.example.data, cluster.column = 'cl', id.column = 'id',  
          pos.columns = letters[24:26], channel.column = 'ch', 
          point.column = "p")
```

    #> Using the following column mapping:
    #> cluster      id    time       x       y       z channel   point 
    #>    "cl"    "id"    "id"     "x"     "y"     "z"    "ch"     "p"

    #> MTrackJ 1.5.1 Data File
    #> Assembly 1
    #> Cluster 1
    #> Track 1
    #> Point 1 187.1 263.2 27.4 1 2
    #> Point 3 309.2 264.4 15.8 1 2
    #> Track 2
    #> Point 1 18.4 438.5 28.1 2 2
    #> Point 2 142.9 58.6 28.2 2 2
    #> Point 5 290.1 197.5 18.8 2 2
    #> Cluster 2
    #> Track 1
    #> Point 1 310.1 15.4 5.8 1 2
    #> Track 2
    #> Point 1 99.1 33.5 22.5 2 2
    #> Point 2 220.2 396 16.4 2 2
    #> Track 3
    #> Point 1 8.4 305.8 30.2 3 2
    #> Point 2 84.7 227.7 21.1 3 2
    #> End of MTrackJ Data File

For more information, please consult the package documentation.
