
<!-- README.md is generated from README.Rmd. Please edit that file -->

# spotoroo

<!-- badges: start -->

<!-- badges: end -->

The goal of spotoroo is to …

## Installation

<!-- You can install the released version of spotoroo from [CRAN](https://CRAN.R-project.org) with: -->

<!-- ``` r -->

<!-- install.packages("spotoroo") -->

<!-- ``` -->

You can install the development version from
[GitHub](https://github.com/) with:

``` r
install.packages("devtools")
devtools::install_github("TengMCing/spotoroo")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(spotoroo)
```

The built-in dataset `hotspots500`.

``` r
str(hotspots500)
#> 'data.frame':    500 obs. of  4 variables:
#>  $ id     : int  1 2 3 4 5 6 7 8 9 10 ...
#>  $ lon    : num  141 141 141 141 141 ...
#>  $ lat    : num  -37.1 -37.1 -37.1 -37.1 -37.1 ...
#>  $ obsTime: POSIXct, format: "2019-10-01 03:20:00" "2019-10-01 03:20:00" ...
```

``` r
hotspots500[1:10,]
#>    id    lon    lat             obsTime
#> 1   1 141.12 -37.10 2019-10-01 03:20:00
#> 2   2 141.14 -37.10 2019-10-01 03:20:00
#> 3   3 141.12 -37.12 2019-10-01 03:20:00
#> 4   4 141.14 -37.12 2019-10-01 03:20:00
#> 5   5 141.16 -37.12 2019-10-01 03:20:00
#> 6   6 141.12 -37.14 2019-10-01 03:20:00
#> 7   7 141.14 -37.14 2019-10-01 03:20:00
#> 8   8 141.16 -37.14 2019-10-01 03:20:00
#> 9   9 141.12 -37.16 2019-10-01 03:20:00
#> 10 10 141.14 -37.16 2019-10-01 03:20:00
```

``` r
library(tidyverse)
ggplot(hotspots500) +
  geom_sf(data = vic_map) +
  geom_point(aes(lon, lat), alpha = 0.3) +
  ggthemes::theme_map() +
  ggtitle("Raw Hotspots")
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="70%" height="70%" />

Perform spatiotemporal clustering on this dataset.

``` r
result <- hotspot_cluster(hotspots500,
                          lon = "lon",
                          lat = "lat",
                          obsTime = "obsTime",
                          activeTime = 24,
                          adjDist = 3000,
                          minPts = 4,
                          ignitionCenter = "mean",
                          timeUnit = "h",
                          timeStep = 1)
#> 
#> ------------------------------ SPOTOROO 0.0.0.9000 -----------------------------
#> 
#> -- Calling Core Function : `hotspot_cluster()` --
#> 
#> -- 1 time index = 1 hours
#> √ Transform observed time > time indexes
#> i 1226 time indexes found
#> 
#> -- activeTime = 24 time indexes | adjDist = 3000 meters
#> √ Cluster
#> i 68 clusters found (including noise)
#> 
#> -- minPts = 4
#> √ Handle noise
#> i 38 clusters left
#> i noise propotion : 11.6 %
#> 
#> -- ignitionCenter = 'mean'
#> √ Compute ignition points for clusters
#> i average hotspots : 11.6
#> i average duration : 1.9 hours
#> 
#> -- Time taken = 0 mins 1 sec for 500 hotspots
#> i 0.002 secs per hotspot
#> 
#> --------------------------------------------------------------------------------
```

The ignition points of the first 10 bushfires.

``` r
result$ignition[1:10,]
#>    membership     lon       lat             obsTime timeID obsInCluster
#> 1           1 141.136 -37.13000 2019-10-01 03:20:00      1           18
#> 2           2 141.300 -37.65000 2019-10-01 04:30:00      2            4
#> 3           3 141.480 -37.34000 2019-10-02 03:00:00     24           19
#> 4           4 147.160 -37.85000 2019-10-02 04:40:00     26            9
#> 5           5 148.120 -37.57999 2019-10-02 04:50:00     26            4
#> 6           6 143.140 -37.25999 2019-10-03 01:00:00     46           25
#> 7           7 141.150 -36.54000 2019-10-03 04:30:00     50            5
#> 8           8 148.435 -37.10000 2019-10-06 04:00:00    121            6
#> 9           9 144.240 -37.28000 2019-10-14 21:40:00    331            5
#> 10         10 143.870 -36.84000 2019-10-21 02:10:00    479           29
#>     clusterTimeLen clusterTimeLenUnit
#> 1  0.6666667 hours                  h
#> 2  0.6666667 hours                  h
#> 3  4.6666667 hours                  h
#> 4  1.5000000 hours                  h
#> 5  0.1666667 hours                  h
#> 6  4.1666667 hours                  h
#> 7  1.0000000 hours                  h
#> 8  0.1666667 hours                  h
#> 9  2.3333333 hours                  h
#> 10 2.8333333 hours                  h
```

The memberships of the first 10 hotspots.

``` r
result$hotspots[1:10,]
#>       lon    lat             obsTime timeID membership noise distToIgnition
#> 1  141.12 -37.10 2019-10-01 03:20:00      1          1 FALSE       3622.871
#> 2  141.14 -37.10 2019-10-01 03:20:00      1          1 FALSE       3352.773
#> 3  141.12 -37.12 2019-10-01 03:20:00      1          1 FALSE       1801.324
#> 4  141.14 -37.12 2019-10-01 03:20:00      1          1 FALSE       1166.473
#> 5  141.16 -37.12 2019-10-01 03:20:00      1          1 FALSE       2399.356
#> 6  141.12 -37.14 2019-10-01 03:20:00      1          1 FALSE       1801.324
#> 7  141.14 -37.14 2019-10-01 03:20:00      1          1 FALSE       1166.473
#> 8  141.16 -37.14 2019-10-01 03:20:00      1          1 FALSE       2399.356
#> 9  141.12 -37.16 2019-10-01 03:20:00      1          1 FALSE       3622.871
#> 10 141.14 -37.16 2019-10-01 03:20:00      1          1 FALSE       3352.773
#>    distToIgnitionUnit timeFromIgnition timeFromIgnitionUnit
#> 1                   m          0 hours                    h
#> 2                   m          0 hours                    h
#> 3                   m          0 hours                    h
#> 4                   m          0 hours                    h
#> 5                   m          0 hours                    h
#> 6                   m          0 hours                    h
#> 7                   m          0 hours                    h
#> 8                   m          0 hours                    h
#> 9                   m          0 hours                    h
#> 10                  m          0 hours                    h
```

<!-- Summary of the clustering result. -->

<!-- ```{r} -->

<!-- summary(results) -->

<!-- ``` -->

Plot of the result.

``` r
p <- ggplot() +
  geom_sf(data = vic_map) +
  ggthemes::theme_map()
plot(result,
     type = "def",
     cluster = "all",
     hotspot = TRUE, 
     noise = TRUE, 
     ignition = TRUE, 
     bg = p)
```

<img src="man/figures/README-unnamed-chunk-9-1.png" width="70%" height="70%" />

``` r
plot(result,
     type = "def",
     cluster = 1:3,
     hotspot = TRUE, 
     noise = FALSE, 
     ignition = TRUE)
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="70%" height="70%" />

``` r
plot(result,
     type = "mov",
     cluster = c(26, 28),
     hotspot = TRUE, 
     noise = FALSE)
```

<img src="man/figures/README-unnamed-chunk-11-1.png" width="70%" height="70%" />
