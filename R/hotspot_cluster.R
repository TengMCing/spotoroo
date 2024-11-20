#' Spatiotemporal clustering of hot spot data
#'
#' This is the main function of the package.
#' \cr
#' This function clusters hot spots into fires. It can be used to
#' reconstruct fire history and detect fire ignition points.
#'
#' Arguments `timeUnit` and `timeStep` need to be
#' specified to convert date/datetime/numeric to time index.
#' More details can be found in [transform_time_id()].
#' \cr\cr
#' This clustering algorithm consisted of **5 steps**:
#' \cr\cr
#' In **step 1**, it defines \eqn{T} intervals using the time index
#' \deqn{Interval(t) = [max(1, t - activeTime),t]}
#' where \eqn{t = 1, 2, ..., T}, and \eqn{T} is the maximum time index.
#' `activeTime` is an argument that needs to be specified. It represents
#' the maximum time difference between two hot spots in the same local
#' cluster. Please notice that a local cluster is different with a cluster
#' in the final result. More details will be given in the next part.
#' \cr\cr
#' In **step 2**, the algorithm performs spatial clustering on each interval.
#' A local cluster is a cluster found in an interval. Argument `adjDist`
#' is used to control the spatial clustering. If the distance between two
#' hot spots is smaller or equal to `adjDist`, they are directly-connected. If
#' hot spot `A` is directly-connected with hot spot `B` and hot spot `B` is
#' directly-connected with hot spot `C`, hot spot `A`, `B` and `C` are
#' connected. All connected hot spots become a local cluster.
#' \cr\cr
#' In **step 3**, the algorithm starts from interval \eqn{1}. It marks all
#' hot spots in this interval and records their membership labels.
#' Then it moves on to interval \eqn{2}. Due to a hot spot could exist in
#' multiple intervals, it checks whether any hot spot in interval \eqn{2}
#' has been marked. If there is any, their membership labels will be
#' carried over from the record. Unmarked hot spots in interval \eqn{2},
#' which share the same local cluster with marked hot spots, their
#' membership labels are carried over from marked hot spots. If a unmarked
#' hot spot shares the same local cluster with multiple marked hot spots, the
#' algorithm will carry over the membership label from the nearest one. All
#' other unmarked hot spots in interval \eqn{2} that do not share the same
#' cluster with any marked hot spot, their membership labels will be adjusted
#' such that the clusters they belong to are considered to be new clusters.
#' Finally, all
#' hot spots in interval \eqn{2} are marked and their membership labels are
#' recorded. This process continues for interval \eqn{3}, \eqn{4}, ...,
#' \eqn{T}. After finishing step 3, all hot spots are marked and their
#' membership labels are recorded.
#' \cr\cr
#' In **step 4**, it checks each cluster. If there is any cluster contains less
#' than `minPts` hot spots, or lasts shorter than `minTime`, it will not be
#' considered to be a cluster any more, and their hot spots will be
#' assigned with `-1` as their membership labels. A hot spot with membership
#' label `-1` is noise.
#' Arguments `minPts` and `minTime` need to be specified.
#' \cr\cr
#' In **step 5**, the algorithm finds the earliest observed hot spots in each
#' cluster and records them as ignition points. If there are multiple
#' earliest observed hot spots in a cluster, the mean or median of the
#' longitude values and the latitude values will be used as the coordinate
#' of the ignition point. This needs to be specified in argument
#' `ignitionCenter`.
#'
#'
#'
#' @param hotspots List/Data frame. A list or a data frame which
#'                                  contains information of hot spots.
#' @param lon Character. The name of the column of the list which contains
#'                       numeric longitude values.
#' @param lat Character. The name of the column of the list which contains
#'                       numeric latitude values.
#' @param obsTime Character. The name of the column of the list which contains
#'                           the observed time of hot spots. The observed time
#'                           has to be in date, datetime or numeric.
#' @param activeTime Numeric (>=0). Time tolerance. Unit is time index.
#' @param adjDist Numeric (>0). Distance tolerance. Unit is metre.
#' @param minPts Numeric (>0). Minimum number of hot spots in a cluster.
#' @param minTime Numeric (>=0). Minimum length of time of a cluster.
#'                               Unit is time index.
#' @param ignitionCenter Character. Method to calculate ignition points,
#'                                  either "mean" or "median".
#' @param timeUnit Character. One of "s" (seconds),
#'                                      "m" (minutes), "h" (hours),
#'                                      "d" (days) and "n" (numeric).
#' @param timeStep Numeric (>0). Number of units of `timeUnit` in a time step.
#' @return A `spotoroo` object. The clustering results. It is also a list:
#' \itemize{
#'   \item \code{hotspots} : A data frame contains information of hot spots.
#'   \itemize{
#'     \item \code{lon} : Longitude.
#'     \item \code{lat} : Latitude.
#'     \item \code{obsTime} : Observed time.
#'     \item \code{timeID} : Time index.
#'     \item \code{membership} : Membership label.
#'     \item \code{noise} : Whether it is a noise point.
#'     \item \code{distToIgnition} : Distance to the ignition location.
#'     \item \code{distToIgnitionUnit} : Unit of distance to the ignition
#'                                       location.
#'     \item \code{timeFromIgnition} : Time from ignition.
#'     \item \code{timeFromIgnitionUnit} : Unit of time from ignition.
#'   }
#'   \item \code{ignition} : A data frame contains information of ignition
#'                           points.
#'   \itemize{
#'     \item \code{lon} : Longitude.
#'     \item \code{lat} : Latitude.
#'     \item \code{obsTime} : Observed time.
#'     \item \code{timeID} : Time index.
#'     \item \code{obsInCluster} : Number of observations in the cluster.
#'     \item \code{clusterTimeLen} : Length of time of the cluster.
#'     \item \code{clusterTimeLenUnit} : Unit of length of time of the
#'     cluster.
#'   }
#'   \item \code{setting} : A list contains the clustering settings.
#' }
#' @examples
#' \donttest{
#'
#'   # Time consuming functions (>5 seconds)
#'
#'
#'   # Get clustering results
#'   result <- hotspot_cluster(hotspots,
#'                 lon = "lon",
#'                 lat = "lat",
#'                 obsTime = "obsTime",
#'                 activeTime = 24,
#'                 adjDist = 3000,
#'                 minPts = 4,
#'                 minTime = 3,
#'                 ignitionCenter = "mean",
#'                 timeUnit = "h",
#'                 timeStep = 1)
#'
#'   # Make a summary of the clustering results
#'   summary(result)
#'
#'   # Make a plot of the clustering results
#'   plot(result, bg = plot_vic_map())
#' }
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
                            timeUnit = "n",
                            timeStep = 1) {

  # safe checks
  is_length_one_bundle(lon,
                       lat,
                       obsTime,
                       activeTime,
                       adjDist,
                       minPts,
                       minTime,
                       ignitionCenter,
                       timeUnit,
                       timeStep)
  check_type("list", hotspots)
  check_type_bundle("numeric", activeTime, adjDist, minPts, minTime, timeStep)
  is_non_negative_bundle(activeTime, minTime)
  is_positive_bundle(adjDist, minPts, timeStep)
  check_type_bundle("character", lon, lat, obsTime, ignitionCenter, timeUnit)
  check_in(c("s", "m", "h", "d", "n"), timeUnit)
  check_in(c("mean", "median"), ignitionCenter)


  # access cols
  lon <- hotspots[[lon]]
  lat <- hotspots[[lat]]
  obsTime <- hotspots[[obsTime]]
  pkg_version <- utils::packageVersion("spotoroo")

  # command line output
  cli::cli_div(theme = list(span.vrb = list(color = "yellow"),
                            span.unit = list(color = "magenta"),
                            span.side = list(color = "grey"),
                            span.def = list(color = "black"),
                            .val = list(digits = 3),
                            rule = list("font-weight" = "bold",
                                        "margin-top" = 1,
                                        "margin-bottom" = 0,
                                        color = "cyan",
                                        "font-color" = "black")))
  cli::cli_rule(center = "{.def SPOTOROO {pkg_version}}")
  cli::cli_h2("Calling Core Function : {.fn hotspot_cluster}")

  # more safety checks and handle time col
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

  # get relationship between hot spots and ignition
  to_ignition <- hotspot_to_ignition(lon,
                                     lat,
                                     obsTime,
                                     timeUnit,
                                     global_membership,
                                     ignition)


  # bind result
  result <- list(hotspots =
                   data.frame(lon,
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
                      "{.side for} {.val {length(lon)}} hot spot{?s}"))
  cli::cli_alert_info("{.val {round(total_secs/length(lon), 3)}} {.unit sec{?s}} {.side per} hot spot")
  cli::cli_rule()
  cli::cli_end()

  # set result class
  class(result) <- "spotoroo"

  # return result
  return(result)

}


#' Summarizing spatiotemporal clustering result
#'
#' `summary.spotoroo()` is the `summary` method of the class `spotoroo`.
#' It is a simple wrapper of [summary_spotoroo()].
#'
#' @param object `spotoroo` object.
#' A result of a call to [hotspot_cluster()].
#' @param ... Additional arguments pass to [summary_spotoroo()]
#' @return No return value, called for side effects
#' @examples
#' \donttest{
#'
#'   # Time consuming functions (>5 seconds)
#'
#'
#'   # Get clustering results
#'   result <- hotspot_cluster(hotspots,
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
#'   # Make a summary
#'   summary(result)
#' }
#'
#' @export
summary.spotoroo <- function(object, ...) {
  summary_spotoroo(object, ...)
}


#' Printing spatiotemporal clustering result
#'
#' `print.spotoroo()` is the `print` method of the class `spotoroo`.
#'
#' @param x `spotoroo` object.
#' A result of a call to [hotspot_cluster()].
#' @param ... Additional arguments will be ignored.
#' @return No return value, called for side effects
#' @examples
#' \donttest{
#'
#'   # Time consuming functions (>5 seconds)
#'
#'
#'   # Get clustering results
#'   result <- hotspot_cluster(hotspots,
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
#'   # print the results
#'   print(result)
#' }
#'
#'
#'
#' @export
print.spotoroo <- function(x, ...) {
  num_cluster <- nrow(x$ignition)
  num_hotspot <- nrow(x$hotspots)
  cli::cli_div(theme = list(span.vrb = list(color = "yellow"),
                            span.unit = list(color = "magenta"),
                            span.side = list(color = "grey"),
                            span.def = list(color = "cyan",
                                            `font-weight` = "bold")))
  cli::cli_alert_info("{.def spotoroo} {.vrb object}: {.val {num_cluster}} {.unit clusters} {.side |} {.val {num_hotspot}} {.unit hot spots (including noise points)}")
  cli::cli_end()
}





#' Plotting spatiotemporal clustering result
#'
#' `plot.spotoroo()` is the `plot` method of the class `spotoroo`.
#' It is a simple wrapper of [plot_spotoroo()].
#'
#' @param x `spotoroo` object.
#' A result of a call to [hotspot_cluster()].
#' @param ... Additional arguments pass to [plot_spotoroo()]
#' @return A `ggplot` object. The plot of the clustering results.
#' @examples
#'
#' \donttest{
#'
#'   # Time consuming functions (>5 seconds)
#'
#'
#'   # Get clustering results
#'   result <- hotspot_cluster(hotspots,
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
#'
#'   # Different types of plots
#'
#'   # Default plot
#'   plot(result, "def", bg = plot_vic_map())
#'
#'   # Fire movement plot
#'   plot(result, "mov", cluster = 1:3, step = 3, bg = plot_vic_map())
#' }
#'
#' @export
plot.spotoroo <- function(x, ...) {
  plot_spotoroo(x, ...)
}


