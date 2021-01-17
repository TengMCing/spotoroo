#' Plotting spatiotemporal clustering results spatially: without fire movement
#'
#' can be called by \code{plot.spotoroo()} or \code{plot_spotoroo()}.
#'
#' @param results an object of class "\code{spotoroo}",
#' a result of a call to \code{\link{hotspot_cluster}}.
#' @param clusters character/numeric; if "all", plot all clusters. if a numeric
#'                 vector is given, plot corresponding clusters.
#' @param ignitions logical; if \code{TRUE}, plot the ignition points.
#' @param hotspots logical; if \code{TRUE}, plot the hotspots.
#' @param noises logical; if \code{TRUE}, plot the noises.
#' @param bottom an object of class "\code{ggplot}", optional; if \code{TRUE},
#' plot onto this object. Now it only supports object without colour related
#' aesthetics.
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
#'
#' static_spotoroo(results)
#' @export
static_spotoroo <- function(results,
                            clusters = "all",
                            hotspots = TRUE,
                            noises = FALSE,
                            ignitions = TRUE,
                            bottom = NULL) {

  n <- noise <- lon <- lat <- ignition_lon <- ignition_lat <- NULL

  if (!"spotoroo" %in% class(results)) {
    stop('Needs a "spotoroo" object as input.')
  }

  # safe check
  check_type_bundle("logical", ignitions, hotspots, noises)
  is_length_one_bundle(ignitions, hotspots, noises)

  # extract corresponding clusters
  if (!identical("all", clusters)){
    check_type("numeric", clusters)

    if (length(clusters) == 0) stop("Please provide valid membership labels.")

    indexes <- results$ignition$membership %in% clusters
    results$ignition <- results$ignition[indexes, ]

    indexes <- results$hotspots$membership %in% c(clusters, -1)
    results$hotspots <- results$hotspots[indexes, ]
  }


  # whether or not to draw on an existing plot
  if (ggplot2::is.ggplot(bottom)) {
    p <- bottom
  } else {
    p <- ggplot2::ggplot() + ggplot2::theme_bw()
  }

  # draw hotspots
  if (hotspots) {

    p <- p + ggplot2::geom_point(data = dplyr::filter(results$hotspots,
                                                       !noise),
                                  ggplot2::aes(lon,
                                               lat),
                                  alpha = 0.4)

  }

  # draw noises
  if (noises) {

    p <- p + ggplot2::geom_point(data = dplyr::filter(results$hotspots,
                                                       noise),
                                  ggplot2::aes(lon,
                                               lat,
                                               col = "noise"),
                                  alpha = 0.2)

  }

  # draw ignitions
  if (ignitions) {
    p <- p +
      ggplot2::geom_point(data = results$ignition,
                          ggplot2::aes(lon,
                                       lat,
                                       col = "ignition"))
  }

  # define colours
  draw_cols <- c("red", "blue")[c(ignitions, noises)]
  if (length(draw_cols) > 0) {
    p <- p + ggplot2::scale_color_manual(values = draw_cols)
  }

  # define labs
  p <- p + ggplot2::labs(col = "", x = "lon", y = "lat")

  # return the plot
  return(p)

}
