handle_noises <- function(global_memberships, minPts){

  # count every membership
  membership_count <- dplyr::count(data.frame(id = 1:length(global_memberships),
                                              global_memberships),
                                   global_memberships)

  # filter noises
  noise_clusters <- dplyr::filter(membership_count, n < minPts)
  noise_clusters <- noise_clusters[['global_memberships']]
  indexes <- global_memberships %in% noise_clusters
  global_memberships[indexes] <- -1

  if (all_noises(global_memberships)){
    warning("All observations are noises!!!")
  } else {
    global_memberships[!indexes] <- adjust_memberships(global_memberships[!indexes], 0)
  }

  cat("Handel noises \u2713 \n")

  return(global_memberships)
}

