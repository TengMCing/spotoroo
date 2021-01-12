scatter_spotoroo <- function(results,
                             clusters = "all",
                             hotspots = TRUE,
                             noises = TRUE,
                             ignitions = TRUE,
                             bottom = NULL) {

  n <- noise <- lon <- lat <- ignition_lon <- ignition_lat <- NULL

  if (!"spotoroo" %in% class(results)) {
    stop('Needs a "spotoroo" object as input.')
  }

  # safe check
  check_type_bundle("logical", ignitions, hotspots, noises)

  if (!identical("all", clusters)){
    check_type("numeric", clusters)

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
                                 alpha = 0.6)

  }

  # draw noises
  if (noises) {

    p <- p + ggplot2::geom_point(data = dplyr::filter(results$hotspots,
                                                      noise),
                                 ggplot2::aes(lon,
                                              lat,
                                              col = "noise"),
                                 alpha = 0.3)

  }

  # draw ignitions
  if (ignitions) {
    p <- p +
      ggplot2::geom_point(data = results$ignitions,
                          ggplot2::aes(ignition_lon,
                                       ignition_lat,
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
