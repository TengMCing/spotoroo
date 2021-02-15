#' Update membership labels
#'
#' Update membership labels by combining local clustering results in different
#' intervals.
#'
#' @param lon numeric; a vector of longitude value.
#' @param lat numeric; a vector of latitude value.
#' @param global_membership integer; a vector of the membership labels of
#'                                   all hot spots.
#' @param local_membership integer; a vector of membership labels of the
#'                                  hot spots in the current interval.
#' @param indexes integer; indexes of hot spots in the current interval.
#' @return integer; a vector of membership labels of all hot spots.
#' @noRd
update_membership <- function(lon,
                              lat,
                              global_membership,
                              local_membership,
                              indexes) {

  # if all new hot spots
  if (sum(global_membership[indexes]) == 0) {
    global_membership[indexes] <- adjust_membership(local_membership,
                                                    max(global_membership))
    return(global_membership)
  }

  # if all old hot spots
  if (all(global_membership[indexes] != 0)) {
    return(global_membership)
  }

  # access local membership
  fin_membership <- global_membership[indexes]
  local_lon <- lon[indexes]
  local_lat <- lat[indexes]

  # new points and old points
  new_p <- which(fin_membership == 0)
  old_p <- which(fin_membership != 0)

  shared_clusteres <- unique(local_membership[old_p])

  # completely new points; new points but in a shared cluster
  type1 <- new_p[local_membership[new_p] %in% shared_clusteres]
  type2 <- new_p[!local_membership[new_p] %in% shared_clusteres]

  # new points but in a shared cluster
  for (i in type1) {

    bool <- local_membership[old_p] == local_membership[i]

    current_old <- old_p[bool]

    dist_vector <- dist_point_to_vector(local_lon[i],
                                        local_lat[i],
                                        local_lon[current_old],
                                        local_lat[current_old])


    target <- current_old[which.min(dist_vector)]

    fin_membership[i] <- fin_membership[target]

  }

  # completely new
  if (length(type2) != 0) {
    fin_membership[type2] <- adjust_membership(local_membership[type2],
                                               max(global_membership))
  }

  global_membership[indexes] <- fin_membership
  return(global_membership)

}
