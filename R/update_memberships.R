#' Update membership labels
#'
#' Update membership labels by combining clustering results in different
#' timestamps.
#'
#' @param lon numeric; a vector of longitude value.
#' @param lat numeric; a vector of latitude value.
#' @param global_memberships integer; a vector of all membership labels.
#' @param local_memberships integer; a vector of membership labels of the
#'                                   current timestamp.
#' @param indexes integer; indexes of hotspots in the current timestamp.
#' @return integer; a vector of all membership labels.
#' @noRd
update_memberships <- function(lon,
                               lat,
                               global_memberships,
                               local_memberships,
                               indexes) {

  # if all new hotspots
  if (sum(global_memberships[indexes]) == 0) {
    global_memberships[indexes] <- adjust_memberships(local_memberships,
                                                      max(global_memberships))
    return(global_memberships)
  }

  # if all old hotspots
  if (all(global_memberships[indexes] != 0)) {
    return(global_memberships)
  }

  # access local memberships
  fin_memberships <- global_memberships[indexes]
  local_lon <- lon[indexes]
  local_lat <- lat[indexes]

  # new points and old points
  new_p <- which(fin_memberships == 0)
  old_p <- which(fin_memberships != 0)

  shared_clusteres <- unique(local_memberships[old_p])

  # completely new points; new points but in a previous cluster
  type1 <- new_p[local_memberships[new_p] %in% shared_clusteres]
  type2 <- new_p[!local_memberships[new_p] %in% shared_clusteres]

  # new points but in a previous cluster
  for (i in type1) {

    bool <- local_memberships[old_p] == local_memberships[i]

    current_old <- old_p[bool]

    dist_vector <- dist_point_to_vector(local_lon[i],
                                        local_lat[i],
                                        local_lon[current_old],
                                        local_lat[current_old])


    target <- current_old[which.min(dist_vector)]

    fin_memberships[i] <- fin_memberships[target]

  }

  # completely new
  if (length(type2) != 0) {
    fin_memberships[type2] <- adjust_memberships(local_memberships[type2],
                                                 max(global_memberships))
  }

  global_memberships[indexes] <- fin_memberships
  return(global_memberships)

}
