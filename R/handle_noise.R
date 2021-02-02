#' Handling noise in the clustering results
#'
#' `handle_noise() finds noise from the clustering results and label it with
#' `-1`.
#'
#' For more details about the clustering algorithm and the parameter
#' `minPts` and `minTime`, please check the documentation
#' of [hotspot_cluster()].
#' This function performs the **step 4** of the clustering algorithm. It uses a
#' given threshold (minimum number of points and minimum existing time) to find
#' noise and label it with `-1`.
#'
#' @param global_membership integer; a vector of membership labels.
#' @param timeID integer; a vector of time indexes.
#' @param minPts numeric (>0); minimum number of hotspots in a cluster.
#' @param minTime numeric (>=0); minimum length of time of a cluster;
#'                               unit is time index.
#' @return integer; a vector of membership labels.
#' @examples
#' global_membership <- c(1,1,1,2,2,2,2,2,2,3,3,3,3,3,3)
#' timeID <- c(1,2,3,2,3,3,4,5,6,3,3,3,3,3,3)
#'
#' handle_noise(global_membership, timeID, 4, 0)
#' handle_noise(global_membership, timeID, 4, 1)
#' handle_noise(global_membership, timeID, 3, 3)
#'
#' @export
handle_noise <- function(global_membership, timeID, minPts, minTime) {

  cli::cli_div(theme = list(span.vrb = list(color = "yellow"),
                            span.unit = list(color = "magenta"),
                            span.side = list(color = "grey")))
  cli::cli_h3("{.field minPts} = {.val {minPts}} {.unit hotspot{?s}} | {.field minTime} = {.val {minTime}} {.unit time index{?es}}")

  # pass CMD CHECK variables
  n <- timelen <- NULL
  `%>%` <- dplyr::`%>%`

  # count every membership
  membership_count <- data.frame(id = 1:length(global_membership),
                                 timeID,
                                 global_membership) %>%
    dplyr::group_by(global_membership) %>%
    dplyr::summarise(n = dplyr::n(), timelen = max(timeID) - min(timeID))


  # filter noise
  noise_clusters <- dplyr::filter(membership_count,
                                  n < minPts | timelen < minTime)
  noise_clusters <- noise_clusters[['global_membership']]
  indexes <- global_membership %in% noise_clusters
  global_membership[indexes] <- -1

  if (all_noise_bool(global_membership)) {
    cli::cli_alert_warning("All observations are noise!!!")
  } else {
    global_membership[!indexes] <-
      adjust_membership(global_membership[!indexes], 0)
  }

  cli::cli_alert_success("{.vrb Handle} {.field noise}")
  cli::cli_alert_info("{.val {max(c(global_membership, 0))}} cluster{?s} {.side left}")
  cli::cli_alert_info("noise {.side proportion} : {.val {mean(global_membership == -1)*100} %} ")
  cli::cli_end()

  return(global_membership)
}

