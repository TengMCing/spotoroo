fire_mov <- function(results, cluster, method = "mean"){

  if (!"spotoroo" %in% class(results)) {
    stop('Needs a "spotoroo" object as input.')
  }

  is_length_one_bundle(cluster, method)
  check_type("numeric", cluster)
  check_type("character", method)

  if (cluster > max(results$hotspots$memberships)) {
    stop(paste("Cluster", cluster, "does not exist!"))
  }

  indexes <- results$hotspots$memberships == cluster
  all_hotspots <- results$hotspots[indexes, ]

  fin_lon <- results$ignitions$lon[results$ignitions$memberships == cluster]
  fin_lat <- results$ignitions$lat[results$ignitions$memberships == cluster]

  for (i in min(all_hotspots$timeID):max(all_hotspots$timeID)) {

    if (sum(all_hotspots$timeID == i) == 0) {
      fin_lon <- c(fin_lon, NA)
      fin_lat <- c(fin_lat, NA)
      next
    }

    current_hotspots <- all_hotspots[all_hotspots$timeID == i, ]

    if (method == "mean") {
      fin_lon <- c(fin_lon, mean(current_hotspots$lon))
      fin_lat <- c(fin_lat, mean(current_hotspots$lat))
    }

    if (method == "median") {
      fin_lon <- c(fin_lon, stats::median(current_hotspots$lon))
      fin_lat <- c(fin_lat, stats::median(current_hotspots$lat))
    }

  }

  fin_data_set <- data.frame(memberships = cluster,
                             lon = fin_lon,
                             lat = fin_lat,
                             timeID = 1:length(fin_lon))

  fin_data_set[stats::complete.cases(fin_data_set), ]
}
