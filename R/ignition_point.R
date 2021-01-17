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
#' @param timeUnit character; the unit of time, one of "s" (secs), "m"(mins),
#'                            "h"(hours), "d"(days) and "n"(numeric).
#' @param timeID integer (>=1); a vector of time indexes.
#' @param membership integer; a vector of membership labels.
#' @param ignitionCenter character; method of calculating ignition points,
#'                       one of "mean" and "median".
#' @return a data frame of ignition points
#' \itemize{
#'   \item \code{membership} : membership labels.
#'   \item \code{ignition_lon} : longitude of ignition points.
#'   \item \code{ignition_lat} : latitude of ignition points.
#'   \item \code{ignition_obsTime} : observed time of ignition points.
#'   \item \code{timeID} : time indexes.
#'   \item \code{clusterObs} : number of observations in the cluster.
#'   \item \code{clusterTimeLen} : time frame of the cluster.
#' }
#' @examples
#' lon <- c(141.1, 141.14, 141.12, 141.14, 141.16, 141.12, 141.14,
#'           141.16, 141.12, 141.14)
#' lat <- c(-37.10, -37.10, -37.12, -37.12, -37.12, -37.14, -37.14,
#'          -37.14, -37.16, -37.16)
#' obsTime <- c(rep(1, 5), rep(26, 5))
#' timeUnit <- "n"
#' timeID <- c(rep(1, 5), rep(26, 5))
#' membership <- c(1, 1, 1, 1, 1, 2, 2, 2, 2, 2)
#'
#' ignition_point(lon, lat, obsTime, timeUnit, timeID, membership, "mean")
#'
#' @export
ignition_point <- function(lon,
                           lat,
                           obsTime,
                           timeUnit,
                           timeID,
                           membership,
                           ignitionCenter) {

  tb <- list(s = "secs", m = "mins", h = "hours", d = "days", n = "numeric")
  timeUnit <- tb[[timeUnit]]

  # init vec
  ignition_lon <- rep(0, max(membership))
  ignition_lat <- rep(0, max(membership))
  ignition_obsTime <- rep(obsTime[1], max(membership))
  ignition_timeID <- rep(timeID[1], max(membership))
  obs <- rep(0, max(membership))

  if (timeUnit != "numeric") {
    timeLen <- difftime(rep(obsTime[1], max(membership)),
                        obsTime[2],
                        units = timeUnit)
  } else {
    timeLen <- rep(0, max(membership))
  }



  # for each cluster
  for (i in 1:max(membership)) {

    # get earliest observed time
    earliest_time <- min(obsTime[membership == i])
    ignition_obsTime[i] <- earliest_time

    # get earliest time index
    earliest_timeID <- min(timeID[membership == i])
    ignition_timeID[i] <- earliest_timeID

    # count observations
    obs[i] <- sum(membership == i)

    # calc time len using time indexes or obs time
    if (timeUnit != "numeric") {
      timeLen[i] <- difftime(max(obsTime[membership == i]),
                             min(obsTime[membership == i]),
                             units = timeUnit)
    } else {
      timeLen[i] <- max(timeID[membership == i]) - min(timeID[membership == i])
    }


    # extract earliest observed hotspots
    indexes <- (obsTime == earliest_time) & (membership == i)
    if (ignitionCenter == "mean") {
      ignition_lon[i] <- mean(lon[indexes])
      ignition_lat[i] <- mean(lat[indexes])
    } else {
      ignition_lon[i] <- stats::median(lon[indexes])
      ignition_lat[i] <- stats::median(lat[indexes])
    }

  }

  cli::cli_alert_success("Compute ignition points")

  tb <- list(secs = "s", mins = "m", hours = "h", days = "d", numeric = "n")
  timeUnit <- tb[[timeUnit]]

  data.frame(membership = 1:max(membership),
             lon = ignition_lon,
             lat = ignition_lat,
             obsTime = ignition_obsTime,
             timeID = ignition_timeID,
             obsInCluster = obs,
             clusterTimeLen = timeLen,
             clusterTimeLenUnit = timeUnit)
}
