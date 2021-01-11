#' Find nearby hotspots
#'
#' Find nearby hotspots that are included not in the list.
#'
#' @param hotspot_list integer; a vector of hotspot indexes.
#' @param pointer integer; the current working index.
#' @param lon numeric; a vector of longitude values.
#' @param lat numeric; a vector of latitude values.
#' @param adjDist numeric (>0); distance tolerance.
#'                see also \code{\link{hotspot_cluster}}.
#' @return integer; a vector of indexes of nearby hotspots. If there is no
#'                  nearby hotspots, return \code{NULL}.
#' @noRd
nearby_hotspots <- function(hotspot_list, pointer, lon, lat, adjDist) {

  if (length(lon) == 1) return(NULL)

  dist_vector <- dist_point_to_vector(lon[pointer], lat[pointer], lon, lat)
  potential <- which(dist_vector <= adjDist)
  indexes <- !(potential %in% hotspot_list)

  if (sum(indexes) == 0) return(NULL)

  potential[!(potential %in% hotspot_list)]
}
