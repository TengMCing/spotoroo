#' Clustering hot spots spatially
#'
#' This function clusters hot spots spatially.
#'
#' For more details about the clustering algorithm and the argument `adjDist`,
#' please check the documentation of [hotspot_cluster()].
#' This function performs the **step 2** of the clustering algorithm. It
#' clusters hot spots in a given interval.
#'
#' @param lon Numeric. A vector of longitude values.
#' @param lat Numeric. A vector of latitude values.
#' @param adjDist Numeric (>0). Distance tolerance. Unit is metre.
#' @return Integer. A vector of membership labels
#' @examples
#'
#' # Define lon and lat for 10 observations
#' lon <- c(141.1, 141.14, 141.12, 141.14, 141.16, 141.12, 141.14,
#'           141.16, 141.12, 141.14)
#' lat <- c(-37.10, -37.10, -37.12, -37.12, -37.12, -37.14, -37.14,
#'          -37.14, -37.16, -37.16)
#'
#' # Cluster 10 hot spots with different values of adjDist
#' local_clustering(lon, lat, 2000)
#' local_clustering(lon, lat, 3000)
#' local_clustering(lon, lat, 4000)
#'
#' @export
local_clustering <- function(lon, lat, adjDist) {

  # only one hot spot
  if (length(lon) == 1) return(c(1))

  hotspots_list <- c(1)
  pointer <- c(1)
  pointer_pos <- 1

  membership <- NULL
  label <- NULL

  # find all clusters
  while (TRUE) {

    # find a cluster
    while (TRUE) {

      # push nearby hot spots into list
      nearby_points <- nearby_hotspot(hotspots_list,
                                       pointer,
                                       lon,
                                       lat,
                                       adjDist)
      if (!is.null(nearby_points)) {
        hotspots_list <- c(hotspots_list, nearby_points)
      }

      if (pointer_pos < length(hotspots_list)) {
        pointer_pos <- pointer_pos + 1
        pointer <- hotspots_list[pointer_pos]
      } else {
        break
      }

    }

    # assign membership labels
    if (is.null(membership)) {
      membership <- rep(1, length(hotspots_list))
      label <- 1
    } else {
      label <- label + 1
      new_len <- length(hotspots_list) - length(membership)
      membership <- c(membership, rep(label, new_len))
    }


    indexes <- (!(1:length(lon) %in% hotspots_list))

    if (sum(indexes) == 0) break

    hotspots_list <- c(hotspots_list, min(which(indexes)))
    pointer_pos <- pointer_pos + 1
    pointer <- hotspots_list[pointer_pos]

  }

  membership[order(hotspots_list)]

}
