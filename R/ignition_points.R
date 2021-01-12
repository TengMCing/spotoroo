#' Calculate ignition points
#'
#' Calculate ignition points using membership labels.
#'
#' For a cluster, when there are multiple earliest hotspots, if
#' ignitionCenter = "mean", the centroid of these hotspots will be used
#' as the ignition point, if ignitionCenter = "median", median longitude
#' and median latitude of these hotspots will be used.
#'
#' @param lon numeric; a vector of longitude values.
#' @param lat numeric; a vector of latitude values.
#' @param obsTime date/numeric; a vector of observed time.
#' @param timeID integer (>=1); a vector of time indexes.
#' @param memberships integer; a vector of membership labels.
#' @param ignitionCenter character; method of calculating ignition points,
#'                       one of "mean" and "median".
#' @return a data frame of ignition points
#' \itemize{
#'   \item \code{ignition_lon} : longitude of ignition points.
#'   \item \code{ignition_lat} : latitude of ignition points.
#'   \item \code{ignition_obsTime} : observed time of ignition points.
#' }
#' @examples
#' lon <- c(141.1, 141.14, 141.12, 141.14, 141.16, 141.12, 141.14,
#'           141.16, 141.12, 141.14)
#' lat <- c(-37.10, -37.10, -37.12, -37.12, -37.12, -37.14, -37.14,
#'          -37.14, -37.16, -37.16)
#' obsTime <- c(rep(1, 5), rep(26, 5))
#' memberships <- c(1, 1, 1, 1, 1, 2, 2, 2, 2, 2)
#'
#' global_clustering(lon, lat, obsTime, memberships, "mean")
#'
#' #   ignition_lon ignition_lat ignition_obsTime
#' # 1      141.132      -37.112                1
#' # 2      141.136      -37.148               26
#' @export
ignition_points <- function(lon,
                            lat,
                            obsTime,
                            timeID,
                            memberships,
                            ignitionCenter) {

  ignition_lon <- rep(0, max(memberships))
  ignition_lat <- rep(0, max(memberships))
  ignition_obsTime <- rep(obsTime[1], max(memberships))
  ignition_timeID <- rep(timeID[1], max(memberships))

  for (i in 1:max(memberships)) {

    earliest_time <- min(obsTime[memberships == i])
    ignition_obsTime[i] <- earliest_time
    earliest_timeID <- min(timeID[memberships == i])
    ignition_timeID[i] <- earliest_timeID
    indexes <- (obsTime == earliest_time) & (memberships == i)
    if (ignitionCenter == "mean") {
      ignition_lon[i] <- mean(lon[indexes])
      ignition_lat[i] <- mean(lat[indexes])
    } else {
      ignition_lon[i] <- stats::median(lon[indexes])
      ignition_lat[i] <- stats::median(lat[indexes])
    }

  }

  cli::cli_alert_success("Compute ignition points")

  data.frame(memberships = 1:max(memberships),
             ignition_lon = ignition_lon,
             ignition_lat = ignition_lat,
             ignition_obsTime = ignition_obsTime,
             ignition_timeID = ignition_timeID)
}
