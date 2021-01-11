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

  global_memberships <- rep(0, length(lon))

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
    if (all(global_memberships[indexes] != 0)) next

    # clustering spatially
    local_memberships <- local_clustering(lon[indexes], lat[indexes], adjDist)

    # update memberships
    global_memberships <-  update_memberships(lon,
                                              lat,
                                              global_memberships,
                                              local_memberships,
                                              indexes)
  }

  cli::cli_alert_success("Clustering")

  global_memberships


}
