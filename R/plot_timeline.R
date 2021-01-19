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
    ggplot2::theme_bw()

  # add title
  title <- ""

  if (!is.null(from)) {
    title <- paste("From:", from)
  }

  if (!is.null(to)) {
    title <- paste(title, "To:", to)
  }

  if ((!is.null(from)) | (!is.null(to))) {
    p <- p + ggplot2::labs(subtitle = title)
  }

  p
}
