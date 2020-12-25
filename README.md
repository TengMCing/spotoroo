
<!-- README.md is generated from README.Rmd. Please edit that file -->

# hotspotcluster

<!-- badges: start -->

<!-- badges: end -->

The goal of hotspotcluster is to …

## Installation

<!-- You can install the released version of hotspotcluster from [CRAN](https://CRAN.R-project.org) with: -->

<!-- ``` r -->

<!-- install.packages("hotspotcluster") -->

<!-- ``` -->

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("TengMCing/hotspotcluster")
```

## Example

This is a basic example which shows you how to solve a common problem:

The first 20 observations of the built-in dataset `hotspots`.

``` r
hotspotcluster::hotspots[1:20,]
#>    id    lon    lat time_id
#> 1   1 141.12 -37.10       1
#> 2   2 141.14 -37.10       1
#> 3   3 141.12 -37.12       1
#> 4   4 141.14 -37.12       1
#> 5   5 141.16 -37.12       1
#> 6   6 141.12 -37.14       1
#> 7   7 141.14 -37.14       1
#> 8   8 141.16 -37.14       1
#> 9   9 141.12 -37.16       1
#> 10 10 141.14 -37.16       1
#> 11 11 141.10 -37.12       1
#> 12 12 141.10 -37.14       1
#> 13 13 141.10 -37.12       2
#> 14 14 141.12 -37.12       2
#> 15 15 141.14 -37.12       2
#> 16 16 141.10 -37.14       2
#> 17 17 141.12 -37.14       2
#> 18 18 141.14 -37.14       2
#> 19 19 141.30 -37.64       2
#> 20 20 141.30 -37.66       2
```

Perform spatiotemporal clustering on this data.

``` r
results <- hotspotcluster::hotspot_cluster(hotspots)
#> Clustering <U+2713> 
#> Compute ignition points <U+2713> 
#> Time taken: 0 mins 26 secs for 5000 observations
#> (0.005 secs/obs)
```

The ignition points of the first 20 bushfires.

``` r
data.frame(lon = results$ignition_lon, lat = results$ignition_lat)[1:20,]
#>         lon       lat
#> 1  141.1300 -37.13000
#> 2  141.3000 -37.65000
#> 3  141.4800 -37.35000
#> 4  147.1600 -37.85000
#> 5  148.1050 -37.57999
#> 6  144.1800 -38.35000
#> 7  143.5800 -36.15000
#> 8  143.1425 -37.28250
#> 9  141.1500 -36.54000
#> 10 143.3600 -37.32000
#> 11 148.6300 -37.47000
#> 12 148.4233 -37.10333
#> 13 148.8000 -37.30000
#> 14 148.8000 -37.36000
#> 15 148.8500 -37.38000
#> 16 144.7400 -36.86000
#> 17 144.2300 -37.28000
#> 18 143.6300 -36.12000
#> 19 143.6333 -36.12667
#> 20 143.8700 -36.84000
```

The memberships of the first 20 hotspots.

``` r
results$memberships[1:20]
#>  [1] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2
```
