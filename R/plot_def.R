plot_def <- function(result,
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

  # safety chek
  check_type_bundle("logical", hotspot, ignition, noise)
  is_length_one_bundle(hotspot, ignition, noise)

  # extract corresponding clusters
  if (!identical("all", cluster)){
    check_type("numeric", cluster)

    if (length(cluster) == 0) stop("Please provide valid membership labels.")

    indexes <- result$ignition$membership %in% cluster
    result$ignition <- result$ignition[indexes, ]

    indexes <- result$hotspots$membership %in% c(cluster, -1)
    result$hotspots <- result$hotspots[indexes, ]
  }

  # from date
  if (!is.null(from)) {
    is_length_one(from)
    indexes <- result$ignition$obsTime >= from
    result$ignition <- result$ignition[indexes, ]

    indexes <- result$hotspots$obsTime >= from
    result$hotspots <- result$hotspots[indexes, ]
  }

  # to date
  if (!is.null(to)) {
    is_length_one(to)
    indexes <- result$ignition$obsTime <= to
    result$ignition <- result$ignition[indexes, ]

    indexes <- result$hotspots$obsTime <= to
    result$hotspots <- result$hotspots[indexes, ]
  }


  # whether or not to draw on an existing plot
  if (ggplot2::is.ggplot(bg)) {
    p <- bg
  } else {
    p <- ggplot2::ggplot() + ggplot2::theme_bw()
  }

  # draw hotspots
  if (hotspot) {

    p <- p + ggplot2::geom_point(data = dplyr::filter(result$hotspots,
                                                      !noise),
                                 ggplot2::aes(lon,
                                              lat),
                                 alpha = 0.4)

  }

  # draw noises
  if (noise) {

    p <- p + ggplot2::geom_point(data = dplyr::filter(result$hotspots,
                                                      noise),
                                 ggplot2::aes(lon,
                                              lat,
                                              col = "noise"),
                                 alpha = 0.2)

  }

  # draw ignitions
  if (ignition) {
    p <- p +
      ggplot2::geom_point(data = result$ignition,
                          ggplot2::aes(lon,
                                       lat,
                                       col = "ignition"))
  }

  # define labs
  p <- p + ggplot2::labs(col = "", x = "lon", y = "lat")

  # return the plot
  return(p)


}
