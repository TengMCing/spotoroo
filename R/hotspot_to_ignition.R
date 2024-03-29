#' Calculation of spatiotemporal information between hot spots and
#' ignition points
#'
#' compute distance to ignition points; compute time from ignition.
#'
#' @param lon numeric; a vector of longitude values.
#' @param lat numeric; a vector of latitude values.
#' @param obsTime date/datetime/numeric; a vector of observed time.
#' @param timeUnit character; one of "s" (secs), "m"(mins),
#'                            "h"(hours), "d"(days) and "n"(numeric).
#' @param membership integer; a vector of membership labels.
#' @param ignition ignition points returned by \code{ignition_points()}.
#' @return list; distance to ignition points and time from ignition.
#' @noRd
hotspot_to_ignition <- function(lon,
                                lat,
                                obsTime,
                                timeUnit,
                                membership,
                                ignition) {

  if (all(membership == -1)) {
    return(list(distToIgnition = NA, timeFromIgnition = NA))
  }

  tb <- list(s = "secs", m = "mins", h = "hours", d = "days", n = "numeric")
  timeUnit <- tb[[timeUnit]]

  fin_vec <- rep(0, length(lon))
  if (timeUnit != "numeric") {
    time_vec <- difftime(rep(obsTime[1], length(lon)),
                         obsTime[2],
                         units = timeUnit)
  } else {
    time_vec <- rep(0, length(lon))
  }


  for (i in 1:max(membership)){
    indexes <- membership == i
    vlon <- lon[indexes]
    vlat <- lat[indexes]

    indexes2 <- ignition$membership == i
    plon <- ignition$lon[indexes2]
    plat <- ignition$lat[indexes2]

    dist_vec <- dist_point_to_vector(plon, plat, vlon, vlat)
    fin_vec[indexes] <- dist_vec

    if (timeUnit != "numeric") {
      time_vec[indexes] <- difftime(obsTime[indexes], ignition$obsTime[indexes2],
                                    units = timeUnit)
    } else {
      time_vec[indexes] <- obsTime[indexes] - ignition$obsTime[indexes2]
    }
  }

  indexes <- membership == -1
  if (length(indexes) > 0) {
    fin_vec[indexes] <- 0
    if (timeUnit != "numeric") {
      time_vec[indexes] <- difftime(obsTime[1], obsTime[1],
                                    units = timeUnit)
    } else {
      time_vec[indexes] <- 0
    }
  }

  list(distToIgnition = fin_vec, timeFromIgnition = time_vec)
}
