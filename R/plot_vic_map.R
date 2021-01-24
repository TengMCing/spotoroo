#' @export
plot_vic_map <- function() {
  ggplot2::ggplot(vic_map) +
    ggplot2::geom_sf() +
    ggplot2::theme_bw(base_size = 9) +
    ggplot2::theme(axis.line = element_blank(),
                   axis.text = element_blank(),
                   axis.ticks = element_blank(),
                   axis.title = element_blank(),
                   panel.background = element_blank(),
                   panel.border = element_blank(),
                   panel.grid = element_blank(),
                   panel.spacing = unit(0, "lines"),
                   plot.background = element_blank(),
                   legend.justification = c(0, 0),
                   legend.position = c(0, 0))
}
