#' simple features map of Victoria
#'
#' A dataset containing the simple features of Victoria, Australia.
#'
#' The dataset is obtained via the following codes:\cr
#' \code{library(rnaturalearth)}\cr
#' \code{au_map <- ne_states(country = "Australia", returnclass = "sf")}\cr
#' \code{vic_map <- au_map[7,]$geometry}
#'
#'
#' @format A "\code{sf}" object with 1 row
#' @source \url{https://www.naturalearthdata.com/}
"vic_map"

#' 1070 observations of satellite hot spots
#'
#' A dataset containing the 1070 observations of satellite hot spots in
#' Victoria, Australia during the 2019-2020 Australian bushfire season.
#'
#' @format A data frame with 1070 rows and 3 variables:
#' \describe{
#'   \item{lon}{longitude}
#'   \item{lat}{latitude}
#'   \item{obsTime}{observed time}
#' }
#' @source \url{https://www.eorc.jaxa.jp/ptree/}
"hotspots"
