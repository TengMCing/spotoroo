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

  # define ggplot function
  aes <- ggplot2::aes
  geom_point <- ggplot2::geom_point
  geom_path <- ggplot2::geom_path
  theme <- ggplot2::theme
  ggplot <- ggplot2::ggplot
  theme_light <- ggplot2::theme_light
  element_blank <- ggplot2::element_blank
  geom_text <- ggplot2::geom_text
  unit <- ggplot2::unit
  labs <- ggplot2::labs
  scale_color_brewer <- ggplot2::scale_color_brewer

  #define dplyr function
  mutate <- dplyr::mutate
  filter <- dplyr::filter
  bind_rows <- dplyr::bind_rows
  group_by <- dplyr::group_by
  `%>%` <- dplyr::`%>%`



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
      fire_mov_record <- bind_rows(fire_mov_record, temp_data)
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

  # set theme
  p <- ggplot() +
    theme_light(base_size = 9) +
    theme(axis.line = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          axis.title = element_blank(),
          panel.background = element_blank(),
          panel.grid = element_blank(),
          panel.spacing = unit(0, "lines"),
          plot.background = element_blank(),
          legend.justification = c(0, 0),
          legend.position = "none")


  # draw hotspots
  if (hotspot) {

    mutate(filter(result$hotspots, !noise),
           lon_jit = jitter(lon, factor = 1),
           lat_jit = jitter(lat, factor = 1)) -> temp_data

    # color if less than 10
    if (length(unique(temp_data$membership)) <= 9) {

      p <- p + geom_point(data = temp_data,
                          aes(lon_jit,
                              lat_jit,
                              col = as.character(membership)),
                          alpha = 0.2) +
        theme(legend.position = "none") +
        scale_color_brewer(palette = "Set1")

    } else {

      p <- p + geom_point(data = temp_data,
                          aes(lon_jit,
                              lat_jit),
                          col = "black",
                          alpha = 0.2)
    }

    rm(temp_data)

  }


  # draw fire mov
  # draw start point
  temp_data <- group_by(fire_mov_record, membership) %>%
    filter(timeID == min(timeID))

  p <- p + geom_point(data = temp_data,
                      aes(lon, lat),
                      col = "black",
                      shape = 21,
                      size = 3
                      )
  rm(temp_data)

  # draw line
  data2 <- group_by(fire_mov_record, membership) %>%
    mutate(mov_count = dplyr::n()) %>%
    filter(mov_count > 1)

  if (nrow(data2) > 0) {
    p <- p + geom_path(data = data2,
                       aes(lon, lat),
                       col = "blue",
                       linetype = 2)
  }

  # draw end point
  temp_data <- group_by(fire_mov_record, membership) %>%
    filter(timeID == max(timeID))

  p <- p + geom_point(data = temp_data,
                      aes(lon, lat),
                      col = "black",
                      shape = 24,
                      size = 2.5)
  rm(temp_data)


  # facet
  p <- p + ggplot2::facet_wrap(~membership,
                        scales = "free")


  # add title
  subtitle <- paste("Fires Selected:", nrow(result$ignition), "\n")
  left <- min(result$hotspots$obsTime)
  right <- max(result$hotspots$obsTime)

  if (!is.null(from)) left <- from
  subtitle <- paste0(subtitle, "From: ", left, "\n")

  if (!is.null(to)) right <- to
  subtitle <- paste0(subtitle, "To:      ", right)

  # add left plot
  if (ggplot2::is.ggplot(bg)) {
    if (length(unique(result$hotspots$membership)) <= 10) {

      bg <- bg + geom_point(data = filter(result$hotspots,
                                          !noise),
                            aes(lon,
                                lat,
                                col = as.character(membership)),
                            alpha = 0.2)
    } else {

      bg <- bg + geom_point(data = filter(result$hotspots,
                                          !noise),
                            aes(lon,
                                lat),
                            col = "black",
                            alpha = 0.2)
    }

    bg <- bg + ggrepel::geom_text_repel(data = result$ignition,
                                        aes(lon,
                                            lat,
                                            label = membership)) +
      labs(title = bquote(Fire~Movement~(Delta:Start*" | "*Omicron:End)),
           subtitle = subtitle,
           col = "") +
      theme(legend.position = "none") +
      scale_color_brewer(palette = "Set1")

    p <- patchwork:::`|.ggplot`(bg, p)

  } else {

    p <- p + labs(title = "Fire Movement (Rectangle: Start point | Triangle: End Point)",
                  subtitle = subtitle)

  }

  p


}
