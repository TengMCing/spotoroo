#' Plotting map of Victoria, Australia
#'
#' This function plots the map of Victoria, Australia.
#'
#' Require package `sf` installed.
#'
#' @param ... All arguments will be ignored.
#' @return A `ggplot` object. The map of Victoria, Australia.
#' @examples
#' if (requireNamespace("sf", quietly = TRUE)) {
#'   plot_vic_map()
#' }
#'
#' @export
plot_vic_map <- function(...) {

  if (!requireNamespace("sf", quietly = TRUE)) {
    cli::cli_alert_danger("Package {.pkg sf} needed for {.fn plot_vic_map} to work")
    return(NULL)
  }

  vic_map <- vic_map
  sf::st_crs(vic_map) <- 4326
  geometry <- NULL

  ggplot2::ggplot() +
    ggplot2::geom_sf(data = vic_map,
                     ggplot2::aes(geometry = geometry)) +
    ggplot2::theme_bw(base_size = 9) +
    ggplot2::theme(axis.line = ggplot2::element_blank(),
                   axis.text = ggplot2::element_blank(),
                   axis.ticks = ggplot2::element_blank(),
                   axis.title = ggplot2::element_blank(),
                   panel.background = ggplot2::element_blank(),
                   panel.border = ggplot2::element_blank(),
                   panel.grid = ggplot2::element_blank(),
                   panel.spacing = ggplot2::unit(0, "lines"),
                   plot.background = ggplot2::element_blank(),
                   legend.justification = c(0, 0),
                   legend.position = c(0, 0))
}
