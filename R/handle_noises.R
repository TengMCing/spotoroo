handle_noises <- function(lon,
                          lat,
                          obstime,
                          ignition_center,
                          global_memberships,
                          time_unit,
                          MinPts){

  # count every membership
  membership_count <- dplyr::count(data.frame(id = 1:length(global_memberships),
                                              global_memberships),
                                   global_memberships)

  # filter noises
  noise_clusters <- dplyr::filter(membership_count, n < MinPts)
  noise_clusters <- noise_clusters[['global_memberships']]
  indexes <- global_memberships %in% noise_clusters
  global_memberships[indexes] <- -1

  # warn if all noises
  if (sum(indexes) == length(global_memberships)){
    warning("All observations are noises!!!")
    ignitions <- list()
  } else {
    # adjust memberships
    global_memberships[!indexes] <- adjust_memberships(global_memberships[!indexes], 0)

    # compute ignition points
    ignitions <- ignition_points(lon,
                                 lat,
                                 obstime,
                                 global_memberships,
                                 ignition_center)
  }



  # bind results
  results <- list(hotspots = data.frame(lon,
                                        lat,
                                        obstime,
                                        memberships = global_memberships,
                                        noise = global_memberships == -1),
                  ignitions = ignitions,
                  time_unit = time_unit)

  return(results)
}

