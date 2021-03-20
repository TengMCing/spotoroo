#' Extracting fires from the spatiotemporal clustering results
#'
#' This function takes a `spotoroo` object to produce a data frame which
#' contains information about the fire.
#'
#' @param result `spotoroo` object.
#' A result of a call to [hotspot_cluster()].
#' @param cluster Character/Integer. If "all", extract all clusters.
#'                If an integer vector is given, extract corresponding
#'                clusters.
#' @param noise Logical. Whether or not to include noise.
#' @return A data.frame. The fire information
#' \itemize{
#'   \item \code{lon} : Longitude.
#'   \item \code{lat} : Latitude.
#'   \item \code{obsTime} : Observed time.
#'   \item \code{timeID} : Time indexes.
#'   \item \code{membership} : Membership labels.
#'   \item \code{noise} : Whether it is a noise point.
#'   \item \code{distToIgnition} : Distance to the ignition location.
#'   \item \code{distToIgnitionUnit} : Unit of distance to the ignition
#'                                       location.
#'   \item \code{timeFromIgnition} : Time from ignition.
#'   \item \code{timeFromIgnitionUnit} : Unit of time from ignition.
#'   \item \code{type} : Type of the entry, either "hotspot", "noise" or
#'                       "ignition"
#'   \item \code{obsInCluster} : Number of observations in the cluster.
#'   \item \code{clusterTimeLen} : Length of time of the cluster.
#'   \item \code{clusterTimeLenUnit} : Unit of length of time of the
#'     cluster.
#' }
#' @examples
#' \donttest{
#'
#'   # Time consuming functions (>5 seconds)
#'
#'
#'   # Get clustering results
#'   result <- hotspot_cluster(hotspots,
#'                           lon = "lon",
#'                           lat = "lat",
#'                           obsTime = "obsTime",
#'                           activeTime = 24,
#'                           adjDist = 3000,
#'                           minPts = 4,
#'                           minTime = 3,
#'                           ignitionCenter = "mean",
#'                           timeUnit = "h",
#'                           timeStep = 1)
#'
#'
#'   # Extract all fires
#'   all_fires <- extract_fire(result)
#'   head(all_fires, 3)
#'
#'   # Extract cluster 4
#'   fire_4 <- extract_fire(result, 4)
#'   head(fire_4, 3)
#' }
#'
#' @export
extract_fire <- function(result, cluster = "all", noise = FALSE) {

  if (!"spotoroo" %in% class(result)) {
    stop('Needs a "spotoroo" object as input.')
  }

  # pass CMD CHECK variables
  membership <- obsInCluster <- clusterTimeLen <- clusterTimeLenUnit <- NULL

  check_type("logical", noise)

  if (!identical(cluster, "all")) {
    check_type("numeric", cluster)
    if (length(cluster) == 0) stop("Please provide valid membership labels.")
    if (any(!cluster %in% unique(result$ignition$membership))) {
      stop("Please provide valid membership labels.")}

    indexes <- result$ignition$membership %in% cluster
    result$ignition <- result$ignition[indexes, ]


    indexes <- result$hotspots$membership %in% c(cluster, -1)
    result$hotspots <- result$hotspots[indexes, ]
  }

  if (!noise) {
    result$hotspots <- result$hotspots[!result$hotspots$noise,]
  }


  result$hotspots$type <- ifelse(result$hotspots$noise,
                                 "noise",
                                 "hotspot")

  result$ignition$type <- "ignition"

  temp_data <- dplyr::select(result$ignition,
                             membership,
                             obsInCluster,
                             clusterTimeLen,
                             clusterTimeLenUnit)

  result$hotspots <- dplyr::left_join(result$hotspots,
                                      temp_data,
                                      by = c("membership"))

  result$ignition$noise <- FALSE
  result$ignition$distToIgnition <- 0
  result$ignition$distToIgnitionUnit <- "m"

  if (result$setting$timeUnit == "n") {
    result$ignition$timeFromIgnition <- 0
  } else {
    tunit <- list(d = "days",
                  h = "hours",
                  m = "mins",
                  s = "secs")[[result$setting$timeUnit]]

    result$ignition$timeFromIgnition <- difftime(result$ignition$obsTime,
                                                 result$ignition$obsTime,
                                                 units = tunit)

  }

  result$ignition$timeFromIgnitionUnit <- result$setting$timeUnit

  dplyr::bind_rows(result$hotspots, result$ignition)

}
