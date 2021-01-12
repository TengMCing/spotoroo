#' Calculate temporal and spatial relationships between hotspots and ignition points
#'
#' compute distance to ignition points; compute time from ignition.
#'
#' time from ignition is calculated using the time indexes, it is closely
#' related to \code{timeUnit} and \code{timeStep}. \code{timeFromIgnition} =
#' 1 means it is 1 * \code{timeStep} (\code{timeUnit}) from the ignition.
#'
#' @param lon numeric; a vector of longitude values.
#' @param lat numeric; a vector of latitude values.
#' @param timeID integer (>=1); a vector of time indexes.
#' @param memberships integer; a vector of membership labels.
#' @param ignitions ignition points returned by \code{ignition_points()}.
#' @return a list contains distance to ignition points and time from ignition.
#' @noRd
hotspots_to_ignitions <- function(lon, lat, timeID, memberships, ignitions) {

  fin_vec <- rep(0, length(lon))
  time_vec <- rep(0, length(lon))

  for (i in 1:max(memberships)){
    indexes <- memberships == i
    vlon <- lon[indexes]
    vlat <- lat[indexes]

    indexes2 <- ignitions$memberships == i
    plon <- ignitions$lon[indexes2]
    plat <- ignitions$lat[indexes2]

    dist_vec <- dist_point_to_vector(plon, plat, vlon, vlat)
    fin_vec[indexes] <- dist_vec

    time_vec[indexes] <- timeID[indexes] - ignitions$timeID[indexes2]

  }

  list(distToIgnition = fin_vec, timeFromIgnition = time_vec)
}
