#' Plotting the fire movement
#'
#' This function plots the fire movement. The fire movement is calculated
#' from [get_fire_mov()].
#'
#' @param result `spotoroo` object; a result of a call to [hotspot_cluster()].
#' @param cluster character/integer; if "all", plot all clusters. if a integer
#'                vector is given, plot corresponding clusters.
#' @param hotspot logical; if `TRUE`, plot the hot spots.
#' @param from **OPTIONAL**; date/datetime/numeric; start time; the data type
#'                           needs to be the same as the provided observed time.
#' @param to **OPTIONAL**; date/datetime/numeric; end time; the data type
#'                         needs to be the same as the provided observed time.
#' @param step integer (>0); step size used in the calculation of the
#'                            fire movement.
#' @param bg **OPTIONAL**; `ggplot` object; if specified, plot onto this object.
#' @return `ggplot` object; the plot of the clustering results.
#' @examples
#' # get clustering results
#' result <- hotspot_cluster(hotspots,
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
#' # plot cluster 1 to 4
#' plot_fire_mov(result, cluster = 1:4)
#'
#' # plot cluster 1 to 4, set step = 6
#' plot_fire_mov(result, cluster = 1:4, step = 6)
#'
#'
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

  # define dplyr function
  mutate <- dplyr::mutate
  filter <- dplyr::filter
  bind_rows <- dplyr::bind_rows
  group_by <- dplyr::group_by
  summarise <- dplyr::summarise
  arrange <- dplyr::arrange
  desc <- dplyr::desc
  ungroup <- dplyr::ungroup
  `%>%` <- dplyr::`%>%`

  # pass CMD CHECK variables
  noise <- membership <- num <- include <- lon <- lat <- lon_jit <- lat_jit <-
    timeID <- mov_count <- obsTime <- NULL



  # safety check
  check_type_bundle("logical", hotspot)
  is_length_one_bundle(hotspot, step)


  # extract corresponding clusters
  if (!identical("all", cluster)){
    check_type("numeric", cluster)

    if (length(cluster) == 0) stop("Please provide valid membership labels.")

    indexes <- result$ignition$membership %in% cluster
    result$ignition <- result$ignition[indexes, ]

    indexes <- result$hotspots$membership %in% c(cluster, -1)
    result$hotspots <- result$hotspots[indexes, ]
  }

  # delete noise
  result$hotspots <- filter(result$hotspots, !noise)
  if (nrow(result$hotspots) == 0) {
    stop("No hot spots (exculding noise) observed.")
  }


  # if plot all clusters
  if (identical("all", cluster)) {
    cluster <- unique(result$hotspots$membership)
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
    if (nrow(result$hotspots) == 0) {
      stop(paste("No hot spots observed later than", from))
    }

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
    if (nrow(result$hotspots) == 0) {
      stop(paste("No hot spots observed ealier than", to))
    }

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

  # select the most important clusters if more than 9
  result$hotspots$include <- TRUE
  fire_mov_record$include <- TRUE

  if (length(unique(result$hotspots$membership)) > 9) {
    include_cluster <- group_by(result$hotspots, membership) %>%
      summarise(num = dplyr::n()) %>%
      arrange(desc(num))

    include_cluster <- include_cluster[['membership']]

    include_cluster <- include_cluster[1:9]

    result$hotspots <- mutate(result$hotspots,
                              include = membership %in% include_cluster)

    fire_mov_record <- mutate(fire_mov_record,
                              include = membership %in% include_cluster)
  }


  # draw hot spots
  if (hotspot) {

    temp_data <- filter(result$hotspots, include) %>%
      mutate(lon_jit = jitter(lon, factor = 1),
             lat_jit = jitter(lat, factor = 1))


    p <- p + geom_point(data = temp_data,
                        aes(lon_jit,
                            lat_jit,
                            col = as.character(membership)),
                        alpha = 0.2) +
        theme(legend.position = "none") +
        scale_color_brewer(palette = "Set1")

  }



  # plot fire movement
  # draw start point
  temp_data <- filter(fire_mov_record, include) %>%
    group_by(membership) %>%
    filter(timeID == min(timeID))

  p <- p + geom_point(data = temp_data,
                      aes(lon, lat),
                      col = "black",
                      shape = 21,
                      size = 3)

  # draw line
  temp_data <- filter(fire_mov_record, include) %>%
    group_by(membership) %>%
    mutate(mov_count = dplyr::n()) %>%
    filter(mov_count > 1) %>%
    ungroup()

  if (nrow(temp_data) > 0) {
    p <- p + geom_path(data = temp_data,
                       aes(lon, lat),
                       col = "black",
                       linetype = 2)
  }

  # draw end point
  temp_data <- filter(fire_mov_record, include) %>%
    group_by(membership) %>%
    filter(timeID == max(timeID))

  p <- p + geom_point(data = temp_data,
                      aes(lon, lat),
                      col = "black",
                      shape = 24,
                      size = 2.5)



  # facet
  p <- p + ggplot2::facet_wrap(~membership, scales = "free")


  # edit subtitle
  subtitle <- paste("Fires Selected:", length(cluster), "\n")
  if (length(unique(result$hotspots$membership)) > 9) {
    subtitle <- paste0(subtitle, "(Only display top 9 largest fires) \n")
  }
  left <- min(result$hotspots$obsTime)
  right <- max(result$hotspots$obsTime)

  if (!is.null(from)) left <- from
  subtitle <- paste0(subtitle, "From: ", left, "\n")

  if (!is.null(to)) right <- to
  subtitle <- paste0(subtitle, "To:      ", right)

  # add left plot
  if (ggplot2::is.ggplot(bg)) {

    # other clusters
    bg <- bg + geom_point(data = filter(result$hotspots, !include),
                          aes(lon, lat),
                          col = "black",
                          alpha = 0.2)

    # display clusters
    bg <- bg + geom_point(data = filter(result$hotspots, include),
                          aes(lon,
                              lat,
                              col = as.character(membership)),
                          alpha = 0.2)

    temp_data <- filter(result$hotspots, include) %>%
      group_by(membership) %>%
      filter(obsTime == min(obsTime)) %>%
      group_by(membership) %>%
      summarise(lon = dplyr::first(lon), lat = dplyr::first(lat)) %>%
      ungroup()

    # add floating text
    bg <- bg + ggrepel::geom_text_repel(data = temp_data,
                                        aes(lon,
                                            lat,
                                            label = membership))

    # add title
    bg <- bg +
      labs(title = bquote(Fire~Movement~(Delta:Start*" | "*Omicron:End)),
           subtitle = subtitle,
           col = "") +
      theme(legend.position = "none") +
      scale_color_brewer(palette = "Set1")

    p <- patchwork::wrap_plots(bg, p)

  } else {

    p <- p +
      labs(title = bquote(Fire~Movement~(Delta:Start*" | "*Omicron:End)),
           subtitle = subtitle)

  }

  p


}
