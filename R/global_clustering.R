#' Clustering hotspots spatially and temporally
#'
#' `global_clustering()`` clusters hotspots spatially and temporally.
#'
#' For more details about the clustering algorithm and the parameter
#' `activeTime` and `adjDist`, please check the documentation
#' of [hotspot_cluster()].
#' This function performs the **first 3 steps** of the clustering algorithm.
#'
#' @param lon numeric; a vector of longitude values.
#' @param lat numeric; a vector of latitude values.
#' @param timeID integer (>=1); a vector of time indexes.
#' @param activeTime numeric (>=0); time tolerance; unit is time index.
#' @param adjDist numeric (>0); distance tolerance; unit is metre.
#' @return integer; a vector of membership labels.
#' @examples
#' lon <- c(141.1, 141.14, 141.12, 141.14, 141.16, 141.12, 141.14,
#'           141.16, 141.12, 141.14)
#' lat <- c(-37.10, -37.10, -37.12, -37.12, -37.12, -37.14, -37.14,
#'          -37.14, -37.16, -37.16)
#' timeID <- c(rep(1, 5), rep(26, 5))
#'
#' global_clustering(lon, lat, timeID, 12, 1500)
#' global_clustering(lon, lat, timeID, 24, 3000)
#' global_clustering(lon, lat, timeID, 36, 6000)
#'
#' @export
global_clustering <- function(lon, lat, timeID, activeTime, adjDist) {

  cli::cli_div(theme = list(span.vrb = list(color = "yellow"),
                            span.unit = list(color = "magenta"),
                            span.side = list(color = "grey")))
  cli::cli_h3("{.field activeTime} = {.val {activeTime}} {.unit time indexes} | {.field adjDist} = {.val {adjDist}} {.unit meters}")


  global_membership <- rep(0, length(lon))

  barstr <- "Clustering [:bar] :current/:total (:percent) eta: :eta"

  pb <- progress::progress_bar$new(format = barstr,
                                   total = max(timeID))
  pb$tick(0)

  for (t in 1:max(timeID)) {

    pb$tick(1)

    # find hotspots in the current interval
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

