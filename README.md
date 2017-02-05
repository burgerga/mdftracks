mdftracks
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/burgerga/mdftracks.svg?branch=master)](https://travis-ci.org/burgerga/mdftracks) [![codecov](https://codecov.io/gh/burgerga/mdftracks/branch/master/graph/badge.svg)](https://codecov.io/gh/burgerga/mdftracks)

Reads and writes **[MTrackJ](https://imagescience.org/meijering/software/mtrackj/) Data Files** ([`.mdf`](https://imagescience.org/meijering/software/mtrackj/format/)). Supports clusters, 2D data, and channel information. If desired, generates unique track identifiers based on cluster and id data from the `.mdf` file.

Usage
-----

First load the package with `library(mdftracks)`.

**Reading 3D data: **

``` r
data <- read.mdf('~/mdftracks.mdf')
head(data, 10)
```

    #> MTrackJ 1.5.1 Data File
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

**Reading 2D data: **

``` r
data <- read.mdf('~/mdftracks.mdf', drop.Z = T)
head(data, 10)
```

    #> MTrackJ 1.5.1 Data File
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

**Writing data in `(id, t, x, y, z)` format (e.g., from [MotilityLab](https://github.com/jtextor/MotilityLab)): **

``` r
print(tracks)
```

    #>    uid t     x     y    z
    #> 1    1 1 187.1 263.2 27.4
    #> 2    1 2 309.2 264.4 15.8
    #> 3    2 1  18.4 438.5 28.1
    #> 4    2 2 142.9  58.6 28.2
    #> 5    2 3 290.1 197.5 18.8
    #> 6    3 1 310.1  15.4  5.8
    #> 7    4 1  99.1  33.5 22.5
    #> 8    4 2 220.2 396.0 16.4
    #> 9    5 1   8.4 305.8 30.2
    #> 10   5 2  84.7 227.7 21.1

``` r
write.mdf(tracks)
```

    #> Using the following column mapping:
    #> cluster      id    time       x       y       z channel   point 
    #>      NA   "uid"     "t"     "x"     "y"     "z"      NA      NA

    #> MTrackJ 1.5.1 Data File
    #> Assembly 1
    #> Cluster 1
    #> Track 1
    #> Point 1 187.1 263.2 27.4 1.0 1.0
    #> Point 2 309.2 264.4 15.8 2.0 1.0
    #> Track 2
    #> Point 1 18.4 438.5 28.1 1.0 1.0
    #> Point 2 142.9 58.6 28.2 2.0 1.0
    #> Point 3 290.1 197.5 18.8 3.0 1.0
    #> Track 3
    #> Point 1 310.1 15.4 5.8 1.0 1.0
    #> Track 4
    #> Point 1 99.1 33.5 22.5 1.0 1.0
    #> Point 2 220.2 396.0 16.4 2.0 1.0
    #> Track 5
    #> Point 1 8.4 305.8 30.2 1.0 1.0
    #> Point 2 84.7 227.7 21.1 2.0 1.0
    #> End of MTrackJ Data File

**Writing data with cluster, channel, and point information: **

``` r
print(tracks)
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
write.mdf(tracks, cluster.column = 'cl', id.column = 'id', 
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
    #> Point 1 187.1 263.2 27.4 1.0 2.0
    #> Point 3 309.2 264.4 15.8 1.0 2.0
    #> Track 2
    #> Point 1 18.4 438.5 28.1 2.0 2.0
    #> Point 2 142.9 58.6 28.2 2.0 2.0
    #> Point 5 290.1 197.5 18.8 2.0 2.0
    #> Cluster 2
    #> Track 1
    #> Point 1 310.1 15.4 5.8 1.0 2.0
    #> Track 2
    #> Point 1 99.1 33.5 22.5 2.0 2.0
    #> Point 2 220.2 396.0 16.4 2.0 2.0
    #> Track 3
    #> Point 1 8.4 305.8 30.2 3.0 2.0
    #> Point 2 84.7 227.7 21.1 3.0 2.0
    #> End of MTrackJ Data File

For more information, consult the package documentation.

Installation
------------

``` r
install.packages('mdftracks')
```
