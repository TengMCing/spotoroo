plot_fire_mov <- function(result,
                          cluster = "all",
                          hotspot = TRUE,
                          noise = FALSE,
                          from = NULL,
                          to = NULL,
                          bg = NULL) {

  if (!"spotoroo" %in% class(result)) {
    stop('Needs a "spotoroo" object as input.')
  }

  # safety check
  check_type_bundle("logical", hotspot, noise)
  is_length_one_bundle(hotspot, noise)

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
    temp_data <- get_fire_mov(result, i)

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

  fire_mov_record$type <- "fire movement"
  fire_mov_record$type[fire_mov_record$ignition] <- "ignition"


  # draw fire mov
  p <- p + ggplot2::geom_point(data = fire_mov_record,
                               ggplot2::aes(lon, lat, col = type))


  # add path
  data2 <- dplyr::filter(dplyr::mutate(dplyr::group_by(fire_mov_record,
                                                       membership),
                                       mov_count = n()),
                         mov_count > 1)

  if (nrow(data2) > 0) {
    p <- p +     ggplot2::geom_path(data = data2,
                                    ggplot2::aes(lon, lat, col = "fire movement"))
  }


  # facet
  p <- p + ggplot2::facet_wrap(~membership,
                        scales = "free") +
    ggplot2::labs(col = "", x = "lon", y = "lat")


  # add title
  title <- ""

  if (!is.null(from)) {
    title <- paste("From:", from, " ")
  }

  if (!is.null(to)) {
    title <- paste("To:", to)
  }

  if ((!is.null(from)) | (!is.null(to))) {
    p <- p + ggplot2::labs(subtitle = title)
  }



  p


}
