#' Find nearby hot spots
#'
#' Find nearby hot spots that are not included in the list.
#'
#' @param hotspot_list integer; a vector of hot spot indexes.
#' @param pointer integer; the current working position.
#' @param lon numeric; a vector of longitude values.
#' @param lat numeric; a vector of latitude values.
#' @param adjDist numeric (>0); distance tolerance; unit is metre.
#' @return integer; a vector of indexes of nearby hot spots. If there is no
#'                  nearby hot spots, return `NULL`.
#' @noRd
nearby_hotspot <- function(hotspot_list, pointer, lon, lat, adjDist) {

  if (length(lon) == 1) return(NULL)

  dist_vector <- dist_point_to_vector(lon[pointer], lat[pointer], lon, lat)
  potential <- which(dist_vector <= adjDist)
  indexes <- !(potential %in% hotspot_list)

  if (sum(indexes) == 0) return(NULL)

  potential[!(potential %in% hotspot_list)]
}
