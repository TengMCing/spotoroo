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
  if (!all_noises(global_memberships)) {
    ignitions <- ignition_points(lon,
                                 lat,
                                 obsTime,
                                 global_memberships,
                                 ignitionCenter)
  }

  # bind results
  results <- list(hotspots = data.frame(lon,
                                        lat,
                                        obsTime,
                                        memberships = global_memberships,
                                        noise = global_memberships == -1),
                  ignitions = ignitions,
                  timeUnit = timeUnit)


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


# number of obs in each cluster
# ave obs in clusters
# time, distance, coverage
# CLI

len_of_fire <- function(obsTime, timeUnit) {

  return(as.numeric(difftime(max(obsTime),
                             min(obsTime),
                             units = timeUnit)))
}

fire_time_summary <- function(results, timeUnit) {

  time_sum <- dplyr::summarise(dplyr::group_by(results$hotspots,
                                               memberships),
                               t_diff = len_of_fire(obsTime,
                                                    results$timeUnit))
  return(time_sum$t_diff)
}

dist_of_fire <- function(lon, lat, ilon, ilat) {

}


#' @export
summary.spotoroo <- function(results, ...) {

  noise_prop <- mean(results$hotspots$noise) * 100
  results$hotspots <- dplyr::filter(results$hotspots, !noise)

  cat("Clusters:\n")

  cat(paste("    total   ",
            max(results$hotspots$memberships),
            "\n"))

  cat(paste("    ave obs ",
            format(mean(dplyr::count(results$hotspots,
                                     memberships)$n),
                   digits = 3),
            "\n"))

  t_diff <- fire_time_summary(results, timeUnit)

  cat(paste("    ave time",
            format(mean(t_diff),
                   digits = 3),
            results$timeUnit,
            "\n"))


  cat("Noises:\n")

  cat(paste("    prop    ",
            format(noise_prop,
                   digits = 3),
            "   %\n"))

}





#' Plotting spatiotemporal clustering results
#'
#' \code{plot} method for class "\code{spotoroo}"
#'
#' @param results an object of class "\code{spotoroo}",
#' a result of a call to \code{\link{hotspot_cluster}}.
#' @param drawIgnitions logical; if \code{TRUE}, plot the ignition points.
#' @param drawHotspots logical; if \code{TRUE}, plot the hotspots.
#' @param bottom an object of class "\code{ggplot}", optional; if \code{TRUE},
#' plot onto this object.
#' @param ... further arguments will be omitted.
#' @return an object of class "\code{ggplot}".
#' @examples
#' results <- hotspot_cluster(hotspots5000,
#'                            lon = "lon",
#'                            lat = "lat",
#'                            obsTime = "obsTime",
#'                            activeTime = 24,
#'                            adjDist = 3000,
#'                            minPts = 4,
#'                            ignitionCenter = "mean",
#'                            timeUnit = "h",
#'                            timeStep = 1)
#' plot(results)
#' @export
plot.spotoroo <- function(results,
                          drawIgnitions = TRUE,
                          drawHotspots = TRUE,
                          drawNoises = TRUE,
                          bottom = NULL,
                          ...) {

  # safe check
  check_type_bundle("logical", drawIgnitions, drawHotspots, drawNoises)


  # whether or not to draw on an existing plot
  if (ggplot2::is.ggplot(bottom)) {
    p <- bottom
  } else {
    p <- ggplot2::ggplot() + ggplot2::theme_bw()
  }

  # draw hotspots
  if (drawHotspots) {

    p <- p + ggplot2::geom_point(data = dplyr::filter(results$hotspots,
                                                      !noise),
                                 ggplot2::aes(lon,
                                              lat),
                                 alpha = 0.6)

  }

  # draw noises
  if (drawNoises) {

    p <- p + ggplot2::geom_point(data = dplyr::filter(results$hotspots,
                                                      noise),
                                 ggplot2::aes(lon,
                                              lat,
                                              col = "noise"),
                                 alpha = 0.3)

  }

  # draw ignitions
  if (drawIgnitions) {
    p <- p +
      ggplot2::geom_point(data = results$ignitions,
                                 ggplot2::aes(ignition_lon,
                                              ignition_lat,
                                              col = "ignition"))
  }

  # define colours
  draw_cols <- c("red", "blue")[c(drawIgnitions, drawNoises)]
  if (length(draw_cols) > 0) {
    p <- p + ggplot2::scale_color_manual(values = draw_cols)
  }

  # define labs
  p <- p + ggplot2::labs(col = "", x = "lon", y = "lat")

  # return the plot
  return(p)
}
