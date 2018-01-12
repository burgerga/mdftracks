mdftracks
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
![](http://www.r-pkg.org/badges/version/mdftracks) [![Build Status](https://travis-ci.org/burgerga/mdftracks.svg?branch=master)](https://travis-ci.org/burgerga/mdftracks) [![codecov](https://codecov.io/gh/burgerga/mdftracks/branch/master/graph/badge.svg)](https://codecov.io/gh/burgerga/mdftracks) [![License: GPL-3](https://img.shields.io/badge/license-GPL--3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

Reads and writes **[MTrackJ](https://imagescience.org/meijering/software/mtrackj/) Data Files** ([`.mdf`](https://imagescience.org/meijering/software/mtrackj/format/)). Supports clusters, 2D data, and channel information. If desired, generates unique track identifiers based on cluster and id data from the `.mdf` file.

Usage
-----

First load the package with

``` r
library(mdftracks)
```

**Reading 3D data**

``` r
mdf.file <- system.file("extdata", "example.mdf", package = 'mdftracks')
data <- read.mdf(mdf.file)
#> MTrackJ 1.5.1 Data File
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

**Dropping the z-coordinate for 2D data**

``` r
data <- read.mdf(mdf.file, drop.Z = T)
#> MTrackJ 1.5.1 Data File
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

**Writing data in `(id, t, x, y, z)` format (e.g., from [MotilityLab](https://github.com/jtextor/MotilityLab))**

``` r
library('MotilityLab')
tracks.df <- as.data.frame(TCells)
```

``` r
head(tracks.df, 10)
```

    #>    id       t       x       y    z
    #> 1   0   0.000 132.521 118.692 8.75
    #> 2   0  27.781 133.909 118.700 8.75
    #> 3   0  55.484 131.763 118.129 6.25
    #> 4   0  83.296 133.161 117.903 6.25
    #> 5   0 111.093 131.530 117.894 6.25
    #> 6   0 138.906 132.229 117.665 6.25
    #> 7   0 166.656 131.763 118.595 6.25
    #> 8   0 194.406 131.763 117.663 6.25
    #> 9   0 222.078 131.996 117.664 6.25
    #> 10  0 249.890 131.763 117.663 6.25

``` r
write.mdf(head(tracks.df, 10))
```

    #> Using the following column mapping:
    #> cluster      id    time       x       y       z channel   point 
    #>      NA    "id"     "t"     "x"     "y"     "z"      NA      NA

    #> Converting factor to numeric in columns: id

    #> MTrackJ 1.5.1 Data File
    #> Assembly 1
    #> Cluster 1
    #> Track 0
    #> Point 1 132.5209960938 118.6920013428 8.75 0 1
    #> Point 2 133.908996582 118.6999969482 8.75 27.7810001373 1
    #> Point 3 131.7630004883 118.1289978027 6.25 55.4840011597 1
    #> Point 4 133.1609954834 117.9029998779 6.25 83.2959976196 1
    #> Point 5 131.5299987793 117.8939971924 6.25 111.0930023193 1
    #> Point 6 132.2290039063 117.6650009155 6.25 138.9060058594 1
    #> Point 7 131.7630004883 118.5950012207 6.25 166.6560058594 1
    #> Point 8 131.7630004883 117.6630020142 6.25 194.4060058594 1
    #> Point 9 131.9960021973 117.6640014648 6.25 222.0780029297 1
    #> Point 10 131.7630004883 117.6630020142 6.25 249.8899993896 1
    #> End of MTrackJ Data File

**Writing data with cluster, channel, and point information**

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

For more information, consult the package documentation.

Installation
------------

``` r
install.packages('mdftracks')
```

How to cite?
------------

Please use the R command `citation(package = "mdftracks")` to get the most up-to-date citation. Example for v0.2.0:

``` r
citation(package = "mdftracks")
#> 
#> To cite package 'mdftracks' in publications use:
#> 
#>   Gerhard Burger (2017). mdftracks: Read and Write 'MTrackJ Data
#>   Files'. R package version 0.2.0.
#>   https://CRAN.R-project.org/package=mdftracks
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {mdftracks: Read and Write 'MTrackJ Data Files'},
#>     author = {Gerhard Burger},
#>     year = {2017},
#>     note = {R package version 0.2.0},
#>     url = {https://CRAN.R-project.org/package=mdftracks},
#>   }
```
