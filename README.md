
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
install.packages("devtools")
devtools::install_github("TengMCing/hotspotcluster")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(hotspotcluster)
```

The built-in dataset `hotspots5000`.

``` r
str(hotspots5000)
#> 'data.frame':    5000 obs. of  4 variables:
#>  $ id     : int  1 2 3 4 5 6 7 8 9 10 ...
#>  $ lon    : num  141 141 141 141 141 ...
#>  $ lat    : num  -37.1 -37.1 -37.1 -37.1 -37.1 ...
#>  $ obstime: POSIXct, format: "2019-10-01 03:20:00" "2019-10-01 03:20:00" ...
```

``` r
hotspots5000[1:10,]
#>    id    lon    lat             obstime
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
library(rnaturalearth)
au_map <- ne_states(country = "Australia", returnclass = "sf")
vic_map <- au_map[7,]
ggplot(hotspots5000) +
  geom_sf(data = vic_map) +
  geom_point(aes(lon, lat), alpha = 0.3) +
  ggthemes::theme_map() +
  ggtitle("Raw Hotspots")
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="70%" height="70%" />

Perform spatiotemporal clustering on this dataset.

``` r
results <- hotspot_cluster(hotspots5000, 
                           lon = "lon", 
                           lat = "lat", 
                           obstime = "obstime",
                           ActiveTime = 24,
                           AdjDist = 3000,
                           ignition_center = "mean",
                           time_unit = "hours",
                           timestep = 1)
#> Transform time_id <U+2713> 
#> Clustering <U+2713> 
#> Compute ignition points <U+2713> 
#> Time taken: 0 mins 34 secs for 5000 obs (0.007 secs/obs)
```

The ignition points of the first 10 bushfires.

``` r
results$ignitions[1:10,]
#>    ignition_lon ignition_lat    ignition_obstime
#> 1       141.136    -37.13000 2019-10-01 03:20:00
#> 2       141.300    -37.65000 2019-10-01 04:30:00
#> 3       141.480    -37.34000 2019-10-02 03:00:00
#> 4       147.160    -37.85000 2019-10-02 04:40:00
#> 5       148.120    -37.57999 2019-10-02 04:50:00
#> 6       143.140    -37.25999 2019-10-03 01:00:00
#> 7       141.150    -36.54000 2019-10-03 04:30:00
#> 8       148.435    -37.10000 2019-10-06 04:00:00
#> 9       144.240    -37.28000 2019-10-14 21:40:00
#> 10      143.870    -36.84000 2019-10-21 02:10:00
```

The memberships of the first 10 hotspots.

``` r
results$hotspots[1:10,]
#>       lon    lat             obstime memberships noise
#> 1  141.12 -37.10 2019-10-01 03:20:00           1 FALSE
#> 2  141.14 -37.10 2019-10-01 03:20:00           1 FALSE
#> 3  141.12 -37.12 2019-10-01 03:20:00           1 FALSE
#> 4  141.14 -37.12 2019-10-01 03:20:00           1 FALSE
#> 5  141.16 -37.12 2019-10-01 03:20:00           1 FALSE
#> 6  141.12 -37.14 2019-10-01 03:20:00           1 FALSE
#> 7  141.14 -37.14 2019-10-01 03:20:00           1 FALSE
#> 8  141.16 -37.14 2019-10-01 03:20:00           1 FALSE
#> 9  141.12 -37.16 2019-10-01 03:20:00           1 FALSE
#> 10 141.14 -37.16 2019-10-01 03:20:00           1 FALSE
```

``` r
ggplot(results$ignitions) +
  geom_sf(data = vic_map) +
  geom_point(aes(ignition_lon, ignition_lat), alpha = 0.5) +
  ggthemes::theme_map() +
  ggtitle("Ignition Points")
```

<img src="man/figures/README-unnamed-chunk-9-1.png" width="70%" height="70%" />

Summary of the clustering result.

``` r
summary(results)
#> Clusters:
#>     total    110 
#>     ave obs  43.6 
#>     ave time 16.3 hours 
#> Noises:
#>     prop     4    %
```

Plot of the result.

``` r
p <- ggplot() +
  geom_sf(data = vic_map) +
  ggthemes::theme_map()
plot(results, ignition = TRUE, bottom = p)
```

<img src="man/figures/README-unnamed-chunk-11-1.png" width="70%" height="70%" />
