#' @export
plot_fire_mov <- function(result,
                          cluster = "all",
                          hotspot = TRUE,
                          from = NULL,
                          to = NULL,
                          step = 1,
                          bg = NULL) {

  if (!"spotoroo" %in% class(result)) {
    stop('Needs a "spotoroo" object as input.')
  }

  # safety check
  check_type_bundle("logical", hotspot)
  is_length_one_bundle(hotspot)


  # extract corresponding clusters
  if (!identical("all", cluster)){
    check_type("numeric", cluster)

    if (length(cluster) == 0) stop("Please provide valid membership labels.")

    indexes <- result$ignition$membership %in% cluster
    result$ignition <- result$ignition[indexes, ]

    indexes <- result$hotspots$membership %in% c(cluster, -1)
    result$hotspots <- result$hotspots[indexes, ]
  }


  # if plot all clusters
  if (identical("all", cluster)) {
    cluster <- 1:max(result$hotspots$membership)
  }

  # get fire mov
  fire_mov_record <- NULL

  for (i in cluster) {
    temp_data <- get_fire_mov(result, i, step)

    if (is.null(fire_mov_record)) {
      fire_mov_record <- temp_data
    } else {
      fire_mov_record <- dplyr::bind_rows(fire_mov_record, temp_data)
    }

  }


  # from date
  if (!is.null(from)) {
    is_length_one(from)

    indexes <- result$hotspots$obsTime >= from
    result$hotspots <- result$hotspots[indexes, ]

    indexes <- fire_mov_record$obsTime >= from
    fire_mov_record <- fire_mov_record[indexes, ]

    if (nrow(fire_mov_record) == 0) {
      stop(paste("No fire movement observed later than", from))
    }
  }

  # to date
  if (!is.null(to)) {
    is_length_one(to)

    indexes <- result$hotspots$obsTime <= to
    result$hotspots <- result$hotspots[indexes, ]

    indexes <- fire_mov_record$obsTime <= to
    fire_mov_record <- fire_mov_record[indexes, ]

    if (nrow(fire_mov_record) == 0) {
      stop(paste("No fire movement observed ealier than", to))
    }
  }


  p <- ggplot2::ggplot() + ggplot2::theme_light(base_size = 9) +
    ggplot2::theme(axis.line = element_blank(),
                   axis.text = element_blank(),
                   axis.ticks = element_blank(),
                   axis.title = element_blank(),
                   panel.background = element_blank(),
                   panel.grid = element_blank(),
                   panel.spacing = unit(0, "lines"),
                   plot.background = element_blank(),
                   legend.justification = c(0, 0),
                   legend.position = "right")


  # draw hotspots
  if (hotspot) {

    dplyr::mutate(dplyr::filter(result$hotspots, !noise),
                  lon_jit = jitter(lon, factor = 1),
                  lat_jit = jitter(lat, factor = 1)) -> temp_data

    if (length(unique(temp_data$membership)) <= 9) {
      p <- p + ggplot2::geom_point(data = temp_data,
                                   ggplot2::aes(lon_jit,
                                                lat_jit,
                                                col = as.character(membership)),
                                   alpha = 0.2) +
        ggplot2::theme(legend.position = "none") +
        ggplot2::scale_color_brewer(palette = "Set1")
    } else {
      p <- p + ggplot2::geom_point(data = temp_data,
                                   ggplot2::aes(lon_jit,
                                                lat_jit),
                                   col = "black",
                                   alpha = 0.2)
    }



    rm(temp_data)

  }


  # draw fire mov and path
  temp_data <- dplyr::group_by(fire_mov_record, membership)
  temp_data <- dplyr::filter(temp_data, timeID == min(timeID))
  p <- p + ggplot2::geom_text(data = temp_data,
                               ggplot2::aes(lon, lat, label = "F"),
                               col = "black")
  rm(temp_data)

  data2 <- dplyr::filter(dplyr::mutate(dplyr::group_by(fire_mov_record,
                                                       membership),
                                       mov_count = dplyr::n()),
                         mov_count > 1)

  if (nrow(data2) > 0) {
    p <- p + ggplot2::geom_path(data = data2,
                                ggplot2::aes(lon, lat),
                                col = "blue",
                                linetype = 2)
  }

  temp_data <- dplyr::group_by(fire_mov_record, membership)
  temp_data <- dplyr::filter(temp_data, timeID == max(timeID))
  p <- p + ggplot2::geom_text(data = temp_data,
                              ggplot2::aes(lon, lat, label = "T"),
                              col = "black")
  rm(temp_data)


  # facet
  p <- p + ggplot2::facet_wrap(~membership,
                        scales = "free") +
    ggplot2::labs(col = "", x = "lon", y = "lat")


  # add title
  title <- paste("Fires Selected:", nrow(result$ignition), "\n")
  left <- min(result$hotspots$obsTime)
  right <- max(result$hotspots$obsTime)

  if (!is.null(from)) left <- from
  title <- paste0(title, "From: ", left, "\n")

  if (!is.null(to)) right <- to
  title <- paste0(title, "To:      ", right)

  if (ggplot2::is.ggplot(bg)) {
    if (length(unique(result$hotspots$membership)) <= 10) {
      bg <- bg + ggplot2::geom_point(data = dplyr::filter(result$hotspots,
                                                          !noise),
                                     ggplot2::aes(lon,
                                                  lat,
                                                  col = as.character(membership)),
                                     alpha = 0.2)
    } else {
      bg <- bg + ggplot2::geom_point(data = dplyr::filter(result$hotspots,
                                                          !noise),
                                     ggplot2::aes(lon,
                                                  lat),
                                     col = "black",
                                     alpha = 0.2)
    }

    bg <- bg + ggrepel::geom_text_repel(data = result$ignition,
                                        ggplot2::aes(lon,
                                                     lat,
                                                     label = membership)) +
      ggplot2::labs(title = "Fire Movement",
                    subtitle = title,
                    col = "") +
      ggplot2::theme(legend.position = "none") +
      ggplot2::scale_color_brewer(palette = "Set1")
    p <- patchwork:::`|.ggplot`(bg, p)
  } else {
    p <- p + ggplot2::labs(title = "Fire Movement",
                           subtitle = title)
  }

  p


}
