#' Plotting spatiotemporal clustering results spatially: with fire movement
#'
#' can be called by \code{plot.spotoroo()} or \code{plot_spotoroo()}.
#'
#' @param results an object of class "\code{spotoroo}",
#' a result of a call to \code{\link{hotspot_cluster}}.
#' @param clusters character/numeric; if "all", plot all clusters. if a numeric
#'                 vector is given, plot corresponding clusters. plotting more
#'                 than one cluster is not recommended by this function.
#' @param hotspots logical; if \code{TRUE}, plot the hotspots.
#' @param noises logical; if \code{TRUE}, plot the noises. plotting noises is
#' not recommended by this function.
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
#' dynamic_spotoroo(results, clusters = 1)
#' @export
dynamic_spotoroo <- function(results,
                             clusters = "all",
                             hotspots = TRUE,
                             noises = FALSE,
                             bottom = NULL) {

  noise <- lon <- lat <- timeID <- memberships <- NULL

  if (!"spotoroo" %in% class(results)) {
    stop('Needs a "spotoroo" object as input.')
  }

  # safe check
  check_type_bundle("logical", hotspots, noises)
  is_length_one_bundle(hotspots, noises)

  # extract corresponding clusters
  if (!identical("all", clusters)){
    check_type("numeric", clusters)

    if (length(clusters) == 0) stop("Please provide valid cluster ID.")

    indexes <- results$ignitions$memberships %in% clusters
    results$ignitions <- results$ignitions[indexes, ]

    indexes <- results$hotspots$memberships %in% c(clusters, -1)
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
    cli::cli_alert_info("Plotting noises in dynamic mode is not recommended.")

    p <- p + ggplot2::geom_point(data = dplyr::filter(results$hotspots,
                                                       noise),
                                  ggplot2::aes(lon,
                                               lat,
                                               col = "noise"),
                                  alpha = 0.2)

  }

  fire_mov_records <- NULL

  if (identical("all", clusters)) {
    clusters <- 1:max(results$hotspots$memberships)
  }

  if (length(clusters) > 1) {
    cli::cli_alert_info("Plotting multiple clusters in dynamic mode is not recommended.")
  }

  # get fire mov
  for (i in clusters) {
    temp_data <- fire_mov(results, i)

    if (is.null(fire_mov_records)) {
      fire_mov_records <- temp_data
    } else {
      fire_mov_records <- dplyr::bind_rows(fire_mov_records, temp_data)
    }

  }

  p <- p + ggplot2::geom_point(data = fire_mov_records,
                               ggplot2::aes(lon, lat),
                               col = "blue") +
    ggplot2::geom_point(data = fire_mov_records[1, ],
                        ggplot2::aes(lon, lat, col = "ignition"),
                        size = 2) +
    ggplot2::geom_path(data = fire_mov_records,
                       ggplot2::aes(lon, lat, group = memberships),
                       col = "blue") +
    ggplot2::scale_color_manual(values = c("red", "blue")[c(TRUE, noises)])

  p <- p + ggplot2::labs(col = "", x = "lon", y = "lat")

  p


}
