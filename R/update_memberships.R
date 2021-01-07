update_memberships <- function(lon, lat, global_memberships, local_memberships, indexes) {

  if (sum(global_memberships[indexes]) == 0) {
    global_memberships[indexes] <- adjust_memberships(local_memberships, max(global_memberships))
    return(global_memberships)
  }

  if (all(global_memberships[indexes] != 0)) {
    return(global_memberships)
  }

  fin_memberships <- global_memberships[indexes]
  local_lon <- lon[indexes]
  local_lat <- lat[indexes]

  new_p <- which(fin_memberships == 0)
  old_p <- which(fin_memberships != 0)

  shared_clusteres <- unique(local_memberships[old_p])

  type1 <- new_p[local_memberships[new_p] %in% shared_clusteres]
  type2 <- new_p[!local_memberships[new_p] %in% shared_clusteres]

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

  if (length(type2) != 0) {
    fin_memberships[type2] <- adjust_memberships(local_memberships[type2], max(global_memberships))
  }

  global_memberships[indexes] <- fin_memberships
  return(global_memberships)

}
