#' Handle noise clusters
#'
#' Handle noise clusters with a given threshold (minimum number of points of
#' a cluster). Noises will be assigned with membership label \code{-1}. Normal
#' clusters will be assigned with adjusted membership labels.
#'
#' @param global_memberships integer; a vector of membership labels.
#' @param minPts numeric (>0); minimum number of points of a cluster.
#' @return integer; a vector of membership labels.
#' @examples
#' global_memberships <- c(1,1,1,2,2,2,2,2,2,3,3,3,3,3,3)
#'
#' handle_noises(global_memberships, 4)
#'
#' # -1 -1 -1 1 1 1 1 1 1 2 2 2 2 2 2
#' @export
handle_noises <- function(global_memberships, minPts) {

  # count every membership
  membership_count <- dplyr::count(data.frame(id = 1:length(global_memberships),
                                              global_memberships),
                                   global_memberships)

  # filter noises
  noise_clusters <- dplyr::filter(membership_count, n < minPts)
  noise_clusters <- noise_clusters[['global_memberships']]
  indexes <- global_memberships %in% noise_clusters
  global_memberships[indexes] <- -1

  if (all_noises(global_memberships)) {
    cli::cli_alert_warning("All observations are noises!!!")
  } else {
    global_memberships[!indexes] <- adjust_memberships(global_memberships[!indexes], 0)
  }

  cli::cli_alert_success("Handle noises")

  return(global_memberships)
}

