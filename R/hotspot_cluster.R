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
#' @param minTime sdfsd
#' @param ignitionCenter character;
#' @param timeUnit sldfjks
#' @param timeStep sldfjks
#' @return integer; a vector of membership labels.
#' @examples
#' data("hotspots500")
#'
#' results <- hotspot_cluster(hotspots500,
#'                            lon = "lon",
#'                            lat = "lat",
#'                            obsTime = "obsTime",
#'                            activeTime = 24,
#'                            adjDist = 3000,
#'                            minPts = 4,
#'                            minTime = 3,
#'                            ignitionCenter = "mean",
#'                            timeUnit = "h",
#'                            timeStep = 1)
#'
#'
#' @export
hotspot_cluster <- function(hotspots,
                            lon = "lon",
                            lat = "lat",
                            obsTime = "obsTime",
                            activeTime = 24,
                            adjDist = 3000,
                            minPts = 4,
                            minTime = 3,
                            ignitionCenter = "mean",
                            timeUnit = "h",
                            timeStep = 1) {

  # safe checks
  is_length_one_bundle(lon,
                       lat,
                       obsTime,
                       activeTime,
                       adjDist,
                       minPts,
                       minTime,
                       ignitionCenter)
  check_type("list", hotspots)
  check_type_bundle("numeric", activeTime, adjDist, minPts, minTime)
  is_non_negative_bundle(activeTime, minPts, minTime)
  is_positive(adjDist)
  check_type_bundle("character", lon, lat, obsTime, ignitionCenter)
  check_in(c("mean", "median"), ignitionCenter)



  # access cols
  lon <- hotspots[[lon]]
  lat <- hotspots[[lat]]
  obsTime <- hotspots[[obsTime]]

  # command line output
  cli::cli_div(theme = list(span.vrb = list(color = "yellow"),
                            span.unit = list(color = "magenta"),
                            span.side = list(color = "grey"),
                            span.def = list(color = "black"),
                            rule = list("font-weight" = "bold",
                                        "margin-top" = 1,
                                        "margin-bottom" = 0,
                                        color = "cyan",
                                        "font-color" = "black")))
  cli::cli_rule(center = "{.def SPOTOROO 0.0.0.9000}")
  cli::cli_h2("Calling Core Function : {.fn hotspot_cluster}")

  # more safe checks and handle time col
  timeID <- handle_hotspots_col(lon, lat, obsTime, timeUnit, timeStep)

  # start timing
  start_time <- Sys.time()

  # obtain membership
  global_membership <- global_clustering(lon, lat, timeID, activeTime, adjDist)

  # handle noise
  global_membership <- handle_noise(global_membership, timeID, minPts, minTime)

  # get ignition points
  ignition <- list()
  if (!all_noise_bool(global_membership)) {
    ignition <- ignition_point(lon,
                               lat,
                               obsTime,
                               timeUnit,
                               timeID,
                               global_membership,
                               ignitionCenter)
  }

  # get relationship between hotspots and ignition
  to_ignition <- hotspot_to_ignition(lon,
                                     lat,
                                     obsTime,
                                     timeUnit,
                                     global_membership,
                                     ignition)


  # bind results
  result <- list(hotspots = data.frame(lon,
                                       lat,
                                       obsTime,
                                       timeID,
                                       membership = global_membership,
                                       noise = global_membership == -1,
                                       distToIgnition = to_ignition$distToIgnition,
                                       distToIgnitionUnit = "m",
                                       timeFromIgnition = to_ignition$timeFromIgnition,
                                       timeFromIgnitionUnit = timeUnit),
                 ignition = ignition,
                 setting = list(activeTime = activeTime,
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


  cli::cli_h3(paste("{.field Time taken} = {.val {taken_mins}} {.unit min{?s}}",
                      "{.val {taken_secs}} {.unit sec{?s}}",
                      "{.side for} {.val {length(lon)}} hotspots"))
  cli::cli_alert_info("{.val {round(total_secs/length(lon), 3)}} {.unit sec{?s}} {.side per} hotspot")
  cli::cli_rule()
  cli::cli_end()

  # set result class
  class(result) <- "spotoroo"

  # return result
  return(result)

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


