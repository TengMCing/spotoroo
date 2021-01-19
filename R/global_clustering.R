#' Cluster hotspots spatially and temporally
#'
#' Cluster hotspots spatially and temporally.
#'
#' @param lon numeric; a vector of longitude values.
#' @param lat numeric; a vector of latitude values.
#' @param timeID integer (>=1); a vector of time indexes.
#' @param activeTime numeric; time tolerance.
#'                   see also \code{\link{hotspot_cluster}}.
#' @param adjDist numeric; distance tolerance.
#'                see also \code{\link{hotspot_cluster}}.
#' @return integer; a vector of membership labels.
#' @examples
#' lon <- c(141.1, 141.14, 141.12, 141.14, 141.16, 141.12, 141.14,
#'           141.16, 141.12, 141.14)
#' lat <- c(-37.10, -37.10, -37.12, -37.12, -37.12, -37.14, -37.14,
#'          -37.14, -37.16, -37.16)
#' timeID <- c(rep(1, 5), rep(26, 5))
#'
#' global_clustering(lon, lat, timeID, 24, 3000)
#'
#' # 1 1 1 1 1 2 2 2 2 2
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

    # safe checks
    if (is.null(indexes)) next
    if (all(global_membership[indexes] != 0)) next

    # clustering spatially
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
