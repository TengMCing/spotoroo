#' @export
plot_timeline <- function(result,
                          from = NULL,
                          to = NULL,
                          mainBreak = NULL,
                          minorBreak = NULL,
                          dateLabel = NULL) {

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

  if (all(result$hotspots$membership == -1)) {
    p <- ggplot2::ggplot() +
      ggplot2::geom_point(data = dplyr::filter(result$hotspots,
                                               noise),
                          ggplot2::aes(obsTime,
                                       jitter(membership)),
                          col = "#d95f02",
                          alpha = c(0.4, 0.2)[c(noise_num <=50,
                                                noise_num > 50)],
                          size = 1) +
      ggplot2::geom_density(data = dplyr::filter(result$hotspots,
                                                noise),
                           ggplot2::aes(obsTime, ..scaled.. - 1)
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

    } else {

      p <- p + do.call(ggplot2::scale_x_datetime, args_list)

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

  max_index <- max(result$hotspots$membership)
  power10 <- trunc(log10(max_index))
  base10 <- 10^power10
  max_lab <- (max_index %/% base10 + (max_index %% base10 != 0)) * base10
  y_values <- seq(-base10, max_lab, base10)
  y_labs <- as.character(y_values)
  y_labs[1] <- "noise"

  noise_vec <- runif(sum(result$hotspots$membership == -1),
                     -base10 * 0.2,
                     base10 * 0.2)
  result$hotspots$membership[result$hotspots$membership == -1] <- -base10 +
    noise_vec

  not_noise <- dplyr::filter(result$hotspots, !noise)
  not_noise <- dplyr::group_by(not_noise, membership)
  not_noise <- dplyr::summarise(not_noise,
                                startt = min(obsTime),
                                endt = max(obsTime))

  if (max_index < 50) {
    p <- ggplot2::ggplot() +
      ggplot2::geom_point(data = dplyr::filter(result$hotspots,
                                               !noise),
                          ggplot2::aes(obsTime,
                                       membership,
                                       col = "fire"),
                          alpha = 0.3)
  } else {

    p <- ggplot2::ggplot() +
      ggplot2::geom_point(data = dplyr::filter(result$hotspots,
                                               !noise),
                          ggplot2::aes(obsTime,
                                       membership,
                                       col = "fire"),
                          alpha = 0) +
      # ggplot2::geom_point(data = not_noise,
      #                     ggplot2::aes(startt,
      #                                  membership),
      #                     alpha = 1,
      #                     col = "#1b9e77") +
      # ggplot2::geom_point(data = not_noise,
      #                     ggplot2::aes(endt,
      #                                  membership),
      #                     alpha = 1,
      #                     col = "#1b9e77") +
      ggplot2::geom_segment(data = not_noise,
                            ggplot2::aes(x = startt,
                                         xend = endt,
                                         y = membership,
                                         yend = membership),
                            alpha = 1,
                            col = "#1b9e77",
                            size = 1.25)
  }

  p <- p + ggplot2::geom_hline(yintercept = 0, alpha = 0.5)

  noise_num <- nrow(dplyr::filter(result$hotspots, noise))

  if (noise_num > 50) {
    p <- p + ggplot2::geom_density(data = dplyr::filter(result$hotspots,
                                                        noise),
                                   ggplot2::aes(obsTime,
                                                (..scaled.. - 2) * base10 * 0.5
                                   ),
                                   linetype = 2,
                                   col = ggplot2::alpha("black", 0.4)
    )

    p <- p + ggplot2::geom_density(data = dplyr::filter(result$hotspots,
                                                        noise),
                                   ggplot2::aes(obsTime,
                                                (-..scaled.. - 2) *
                                                  base10 *
                                                  0.5
                                   ),
                                   linetype = 2,
                                   col = ggplot2::alpha("black", 0.4)
    )
  }


  if (nrow(dplyr::filter(result$hotspots, noise)) > 0) {

    p <- p + ggplot2::geom_point(data = dplyr::filter(result$hotspots,
                                                      noise),
                                 ggplot2::aes(obsTime,
                                              membership,
                                              col = "noise"),
                                 alpha = c(0.4, 0.2)[c(noise_num <=50,
                                                       noise_num > 50)],
                                 size = 1)
  }



  p <- p + ggplot2::theme_light(base_size = 9) +
    ggplot2::theme(axis.ticks.y = ggplot2::element_blank(),
                   legend.position = "none") +
    ggplot2::scale_y_continuous(breaks = y_values,
                                labels = y_labs,
                                minor_breaks = NULL,
                                expand = c(0, base10 * 0.5)) +
    ggplot2::scale_color_brewer(palette = "Dark2")


  args_list <- list()
  if (!is.null(mainBreak)) args_list[['date_breaks']] <- mainBreak
  if (!is.null(minorBreak)) args_list['date_minor_breaks'] <- minorBreak
  if (!is.null(dateLabel)) args_list[['date_labels']] <- dateLabel

  if (("Date" %in% class(result$hotspots$obsTime)) & (length(args_list) > 0)) {

    p <- p + do.call(ggplot2::scale_x_date, args_list)

  } else {

    p <- p + do.call(ggplot2::scale_x_datetime, args_list)

  }

  # add title
  title <- paste("Fires Selected:", nrow(result$ignition), "\n")
  left <- min(result$hotspots$obsTime)
  right <- max(result$hotspots$obsTime)

  if (!is.null(from)) left <- from
  title <- paste0(title, "From: ", left, "\n")

  if (!is.null(to)) right <- to
  title <- paste0(title, "To:      ", right)

  p <- p + ggplot2::labs(title = "Timeline of Fires and Noise",
                         subtitle = title,
                         y = "Fire ID",
                         x = "",
                         col = "")

  p <- ggExtra::ggMarginal(p,
                           groupColour = TRUE,
                           groupFill = TRUE,
                           margins = c("x"))

  p
}
