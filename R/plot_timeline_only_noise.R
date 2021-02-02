# plot timeline when there is only noise
plot_timeline_only_noise <- function(result,
                                     from = NULL,
                                     to = NULL,
                                     mainBreak = NULL,
                                     minorBreak = NULL,
                                     dateLabel = NULL) {

  # pass CMD CHECK variables
  obsTime <- membership <- ..scaled.. <- NULL

  noise_num <- nrow(result$hotspots)
  result$hotspots$membership <- result$hotspots$membership + 1

  p <- ggplot2::ggplot() +
    ggbeeswarm::geom_quasirandom(data = result$hotspots,
                        ggplot2::aes(obsTime,
                                     membership),
                        col = "#d95f02",
                        groupOnX = FALSE,
                        width = 0.1,
                        alpha = max(1/log(noise_num), 0.1),
                        size = 1) +
    ggplot2::geom_density(data = result$hotspots,
                          ggplot2::aes(obsTime, ..scaled../10),
                          linetype = 2
    ) +
    ggplot2::geom_density(data = result$hotspots,
                          ggplot2::aes(obsTime, -..scaled../10),
                          linetype = 2
    ) +
    ggplot2::theme_bw() +
    ggplot2::theme(axis.text.y = ggplot2::element_blank(),
                   axis.ticks.y = ggplot2::element_blank())

  args_list <- list()
  if (!is.null(mainBreak)) args_list[['date_breaks']] <- mainBreak
  if (!is.null(minorBreak)) args_list['date_minor_breaks'] <- minorBreak
  if (!is.null(dateLabel)) args_list[['date_labels']] <- dateLabel

  if (("Date" %in% class(result$hotspots$obsTime)) & (length(args_list) > 0)) {

    p <- p + do.call(ggplot2::scale_x_date, args_list)

  }

  if (("POSIXct" %in% class(result$hotspots$obsTime)) & (length(args_list) > 0)) {

    p <- p + do.call(ggplot2::scale_x_datetime, args_list)

  }

  if ("numeric" %in% class(result$hotspots$obsTime)) {

    minid <- min(result$hotspots$obsTime)
    maxid <- max(result$hotspots$obsTime)
    args_list <- list()

    if (!is.null(mainBreak)) {
      majbreaks <- seq(minid,
                       (maxid %/% mainBreak + (maxid %% mainBreak != 0)) *
                         mainBreak,
                       mainBreak)
      args_list[['breaks']] <- majbreaks
    }

    if (!is.null(minorBreak)) {
      minbreaks <- seq(minid,
                       (maxid %/% minorBreak + (maxid %% minorBreak != 0)) *
                         minorBreak,
                       minorBreak)
      args_list[['minor_breaks']] <- minbreaks
    }


    if (length(args_list) > 0) {
      p <- p + do.call(ggplot2::scale_x_continuous, args_list)
    }

  }

  # add title
  title <- paste("Fires Selected:", 0, "\n")
  left <- min(result$hotspots$obsTime)
  right <- max(result$hotspots$obsTime)

  if (!is.null(from)) left <- from
  title <- paste0(title, "From: ", left, "\n")

  if (!is.null(to)) right <- to
  title <- paste0(title, "To:      ", right)

  p <- p + ggplot2::labs(title = "Timeline of Noise",
                         subtitle = title,
                         y = "",
                         x = "",
                         col = "")

  return(p)

}
