#' Clustering hot spots spatially and temporally
#'
#' This function clusters hot spots spatially and temporally.
#'
#' For more details about the clustering algorithm and the arguments
#' `activeTime` and `adjDist`, please check the documentation
#' of [hotspot_cluster()].
#' This function performs the **first 3 steps** of the clustering algorithm.
#'
#' @param lon Numeric. A vector of longitude values.
#' @param lat Numeric. A vector of latitude values.
#' @param timeID Integer (>=1). A vector of time indexes.
#' @param activeTime Numeric (>=0). Time tolerance. Unit is time index.
#' @param adjDist Numeric (>0). Distance tolerance. Unit is metre.
#' @return Integer. A vector of membership labels.
#' @examples
#'
#' # Define lon, lat and timeID for 10 observations
#' lon <- c(141.1, 141.14, 141.12, 141.14, 141.16, 141.12, 141.14,
#'           141.16, 141.12, 141.14)
#' lat <- c(-37.10, -37.10, -37.12, -37.12, -37.12, -37.14, -37.14,
#'          -37.14, -37.16, -37.16)
#' timeID <- c(rep(1, 5), rep(26, 5))
#'
#' # Cluster 10 hot spots with different values of activeTime and adjDist
#' global_clustering(lon, lat, timeID, 12, 1500)
#' global_clustering(lon, lat, timeID, 24, 3000)
#' global_clustering(lon, lat, timeID, 36, 6000)
#'
#' @export
global_clustering <- function(lon, lat, timeID, activeTime, adjDist) {

  cli::cli_div(theme = list(span.vrb = list(color = "yellow",
                                            `font-weight` = "bold"),
                            span.unit = list(color = "magenta"),
                            .val = list(digits = 3),
                            span.side = list(color = "grey")))
  cli::cli_h3("{.field activeTime} = {.val {activeTime}} {.unit time index{?es}} | {.field adjDist} = {.val {adjDist}} {.unit meter{?s}}")


  global_membership <- rep(0, length(lon))

  barstr <- "Clustering [:bar] :current/:total (:percent) eta: :eta"

  pb <- progress::progress_bar$new(format = barstr,
                                   total = max(timeID))
  pb$tick(0)

  for (t in 1:max(timeID)) {

    pb$tick(1)

    # find hot spots in the current interval
    indexes <- define_interval(timeID, t, activeTime)

    # safety checks
    if (is.null(indexes)) next
    if (all(global_membership[indexes] != 0)) next

    # perform clustering spatially
    local_membership <- local_clustering(lon[indexes], lat[indexes], adjDist)

    # update membership
    global_membership <-  update_membership(lon,
                                            lat,
                                            global_membership,
                                            local_membership,
                                            indexes)
  }

  cli::cli_alert_success("{.vrb Cluster}")
  cli::cli_alert_info("{.val {max(global_membership)}} cluster{?s} {.side found (including noise)}")
  cli::cli_end()

  global_membership


}

