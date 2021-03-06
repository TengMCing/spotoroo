#' Calculation of the geodesic of a point to multiple points
#'
#' This function calculates the geodesic of a point to multiple
#' points given the coordinate information. It is a wrapper of
#' [geodist::geodist_vec()].
#'
#' @param plon Numeric. The longitude of a point.
#' @param plat Numeric. The latitude of a point.
#' @param vlon Numeric. A vector of longitude values.
#' @param vlat Numeric. A vector of latitude values.
#' @return Numeric. The geodesic of a point to multiple points in meters.
#' @examples
#'
#' # Define vlon and vlat
#' vlon <- c(141.12, 141.13)
#' vlat <- c(-37.1, -37.0)
#'
#' # Calculate the geodesic
#' dist_point_to_vector(141.12, -37.1, vlon, vlat)
#'
#' @export
dist_point_to_vector <- function(plon, plat, vlon, vlat) {
  dist_mat <- suppressMessages(geodist::geodist_vec(plon, plat, vlon, vlat))
  as.vector(dist_mat)
}

