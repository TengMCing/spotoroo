#' Spatiotemporal clustering of hotspots
#'
#' `hotspot_cluster()` cluster hotspots into fires. It can be used to
#' reconstruct fire history and detect fire ignition points.
#'
#' If the observed time of the hotspot is given and it is not a postive
#' integer vector, parameter `timeUnit` and `timeStep` need to be
#' specified to convert date/datetime/numeric to time index.
#' More details can be found in [transform_time_id()].
#' \cr\cr
#' This clustering algorithm is consist of **5 steps**:
#' \cr\cr
#' In **step 1**, it defines \eqn{T} intervals using the time index
#' \deqn{St = [max(1, t - activeTime),t]}
#' where \eqn{t = 1, 2, ..., T}, and \eqn{T} is the maximum time index.
#' `activeTime` is a parameter that needs to be specified. It represents
#' the maximum time difference between two hotspots in the same local
#' cluster. Please notice that a local cluster is different with a cluster
#' in the final result. More details will be given in the next part.
#' \cr\cr
#' In **step 2**, the algorithm performs spatial clustering on each interval.
#' A local cluster is a cluster found in an interval. Parameter `adjDist`
#' is used to control the spatial clustering. If the distance between two
#' hotspots is smaller or equal to `adjDist`, they are directly-connected. If
#' hotspot `A` is directly-connected with hotspot `B` and hotspot `B` is
#' directly-connected with hotspot `C`, hotspot `A`, `B` and `C` are
#' connected. All connected hotspots become a local cluster.
#' \cr\cr
#' In **step 3**, the algorithm starts from interval \eqn{1}. It flags all
#' hotspots in this interval and records their membership labels.
#' Then it moves on to interval \eqn{2}. Due to a hotspot could exist in
#' multiple intervals, it checks whether any hotspot in interval \eqn{2}
#' has been flagged. If there is any, their membership labels will be
#' carried over from the record. Unflagged hotspots in interval \eqn{2},
#' which share the same local cluster with flagged hotspots, their
#' membership labels are carried over from flagged hotspots. If a unflagged
#' hotspot shares the same local cluster with multiple flagged hotspots, the
#' algorithm will carry over the membership label from the nearest one. All
#' other unflagged hotspots in interval \eqn{2} that do not share the same
#' cluster with any flagged hotspot, their membership labels will be adjusted.
#' The clusters they belong to are considered to be new clusters. Finally, all
#' hotspots in interval \eqn{2} are flagged and their membership labels are
#' recorded. This process continues for interval \eqn{3}, \eqn{4}, ...,
#' \eqn{T}. After finishing step 3, all hotspots are flagged and their
#' membership labels are recorded.
#' \cr\cr
#' In **step 4**, it checks each cluster. If there is any cluster contains less
#' than `minPts` hotspots, or lasts shorter than `minTime`, it will not be
#' considered to be a cluster any more, and their hotspots will be
#' assigned with `-1` as their membership labels. A hotspot with membership
#' label `-1` is noise.
#' Parameter `minPts` and `minTime` needs to be specified.
#' \cr\cr
#' In **step 5**, the algorithm finds the earliest observed hotspots in each
#' cluster and records them as ignition points. If there are multiple
#' earliest observed hotspots in a cluster, the mean or median of the
#' longitude values and the latitude values will be used as the coordinate
#' of the ignition point. This needs to be specified in parameter
#' `ignitionCenter`.
#'
#'
#'
#' @param hotspots list/data frame; a list or data frame which
#'                                  contains information of hotspots.
#' @param lon character; the name of the column of the list which contains
#'                       numeric longitude values.
#' @param lat character; the name of the column of the list which contains
#'                       numeric latitude values.
#' @param obsTime character; the name of the column of the list which contains
#'                           the observed time of hotspots in date, datetime or
#'                           numeric. Only if this column is a positive
#'                           integer vector, `timeUnit` and `timeStep`
#'                           do not need to be specified.
#' @param activeTime numeric (>=0); time tolerance; unit is time index.
#' @param adjDist numeric (>0); distance tolerance; unit is metre.
#' @param minPts numeric (>0); minimum number of hotspots in a cluster.
#' @param minTime numeric (>=0); minimum length of time of a cluster;
#'                               unit is time index.
#' @param ignitionCenter character; method to calculate ignition points,
#'                                  either "mean" or "median".
#' @param timeUnit **OPTIONAL**; character; one of "s" (seconds),
#'                                      "m" (minutes), "h" (hours),
#'                                      "d" (days) and "n" (numeric).
#' @param timeStep **OPTIONAL**; numeric (>0); number of units of `timeUnit` in
#'                                             a time step.
#' @return A `spotoroo` object; the clustering result; it is also a list:
#' \itemize{
#'   \item \code{hotspots} : a data frame contains information of hotspots.
#'   \itemize{
#'     \item \code{lon} : longitude.
#'     \item \code{lat} : latitude.
#'     \item \code{obsTime} : observed time.
#'     \item \code{timeID} : time index.
#'     \item \code{membership} : membership label.
#'     \item \code{noise} : whether it is noise.
#'     \item \code{distToIgnition} : distance to ignition.
#'     \item \code{distToIgnitionUnit} : unit of distance to ignition.
#'     \item \code{timeFromIgnition} : time from ignition.
#'   }
#'   \item \code{ignition} : a data frame contains information of ignition
#'                           points.
#'   \itemize{
#'     \item \code{lon} : longitude.
#'     \item \code{lat} : latitude.
#'     \item \code{obsTime} : observed time.
#'     \item \code{timeID} : time index.
#'     \item \code{obsInCluster} : number of observations in the cluster.
#'     \item \code{clusterTimeLen} : length of time of the cluster.
#'   }
#'   \item \code{setting} : a list contains the clustering settings.
#' }
#' @examples
#'
#' result <- hotspot_cluster(hotspots_fin,
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
#' plot(result)
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
                            timeUnit = NULL,
                            timeStep = NULL) {

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
  is_non_negative_bundle(activeTime, minTime)
  is_positive_bundle(adjDist, minPts)
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

  # get relationship between hotspots and ignition
  to_ignition <- hotspot_to_ignition(lon,
                                     lat,
                                     obsTime,
                                     timeUnit,
                                     global_membership,
                                     ignition)


  # bind results
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
#' `plot.spotoroo()` is the `plot` method of the class `spotoroo`.
#' It is a simple wrapper of [plot_spotoroo()].
#'
#' @param x `spotoroo` object;
#' a result of a call to [hotspot_cluster()].
#' @param \dots additional arguments pass to [plot_spotoroo()]
#' @examples
#' results <- hotspot_cluster(hotspots_fin,
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
#' # default plot
#' plot(results)
#'
#' # three different types of plots
#' plot(results, "def")
#' plot(results, "mov")
#'
#' @export
plot.spotoroo <- function(x, ...) {
  plot_spotoroo(x, ...)
}

