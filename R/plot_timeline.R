#' @export
plot_timeline <- function(result,
                          from = NULL,
                          to = NULL) {

  if (!"spotoroo" %in% class(result)) {
    stop('Needs a "spotoroo" object as input.')
  }

  # from date
  if (!is.null(from)) {
    is_length_one(from)

    indexes <- result$hotspots$obsTime >= from
    result$hotspots <- result$hotspots[indexes, ]
    if (nrow(result$hotspots) == 0) {
      stop(paste("No hotspots observed later than", from))
    }
  }

  # to date
  if (!is.null(to)) {
    is_length_one(to)

    indexes <- result$hotspots$obsTime <= to
    result$hotspots <- result$hotspots[indexes, ]
    if (nrow(result$hotspots) == 0) {
      stop(paste("No hotspots observed ealier than", to))
    }
  }


  p <- ggplot2::ggplot(result$hotspots) +
    ggplot2::geom_point(ggplot2::aes(obsTime,
                                     membership,
                                     col = noise),
                        alpha = 0.4) +
    ggplot2::theme_light(base_size = 9) +
    ggplot2::theme(axis.ticks.y = element_blank())

  # add title
  title <- paste("Fires Selected:", nrow(result$ignition), "\n")
  left <- min(result$hotspots$obsTime)
  right <- max(result$hotspots$obsTime)

  if (!is.null(from)) left <- from
  title <- paste0(title, "From: ", left, "\n")

  if (!is.null(to)) right <- to
  title <- paste0(title, "To:      ", right)

  p <- p + ggplot2::labs(title = "Timeline",
                         subtitle = title,
                         y = "")

  p <- ggExtra::ggMarginal(p, groupColour = TRUE, margins = c("x"))

  p
}
