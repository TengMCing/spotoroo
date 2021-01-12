#' Plotting spatiotemporal clustering results
#'
#' can be called by \code{plot.spotoroo()}.
#'
#' @param results an object of class "\code{spotoroo}",
#' a result of a call to \code{\link{hotspot_cluster}}.
#' @param type character; plot type; one of "scatter" and "trace".
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
#' plot(results)
#' @export
plot_spotoroo <- function(results,
                          type = "scatter",
                          clusters = "all",
                          hotspots = TRUE,
                          noises = TRUE,
                          ignitions = TRUE,
                          bottom = NULL) {

  if (!"spotoroo" %in% class(results)) {
    stop('Needs a "spotoroo" object as input.')
  }

  check_type("character", type)
  is_length_one(type)

  if (type == "scatter") scatter_spotoroo(results,
                                          clusters,
                                          hotspots,
                                          noises,
                                          ignitions,
                                          bottom)

}




