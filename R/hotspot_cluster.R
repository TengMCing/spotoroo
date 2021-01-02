#' @export
hotspot_cluster <- function(hotspots,
                            lon = "lon",
                            lat = "lat",
                            obstime = "obstime",
                            ActiveTime = 24,
                            AdjDist = 3000,
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
  # compute ignition points
  ignitions <- ignition_points(lon,
                               lat,
                               obstime,
                               global_memberships,
                               ignition_center)

  # bind results
  results <- list(hotspots = data.frame(lon,
                                        lat,
                                        obstime,
                                        memberships = global_memberships),
                  ignitions = ignitions)


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







#' @export
summary.hotspotcluster <- function(results, ...){
  cat(paste0("Number of clusters: ", max(results$hotspots$memberships), "\n"))
}






#' Plotting spatiotemporal clustering results
#'
#' \code{plot} method for class "\code{hotspotcluster}"
#'
#' @param results a \code{hotspotcluster} object, result of \code{\link{hotspot_cluster}}.
#' @param draw_ignitions logical; whether or not to plot the ignitions.
#' @param draw_hotspots logical; whether or not to plot the hotspots.
#' @param bottom a \code{ggplot} object (optional). plot onto this object.
#' @param ... further arguments will be omitted.
#' @return a \code{ggplot} object.
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
                                bottom = NULL,
                                ...){

  # safe check
  check_type_bundle("logical", ignition, hotspot)

  # whether or not to draw on an existing plot
  if (ggplot2::is.ggplot(bottom)) {
    p <- bottom
  } else {
    p <- ggplot2::ggplot() + ggplot2::theme_bw()
  }

  # draw hotspots
  if (hotspot) {
    p <- p + ggplot2::geom_point(data = results$hotspots,
                                 ggplot2::aes(lon, lat), alpha = 0.6)
  }

  # draw ignitions
  if (ignition) {
    p <- p +
      ggplot2::geom_point(data = results$ignitions,
                                 ggplot2::aes(ignition_lon,
                                              ignition_lat,
                                              col = "ignition")) +
    ggplot2::scale_color_manual(values = "red") +
    ggplot2::labs(col = "", x = "lon", y = "lat")
  }

  # return the plot
  return(p)
}
