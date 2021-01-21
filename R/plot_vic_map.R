#' @export
plot_vic_map <- function() {
  ggplot2::ggplot(vic_map) +
    ggplot2::geom_sf() +
    ggthemes::theme_map()
}
