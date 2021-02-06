#' Plotting the timeline of the fire and the noise
#'
#' `plot_timeline()` plots the timeline of the fire and the noise.
#'
#' @param result `spotoroo` object; a result of a call to [hotspot_cluster()].
#' @param from **OPTIONAL**; date/datetime/numeric; start time; the data type
#'                           needs to be the same as the provided observed time.
#' @param to **OPTIONAL**; date/datetime/numeric; end time; the data type
#'                         needs to be the same as the provided observed time.
#' @param mainBreak **OPTIONAL**; character/numeric; a string/value giving the
#'                                     distance between major breaks; if the
#'                                     observed time is in date/datetime format,
#'                                     this value will pass to
#'                                     [ggplot2::scale_x_date()] or
#'                                     [ggplot2::scale_x_datetime()] as
#'                                     `date_breaks`.
#' @param minorBreak **OPTIONAL**; character/numeric; a string/value giving the
#'                                     distance between minor breaks; if the
#'                                     observed time is in date/datetime format,
#'                                     this value will pass to
#'                                     [ggplot2::scale_x_date()] or
#'                                     [ggplot2::scale_x_datetime()] as
#'                                     `date_breaks`.
#' @param dateLabel **OPTIONAL**; character; a string giving the formatting
#'                                specification for the labels; if the observed
#'                                time is in date/datetime format,
#'                                this value will pass to
#'                                [ggplot2::scale_x_date()] or
#'                                [ggplot2::scale_x_datetime()] as
#'                                `date_labels`; unavailable if the observed
#'                                time is in numeric format.
#' @return `ggplot` object; the plot of the clustering results.
#' @examples
#' result <- hotspot_cluster(hotspots_fin,
#'                           lon = "lon",
#'                           lat = "lat",
#'                           obsTime = "obsTime",
#'                           activeTime = 24,
#'                           adjDist = 3000,
#'                           minPts = 4,
#'                           minTime = 3,
#'                           ignitionCenter = "mean",
#'                           timeUnit = "h",
#'                           timeStep = 1)
#'
#' plot_timeline(result)
#' plot_timeline(result,
#'               mainBreak = "1 week",
#'               minorBreak = "1 day",
#'               dateLabel = "%b %d")
#'
#' @export
plot_timeline <- function(result,
                          from = NULL,
                          to = NULL,
                          mainBreak = NULL,
                          minorBreak = NULL,
                          dateLabel = NULL) {

  # pass CMD CHECK variables
  noise <- membership <- obsTime <- startt <- endt <- ..scaled.. <- NULL

  if (!"spotoroo" %in% class(result)) {
    stop('Needs a "spotoroo" object as input.')
  }

  # from date
  if (!is.null(from)) {
    is_length_one(from)

    indexes <- result$hotspots$obsTime >= from
    result$hotspots <- result$hotspots[indexes, ]
    if (nrow(result$hotspots) == 0) {
      stop(paste("No hotspots/noise observed later than", from))
    }
  }

  # to date
  if (!is.null(to)) {
    is_length_one(to)

    indexes <- result$hotspots$obsTime <= to
    result$hotspots <- result$hotspots[indexes, ]
    if (nrow(result$hotspots) == 0) {
      stop(paste("No hotspots/noise observed ealier than", to))
    }
  }

  if (all(result$hotspots$membership == -1)) {
    p <- plot_timeline_only_noise(result,
                                  from,
                                  to,
                                  mainBreak,
                                  minorBreak,
                                  dateLabel)
    return(p)

  }

  max_index <- max(result$hotspots$membership)
  power10 <- trunc(log10(max_index))
  base10 <- 10^power10
  max_lab <- (max_index %/% base10 + (max_index %% base10 != 0)) * base10
  y_values <- seq(-base10, max_lab, base10)
  y_labs <- as.character(y_values)
  y_labs[1] <- "noise"

  result$hotspots$membership[result$hotspots$membership == -1] <- -base10

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


  if (noise_num > 0) {

    p <- p + ggbeeswarm::geom_quasirandom(data = dplyr::filter(result$hotspots,
                                                               noise),
                                 ggplot2::aes(obsTime,
                                              membership),
                                 col = "#d95f02",
                                 groupOnX = FALSE,
                                 width = base10/2,
                                 alpha = max(1/log(noise_num), 0.1),
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

  }

  if (("POSIXct" %in% class(result$hotspots$obsTime)) & (length(args_list) > 0)) {

    p <- p + do.call(ggplot2::scale_x_datetime, args_list)

  }

  if (is.numeric(result$hotspots$obsTime)) {

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
  title <- paste("Fires Displayed:", nrow(result$ignition), "\n")
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
