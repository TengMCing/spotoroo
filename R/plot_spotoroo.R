#' Plotting spatiotemporal clustering results
#'
#' can be called by \code{plot.spotoroo()}.
#'
#' if \code{type} = "\code{static}", results will be plotted spatially,
#' see also \code{\link{static_spotoroo}}.
#' if \code{type} = "\code{dynamic}", the plot will be faceted by time.
#' see also \code{dynamic_spotoroo}.
#'
#' @param results an object of class "\code{spotoroo}",
#' a result of a call to \code{\link{hotspot_cluster}}.
#' @param type character; plot type; one of "static" and "dynamic".
#' @param clusters character/numeric; if "all", plot all clusters. if a numeric
#'                 vector is given, plot corresponding clusters.
#' @param ignitions logical; if \code{TRUE}, plot the ignition points.
#' @param hotspots logical; if \code{TRUE}, plot the hotspots.
#' @param noises logical; if \code{TRUE}, plot the noises.
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
#'
#' plot_spotoroo(results)
#' @export
plot_spotoroo <- function(results,
                          type = "static",
                          clusters = "all",
                          hotspots = TRUE,
                          noises = FALSE,
                          ignitions = TRUE,
                          bottom = NULL) {

  if (!"spotoroo" %in% class(results)) {
    stop('Needs a "spotoroo" object as input.')
  }

  check_type("character", type)
  is_length_one(type)

  if (type == "static") {
    p <- static_spotoroo(results,
                         clusters,
                         hotspots,
                         noises,
                         ignitions,
                         bottom)

  }

  if (type == "dynamic") {

    p <- dynamic_spotoroo(results,
                          clusters,
                          hotspots,
                          noises,
                          bottom)
  }

  p

}




