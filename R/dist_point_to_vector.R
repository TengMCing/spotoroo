#' Calculate the geodesic of a point to multiple points
#'
#' Calculate the geodesic of a point to multiple points given coordinate
#' information.
#' The calculation of the geodesic uses the mapbox cheap ruler.
#' See also \code{\link[geodist]{geodist}} for more details.
#'
#' @param plon numeric; the longitude of a point.
#' @param plat numeric; the latitude of a point.
#' @param vlon numeric; a vector of longitude values.
#' @param vlat numeric; a vector of latitude values.
#' @return numeric; the geodesic of a point to multiple points in meters.
#' @examples
#' vlon <- c(141.12, 141.13)
#' vlat <- c(-37.1, -37.0)
#'
#' dist_point_to_vector(141.12, -37.1, vlon, vlat)
#'
#' # 0.00 11148.63
#' @export
dist_point_to_vector <- function(plon, plat, vlon, vlat) {
  dist_mat <- suppressMessages(geodist::geodist_vec(plon, plat, vlon, vlat))
  as.vector(dist_mat)
}
