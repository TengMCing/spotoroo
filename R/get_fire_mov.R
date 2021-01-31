#' Calculate fire movement
#'
#' Calculate the movement of a single fire per a given timestamps.
#'
#' @param result spotoroo result object; get from \code{\link{hotspot_cluster}}.
#' @param cluster integer; the membership lable of the fire.
#' @param step integer; step size.
#' @param method character; "mean" or "median", method of centre calculation.
#' @return a data frame of fire movement
#' \itemize{
#'   \item \code{membership} : membership labels.
#'   \item \code{lon} : longitude of fire centre.
#'   \item \code{lat} : latitude of fire centre.
#'   \item \code{timeID} : time indexes.
#'   \item \code{obsTime} : observed time (approximated).
#'   \item \code{ignition} : whether or not it is a ignition point.
#' }
#' @examples
#' result <- hotspot_cluster(hotspots_fin,
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
#' get_fire_mov(result, cluster = 1, step = 1, method = "mean")
#' get_fire_mov(result, cluster = 2, step = 3, method = "median")
#'
#' @export
get_fire_mov <- function(result, cluster, step = 1, method = "mean"){

  # check class
  if (!"spotoroo" %in% class(result)) {
    stop('Needs a "spotoroo" object as input.')
  }

  # safety check
  is_length_one_bundle(cluster, method, step)
  check_type("numeric", cluster, step)
  check_type("character", method)
  step <- round(step)
  is_positive(step)

  # if cluster does not exist
  if (cluster > max(result$hotspots$membership)) {
    stop(paste("Cluster", cluster, "does not exist!"))
  }

  # extract hotspots from this cluster
  indexes <- result$hotspots$membership == cluster
  all_hotspots <- result$hotspots[indexes, ]

  # init vectors
  indexes <- result$ignition$membership == cluster
  fin_lon <- result$ignition$lon[indexes]
  fin_lat <- result$ignition$lat[indexes]
  fin_obsTime <- result$ignition$obsTime[indexes]
  fin_timeID <- result$ignition$timeID[indexes]
  fin_ignition <- TRUE
  j <- 0
  temp_lon <- c()
  temp_lat <- c()

  # for each time ID
  if (min(all_hotspots$timeID) + 1 <= max(all_hotspots$timeID)) {
    for (i in (min(all_hotspots$timeID) + 1):max(all_hotspots$timeID)) {

      j <- j + 1

      # if no hotspots in this time ID
      if (sum(all_hotspots$timeID == i) == 0) next

      # extract hotspots in this time ID
      current_hotspots <- all_hotspots[all_hotspots$timeID == i, ]

      temp_lon <- c(temp_lon, current_hotspots$lon)
      temp_lat <- c(temp_lat, current_hotspots$lat)

      if (j >= step) {

        j <- 0

        # calc centroid lon and lat
        if (method == "mean") {
          fin_lon <- c(fin_lon, mean(temp_lon))
          fin_lat <- c(fin_lat, mean(temp_lat))
        } else {
          fin_lon <- c(fin_lon, stats::median(temp_lon))
          fin_lat <- c(fin_lat, stats::median(temp_lat))
        }

        # append obsTime and timeID
        fin_obsTime <- c(fin_obsTime, max(current_hotspots$obsTime))
        fin_timeID <- c(fin_timeID, i)
        fin_ignition <- c(fin_ignition, FALSE)

        temp_lon <- c()
        temp_lat <- c()
      }



    }
  }


  # bind output
  fin_data_set <- data.frame(membership = cluster,
                             lon = fin_lon,
                             lat = fin_lat,
                             timeID = fin_timeID,
                             obsTime = fin_obsTime,
                             ignition = fin_ignition)

  # return output
  fin_data_set
}


