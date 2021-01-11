#' Cluster hotspots spatially
#'
#' Cluster hotspots spatially.
#'
#' @param lon numeric; a vector of longitude values.
#' @param lat numeric; a vector of latitude values.
#' @param adjDist numeric (>0); distance tolerance.
#'                see also \code{\link{hotspot_cluster}}.
#' @return integer; a vector of membership labels
#' @examples
#' lon <- c(141.1, 141.14, 141.12, 141.14, 141.16, 141.12, 141.14,
#'           141.16, 141.12, 141.14)
#' lat <- c(-37.10, -37.10, -37.12, -37.12, -37.12, -37.14, -37.14,
#'          -37.14, -37.16, -37.16)
#'
#' local_clustering(lon, lat, 2000)
#'
#' # 1 2 3 3 3 4 4 4 5 5
#' @export
local_clustering <- function(lon, lat, adjDist) {

  # only one hotspots
  if (length(lon) == 1) return(c(1))

  hotspots_list <- c(1)
  pointer <- c(1)
  pointer_pos <- 1

  memberships <- NULL
  label <- NULL

  # find all clusters
  while (TRUE) {

    # find a cluster
    while (TRUE) {

      # push nearby hotspots into list
      nearby_hospots <- nearby_hotspots(hotspots_list,
                                        pointer,
                                        lon,
                                        lat,
                                        adjDist)
      if (!is.null(nearby_hospots)) {
        hotspots_list <- c(hotspots_list, nearby_hospots)
      }

      if (pointer_pos < length(hotspots_list)) {
        pointer_pos <- pointer_pos + 1
        pointer <- hotspots_list[pointer_pos]
      } else {
        break
      }

    }

    # assign membership labels
    if (is.null(memberships)) {
      memberships <- rep(1, length(hotspots_list))
      label <- 1
    } else {
      label <- label + 1
      new_len <- length(hotspots_list) - length(memberships)
      memberships <- c(memberships, rep(label, new_len))
    }


    indexes <- (!(1:length(lon) %in% hotspots_list))

    if (sum(indexes) == 0) break

    hotspots_list <- c(hotspots_list, min(which(indexes)))
    pointer_pos <- pointer_pos + 1
    pointer <- hotspots_list[pointer_pos]

  }

  memberships[order(hotspots_list)]

}
