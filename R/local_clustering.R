local_clustering <- function(lon, lat, AdjDist){

  if (length(lon) == 1) return(c(1))

  hotspots_list <- c(1)
  pointer <- c(1)
  pointer_pos <- 1

  memberships <- NULL
  label <- NULL

  while (TRUE){

    while (TRUE) {

      nearby_hospots <- nearby_hotspots(hotspots_list, pointer, lon, lat, AdjDist)
      if (!is.null(nearby_hospots)) hotspots_list <- c(hotspots_list, nearby_hospots)

      if (pointer_pos < length(hotspots_list)) {
        pointer_pos <- pointer_pos + 1
        pointer <- hotspots_list[pointer_pos]
      } else {
        break
      }

    }

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
