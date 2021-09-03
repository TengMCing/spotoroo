#' Summarizing spatiotemporal clustering results
#'
#' This function takes a `spotoroo` object to produce a summary of the
#' clustering results. It can be called by [summary.spotoroo()].
#'
#' @param result `spotoroo` object.
#' A result of a call to [hotspot_cluster()].
#' @param cluster Character/Integer. If "all", summarize all clusters.
#'                If an integer vector is given, summarize corresponding
#'                clusters.
#' @return No return value, called for side effects
#' @examples
#' \donttest{
#'
#'   # Time consuming functions (>5 seconds)
#'
#'
#'   # Get clustering results
#'   result <- hotspot_cluster(hotspots,
#'                            lon = "lon",
#'                            lat = "lat",
#'                            obsTime = "obsTime",
#'                            activeTime = 24,
#'                            adjDist = 3000,
#'                            minPts = 4,
#'                            minTime = 3,
#'                            ignitionCenter = "mean",
#'                            timeUnit = "h",
#'                            timeStep = 1)
#'
#'
#'   # Make a summary of all clusters
#'   summary_spotoroo(result)
#'
#'   # Make a summary of cluster 1 to 3
#'   summary_spotoroo(result, 1:3)
#' }
#'
#' @export
summary_spotoroo <- function(result, cluster = "all"){

  if (!"spotoroo" %in% class(result)) {
    stop('Needs a "spotoroo" object as input.')
  }


  if (!identical(cluster, "all")) {
    check_type("numeric", cluster)
    if (length(cluster) == 0) stop("Please provide valid membership labels.")
    if (any(!cluster %in% unique(result$ignition$membership))) {
      stop("Please provide valid membership labels.")}

    indexes <- result$ignition$membership %in% cluster
    result$ignition <- result$ignition[indexes, ]


    indexes <- result$hotspots$membership %in% c(cluster, -1)
    result$hotspots <- result$hotspots[indexes, ]
  }


  num_cluster <- nrow(result$ignition)
  num_hotspots <- sum(!result$hotspots$noise)
  num_noise <- sum(result$hotspots$noise)
  per_noise <- num_noise / (num_hotspots + num_noise) * 100
  from <- min(result$hotspots$obsTime)
  to <- max(result$hotspots$obsTime)
  cli::cli_div(theme = list(rule = list("font-weight" = "bold",
                                        "margin-top" = 1,
                                        "margin-bottom" = 0,
                                        color = "cyan",
                                        "font-color" = "black"),
                            span.unit = list(color = "magenta"),
                            span.type = list(color = "red",
                                             `text-decoration` = "underline",
                                             `font-style` = "italic",
                                             `font-weight` = "bold"),
                            span.bi = list(`font-weight` = "bold"),
                            span.summary = list(color = "#a63603",
                                                `font-weight` = "bold"),
                            .val = list(digits = 2,
                                        `font-weight` = "bold")))

  cli::cli_rule(center = "{.def SPOTOROO 0.1.2}")
  cli::cli_h2("Calling Core Function : {.fn summary_spotoroo}")
  cluster_str <- as.character(cluster)
  if (identical(cluster_str, "all")) cluster_str <- "ALL"
  if (length(cluster_str) > 10) {
    cluster_str <- c(cluster_str[1],
                     cluster_str[2],
                     cluster_str[3],
                     "...",
                     cluster_str[length(cluster_str)-1],
                     cluster_str[length(cluster_str)])
  }
  cli::cat_line(paste("CLUSTERS:", paste(cluster_str, collapse = " ")))
  cli::cat_line(paste("OBSERVATIONS:", num_noise + num_hotspots))
  cli::cat_line(paste('FROM:',from))
  cli::cat_line(paste('TO:  ',to))
  cli::cli_text()
  cli::cli_h3("{.type Clusters}")
  cli::cli_alert_info("{.bi Number of clusters: {.val {num_cluster}}}")
  cli::cli_text()


  # first 5 summary
  cli::cli_text("{.summary Observations in cluster}")
  vals <- summary(result$ignition$obsInCluster)[-3]
  five_names <- paste(formatC(names(vals), width = 12), collapse = "")
  vals <- paste(format(as.numeric(vals),
                       digits = 1,
                       nsmall = 1,
                       width = 12),
                collapse = "")
  cli::cat_line(five_names, col = "green")
  cli::cat_line(vals, col = "blue")


  # second 5 summary
  tunit <- as.character(result$ignition$clusterTimeLenUnit[1])
  tunit <- list(d = "days",
                h = "hours",
                m = "mins",
                s = "secs",
                n = "numeric")[[tunit]]
  cli::cli_text("{.summary Duration of cluster ({.unit {tunit}})}")
  vals <- summary(as.numeric(result$ignition$clusterTimeLen))[-3]
  five_names <- paste(formatC(names(vals), width = 12), collapse = "")
  vals <- paste(format(as.numeric(vals),
                       digits = 1,
                       nsmall = 1,
                       width = 12),
                collapse = "")
  cli::cat_line(five_names, col = "green")
  cli::cat_line(vals, col = "blue")

  cli::cli_h3("{.type Hot spots (excluding noise)}")
  cli::cli_alert_info("{.bi Number of hot spots: {.val {num_hotspots}}}")
  cli::cli_text()

  # third 5 summary
  cli::cli_text("{.summary Distance to ignition points ({.unit m})}")
  vals <- summary(as.numeric(result$hotspots$distToIgnition[!result$hotspots$noise]))[-3]
  five_names <- paste(formatC(names(vals), width = 12), collapse = "")
  vals <- paste(format(as.numeric(vals),
                       digits = 1,
                       nsmall = 1,
                       width = 12),
                collapse = "")
  cli::cat_line(five_names, col = "green")
  cli::cat_line(vals, col = "blue")

  # fourth 5 summary
  tunit <- as.character(result$hotspots$timeFromIgnitionUnit[1])
  tunit <- list(d = "days",
                h = "hours",
                m = "mins",
                s = "secs",
                n = "numeric")[[tunit]]
  cli::cli_text("{.summary Time from ignition ({.unit {tunit}})}")
  vals <- summary(as.numeric(result$hotspots$timeFromIgnition[!result$hotspots$noise]))[-3]
  five_names <- paste(formatC(names(vals), width = 12), collapse = "")
  vals <- paste(format(as.numeric(vals),
                       digits = 1,
                       nsmall = 1,
                       width = 12),
                collapse = "")
  cli::cat_line(five_names, col = "green")
  cli::cat_line(vals, col = "blue")

  if (identical(cluster, "all")) {
    cli::cli_h3("{.type Noise}")
    cli::cli_alert_info("{.bi Number of noise points: {.val {num_noise}}} ({.val {per_noise} %})")
    cli::cli_text()
  }



  cli::cli_rule()
  cli::cli_end()

}

