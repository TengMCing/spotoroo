#' Handle noise clusters
#'
#' Handle noise clusters with a given threshold (minimum number of points of
#' a cluster). noise will be assigned with membership label \code{-1}. Normal
#' clusters will be assigned with adjusted membership labels.
#'
#' @param global_membership integer; a vector of membership labels.
#' @param minPts numeric (>=0); minimum number of points of a cluster.
#' @return integer; a vector of membership labels.
#' @examples
#' global_membership <- c(1,1,1,2,2,2,2,2,2,3,3,3,3,3,3)
#'
#' handle_noise(global_membership, 4)
#'
#' # -1 -1 -1 1 1 1 1 1 1 2 2 2 2 2 2
#' @export
handle_noise <- function(global_membership, minPts) {

  cli::cli_div(theme = list(span.vrb = list(color = "yellow"),
                            span.unit = list(color = "magenta"),
                            span.side = list(color = "grey")))
  cli::cli_h3("{.field minPts} = {.val {minPts}}")

  n <- NULL

  # count every membership
  membership_count <- dplyr::count(data.frame(id = 1:length(global_membership),
                                              global_membership),
                                   global_membership)

  # filter noise
  noise_clusters <- dplyr::filter(membership_count, n < minPts)
  noise_clusters <- noise_clusters[['global_membership']]
  indexes <- global_membership %in% noise_clusters
  global_membership[indexes] <- -1

  if (all_noise_bool(global_membership)) {
    cli::cli_alert_warning("All observations are noise!!!")
  } else {
    global_membership[!indexes] <- adjust_membership(global_membership[!indexes], 0)
  }

  cli::cli_alert_success("{.vrb Handle} {.field noise}")
  cli::cli_alert_info("{.val {max(global_membership)}} cluster{?s} {.side left}")
  cli::cli_alert_info("noise {.side proportion} : {.val {mean(global_membership == -1)*100} %} ")
  cli::cli_end()

  return(global_membership)
}

