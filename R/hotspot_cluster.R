#' @export
hotspot_cluster <- function(hotspots,
                            lon = "lon",
                            lat = "lat",
                            obstime = "obstime",
                            ActiveTime = 24,
                            AdjDist = 3000,
                            MinPts = 4,
                            ignition_center = "mean",
                            time_unit = NULL,
                            timestep = NULL){

  # safe checks
  check_type("list", hotspots)
  check_type_bundle("character", lon, lat, obstime)
  check_in(c("mean", "median"), ignition_center)
  is_non_negative(ActiveTime)
  is_positive(AdjDist)

  # access cols
  lon <- hotspots[[lon]]
  lat <- hotspots[[lat]]
  obstime <- hotspots[[obstime]]

  # more safe checks and handle time col
  time_id <- handle_hotspots_cols(lon,
                                  lat,
                                  obstime,
                                  time_unit,
                                  timestep)

  # start timing
  start_time <- Sys.time()

  # obtain memberships
  global_memberships <- global_clustering(lon,
                                          lat,
                                          time_id,
                                          ActiveTime,
                                          AdjDist,
                                          ignition_center)

  # handle noises
  results <- handle_noises(lon,
                           lat,
                           obstime,
                           ignition_center,
                           global_memberships,
                           time_unit,
                           MinPts)

  # stop timing
  end_time <- Sys.time()
  time_taken <- end_time - start_time

  # print run time
  cat(paste0("Time taken: ",
             as.numeric(time_taken, units = "secs") %/% 60,
             " mins ",
             round(as.numeric(time_taken, units = "secs") %% 60, 0),
             " secs for ",
             length(lon),
             " obs "
             )
      )
  cat(paste0("(",
             round(as.numeric(time_taken, units = "secs")/length(lon), 3),
             " secs/obs)\n"))

  # set result class
  class(results) <- "hotspotcluster"

  # return result
  return(results)

}


# number of obs in each cluster
# ave obs in clusters
# time, distance, coverage
# CLI

len_of_fire <- function(obstime, time_unit){

  return(as.numeric(difftime(max(obstime),
                             min(obstime),
                             units = time_unit)))
}

fire_time_summary <- function(results, time_unit){

  time_sum <- dplyr::summarise(dplyr::group_by(results$hotspots,
                                               memberships),
                               t_diff = len_of_fire(obstime,
                                                    results$time_unit))
  return(time_sum$t_diff)
}

dist_of_fire <- function(lon, lat, ilon, ilat){

}


#' @export
summary.hotspotcluster <- function(results, ...){

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

  t_diff <- fire_time_summary(results, time_unit)

  cat(paste("    ave time",
            format(mean(t_diff),
                   digits = 3),
            results$time_unit,
            "\n"))


  cat("Noises:\n")

  cat(paste("    prop    ",
            format(noise_prop,
                   digits = 3),
            "   %\n"))

}





#' Plotting spatiotemporal clustering results
#'
#' \code{plot} method for class "\code{hotspotcluster}"
#'
#' @param results an object of class "\code{hotspotcluster}",
#' a result of a call to \code{\link{hotspot_cluster}}.
#' @param draw_ignitions logical; if \code{TRUE}, plot the ignition points.
#' @param draw_hotspots logical; if \code{TRUE}, plot the hotspots.
#' @param bottom an object of class "\code{ggplot}"", optional; if \code{TRUE},
#' plot onto this object.
#' @param ... further arguments will be omitted.
#' @return an object of class "\code{ggplot}",
#' @examples
#' results <- hotspot_cluster(hotspots5000,
#'                            lon = "lon",
#'                            lat = "lat",
#'                            obstime = "obstime",
#'                            ActiveTime = 24,
#'                            AdjDist = 3000,
#'                            ignition_center = "mean",
#'                            time_unit = "hours",
#'                            timestep = 1)
#' plot(results)
#' @export
plot.hotspotcluster <- function(results,
                                draw_ignitions = TRUE,
                                draw_hotspots = TRUE,
                                draw_noises = TRUE,
                                bottom = NULL,
                                ...){

  # safe check
  check_type_bundle("logical", draw_ignitions, draw_hotspots, draw_noises)


  # whether or not to draw on an existing plot
  if (ggplot2::is.ggplot(bottom)){
    p <- bottom
  } else {
    p <- ggplot2::ggplot() + ggplot2::theme_bw()
  }

  # draw hotspots
  if (draw_hotspots){

    p <- p + ggplot2::geom_point(data = dplyr::filter(results$hotspots,
                                                      !noise),
                                 ggplot2::aes(lon,
                                              lat),
                                 alpha = 0.6)

  }

  # draw noises
  if (draw_noises){

    p <- p + ggplot2::geom_point(data = dplyr::filter(results$hotspots,
                                                      noise),
                                 ggplot2::aes(lon,
                                              lat,
                                              col = "noise"),
                                 alpha = 0.3)

  }

  # draw ignitions
  if (draw_ignitions){
    p <- p +
      ggplot2::geom_point(data = results$ignitions,
                                 ggplot2::aes(ignition_lon,
                                              ignition_lat,
                                              col = "ignition"))
  }

  # define colours
  draw_cols <- c("red", "blue")[c(draw_ignitions, draw_noises)]
  if (length(draw_cols) > 0){
    p <- p + ggplot2::scale_color_manual(values = draw_cols)
  }

  # define labs
  p <- p + ggplot2::labs(col = "", x = "lon", y = "lat")

  # return the plot
  return(p)
}
