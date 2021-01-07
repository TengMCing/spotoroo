#' Calculate the geodesic of a point to multiple points
#'
#' Calculate the geodesic of a point to multiple points given coordinate information.
#' The calculation of the geodesic uses the mapbox cheap ruler.
#' See also [geodist::geodist()] for more details.
#'
#' @param plon The longitude of a point. A numeric value.
#' @param plat The latitude of a point. A numeric value.
#' @param vlon The longitude of a series of points. A numeric vector.
#' @param vlat The latitude of a series of points. A numeric vector.
#' @return The geodesic of a point to multiple points in meters. A numeric vector.
#' @examples
#' vlon <- c(141.12, 141.13)
#' vlat <- c(-37.1, -37.0)
#' dist_point_to_vector(141.12, -37.1, vlon, vlat)
#' # 0.00 11148.63
#' @noRd
dist_point_to_vector <- function(plon, plat, vlon, vlat) {
  dist_mat <- suppressMessages(geodist::geodist_vec(plon, plat, vlon, vlat))
  as.vector(dist_mat)
}
