#' Spatiotemporal clustering of hotspots
#'
#' Cluster hotspots spatially and temporally.
#'
#' @param hotspots list/data frame; a list contains information of hotspots.
#' @param lon character; the name of the column of the list which contains
#'                       longitude values.
#' @param lat character; the name of the column of the list which contains
#'                       latitude values.
#' @param obsTime character; the name of the column of the list which contains
#'                       observed time.
#' @param activeTime numeric (>=0); time tolerance.
#' @param adjDist numeric (>0); distance tolerance.
#' @param minPts numeric (>0); minimum number of points in a cluster.
#' @param ignitionCenter character;
#' @param timeUnit sldfjks
#' @param timeStep sldfjks
#' @return integer; a vector of membership labels.
#' @examples
#' global_memberships <- c(1,1,1,2,2,2,2,2,2,3,3,3,3,3,3)
#'
#' handle_noises(global_memberships, 4)
#'
#' # -1 -1 -1 1 1 1 1 1 1 2 2 2 2 2 2
#' @export
hotspot_cluster <- function(hotspots,
                            lon = "lon",
                            lat = "lat",
                            obsTime = "obsTime",
                            activeTime = 24,
                            adjDist = 3000,
                            minPts = 4,
                            ignitionCenter = "mean",
                            timeUnit = NULL,
                            timeStep = NULL) {

  # safe checks
  is_length_one_bundle(lon, lat, obsTime, activeTime, adjDist, minPts, timeStep)
  check_type("list", hotspots)
  check_type("numeric", minPts)
  is_non_negative(minPts)
  check_type_bundle("character", lon, lat, obsTime)
  check_in(c("mean", "median"), ignitionCenter)
  is_non_negative(activeTime)
  is_positive(adjDist)

  # access cols
  lon <- hotspots[[lon]]
  lat <- hotspots[[lat]]
  obsTime <- hotspots[[obsTime]]

  # more safe checks and handle time col
  timeID <- handle_hotspots_cols(lon, lat, obsTime, timeUnit, timeStep)

  # start timing
  start_time <- Sys.time()

  # obtain memberships
  global_memberships <- global_clustering(lon, lat, timeID, activeTime, adjDist)

  # handle noises
  global_memberships <- handle_noises(global_memberships, minPts)

  # get ignition points
  ignitions <- list()
  if (!all_noises_bool(global_memberships)) {
    ignitions <- ignition_points(lon,
                                 lat,
                                 obsTime,
                                 timeID,
                                 global_memberships,
                                 ignitionCenter)
  }

  # bind results
  results <- list(hotspots = data.frame(lon,
                                        lat,
                                        obsTime,
                                        timeID,
                                        memberships = global_memberships,
                                        noise = global_memberships == -1),
                  ignitions = ignitions,
                  settings = list(activeTime = activeTime,
                                  adjDist = adjDist,
                                  minPts = minPts,
                                  ignitionCenter = ignitionCenter,
                                  timeUnit = timeUnit,
                                  timeStep = timeStep)
                  )


  # stop timing
  end_time <- Sys.time()
  time_taken <- end_time - start_time

  # print run time
  total_secs <- as.numeric(time_taken, units = "secs")
  taken_mins <- total_secs %/% 60
  taken_secs <- round(total_secs %% 60, 0)

  cli::cli_text(paste("Time taken: {taken_mins} min{?s} {taken_secs} sec{?s}",
                      "for {length(lon)} obs",
                      "({round(total_secs/length(lon), 3)} secs/obs)"))

  # set result class
  class(results) <- "spotoroo"

  # return result
  return(results)

}



# summary.spotoroo <- function(object, ...) {
#
#
# }





#' Plotting spatiotemporal clustering results
#'
#' \code{plot} method for class "\code{spotoroo}", a simple wrapper of
#' \code{plot_spotoroo()}, see also \code{\link{plot_spotoroo}}.
#'
#' @param x an object of class "\code{spotoroo}",
#' a result of a call to \code{\link{hotspot_cluster}}.
#' @param \dots additional arguments pass to \code{plot_spotoroo()}
#' @examples
#' data("hotspots500")
#' results <- hotspot_cluster(hotspots500,
#'                            lon = "lon",
#'                            lat = "lat",
#'                            obsTime = "obsTime",
#'                            activeTime = 24,
#'                            adjDist = 3000,
#'                            minPts = 4,
#'                            ignitionCenter = "mean",
#'                            timeUnit = "h",
#'                            timeStep = 1)
#'
#' plot(results)
#' @export
plot.spotoroo <- function(x, ...) {
  plot_spotoroo(x, ...)
}


