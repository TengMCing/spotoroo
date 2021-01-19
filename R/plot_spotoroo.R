#' Plotting spatiotemporal clustering result
#'
#' can be called by \code{plot.spotoroo()}.
#'
#' if \code{type} = "\code{def}", result will be plotted spatially,
#' see also \code{\link{plot_fire}}.
#' if \code{type} = "\code{timeline}", timeline will be made,
#' see also \code{\link{timeline}}.
#' if \code{type} = "\code{mov}", fire movement will be plotted.
#' see also \code{plot_fire_mov}.
#'
#' @param result an object of class "\code{spotoroo}",
#' a result of a call to \code{\link{hotspot_cluster}}.
#' @param type character; plot type; one of "def", "timeline" and "mov".
#' @param cluster character/numeric; if "all", plot all clusters. if a numeric
#'                 vector is given, plot corresponding clusters.
#' @param ignition logical; if \code{TRUE}, plot the ignition points.
#' @param hotspot logical; if \code{TRUE}, plot the hotspots.
#' @param noise logical; if \code{TRUE}, plot the noises.
#' @param from time/numeric; start time, data type depends on type of observed
#'                           time.
#' @param to time/numeric; end time, data type depends on type of observed
#'                         time.
#' @param bg an object of class "\code{ggplot}", optional; if \code{TRUE},
#' plot onto this object. Now it only supports object without colour related
#' aesthetics.
#' @return an object of class "\code{ggplot}".
#' @examples
#' data("hotspots500")
#' result <- hotspot_cluster(hotspots500,
#'                           lon = "lon",
#'                           lat = "lat",
#'                           obsTime = "obsTime",
#'                           activeTime = 24,
#'                           adjDist = 3000,
#'                           minPts = 4,
#'                           ignitionCenter = "mean",
#'                           timeUnit = "h",
#'                           timeStep = 1)
#'
#' plot_spotoroo(result)
#' @export
plot_spotoroo <- function(result,
                          type = "def",
                          cluster = "all",
                          hotspot = TRUE,
                          noise = FALSE,
                          ignition = TRUE,
                          from = NULL,
                          to = NULL,
                          bg = NULL) {

  if (!"spotoroo" %in% class(result)) {
    stop('Needs a "spotoroo" object as input.')
  }

  check_type("character", type)
  is_length_one(type)

  if (type == "def") {
    p <- plot_def(result,
                  cluster,
                  hotspot,
                  noise,
                  ignition,
                  from,
                  to,
                  bg)

  }

  if (type == "mov") {

    p <- plot_fire_mov(result,
                       cluster,
                       hotspot,
                       noise,
                       from,
                       to,
                       bg)
  }

  if (type == "timeline") {

    p <- plot_timeline(result,
                       from,
                       to)
  }

  p

}




