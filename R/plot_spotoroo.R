#' Plotting spatiotemporal clustering results
#'
#' can be called by \code{plot.spotoroo()}.
#'
#' @param results an object of class "\code{spotoroo}",
#' a result of a call to \code{\link{hotspot_cluster}}.
#' @param drawIgnitions logical; if \code{TRUE}, plot the ignition points.
#' @param drawHotspots logical; if \code{TRUE}, plot the hotspots.
#' @param drawNoises logical; if \code{TRUE}, plot the noises.
#' @param bottom an object of class "\code{ggplot}", optional; if \code{TRUE},
#' plot onto this object.
#' @return an object of class "\code{ggplot}".
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
#' plot(results)
#' @export
plot_spotoroo <- function(results,
                          drawIgnitions = TRUE,
                          drawHotspots = TRUE,
                          drawNoises = TRUE,
                          bottom = NULL) {

  n <- noise <- lon <- lat <- ignition_lon <- ignition_lat <- NULL

  if (!"spotoroo" %in% class(results)) {
    stop('Needs a "spotoroo" object as input.')
  }


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
