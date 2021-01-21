get_fire_mov <- function(result, cluster, step = 1, method = "mean"){

  # check class
  if (!"spotoroo" %in% class(result)) {
    stop('Needs a "spotoroo" object as input.')
  }

  # safety check
  is_length_one_bundle(cluster, method, step)
  check_type("numeric", cluster, step)
  check_type("character", method)
  step <- round(step)
  is_positive(step)

  # if cluster does not exist
  if (cluster > max(result$hotspots$membership)) {
    stop(paste("Cluster", cluster, "does not exist!"))
  }

  # extract hotspots from this cluster
  indexes <- result$hotspots$membership == cluster
  all_hotspots <- result$hotspots[indexes, ]

  # init vectors
  fin_lon <- result$ignition$lon[result$ignition$membership == cluster]
  fin_lat <- result$ignition$lat[result$ignition$membership == cluster]
  fin_obsTime <- result$ignition$obsTime[result$ignition$membership == cluster]
  fin_timeID <- result$ignition$timeID[result$ignition$membership == cluster]
  fin_ignition <- TRUE
  j <- 0
  temp_lon <- c()
  temp_lat <- c()

  # for each time ID
  if (min(all_hotspots$timeID) + 1 <= max(all_hotspots$timeID)) {
    for (i in (min(all_hotspots$timeID) + 1):max(all_hotspots$timeID)) {

      j <- j + 1

      # if no hotspots in this time ID
      if (sum(all_hotspots$timeID == i) == 0) next

      # extract hotspots in this time ID
      current_hotspots <- all_hotspots[all_hotspots$timeID == i, ]

      temp_lon <- c(temp_lon, current_hotspots$lon)
      temp_lat <- c(temp_lat, current_hotspots$lat)

      if (j >= step) {

        j <- 0

        # calc centroid lon and lat
        if (method == "mean") {
          fin_lon <- c(fin_lon, mean(temp_lon))
          fin_lat <- c(fin_lat, mean(temp_lat))
        }

        if (method == "median") {
          fin_lon <- c(fin_lon, stats::median(temp_lon))
          fin_lat <- c(fin_lat, stats::median(temp_lat))
        }

        # append obsTime and timeID
        fin_obsTime <- c(fin_obsTime, max(current_hotspots$obsTime))
        fin_timeID <- c(fin_timeID, i)
        fin_ignition <- c(fin_ignition, FALSE)

        temp_lon <- c()
        temp_lat <- c()
      }



    }
  }


  # bind output
  fin_data_set <- data.frame(membership = cluster,
                             lon = fin_lon,
                             lat = fin_lat,
                             timeID = fin_timeID,
                             obsTime = fin_obsTime,
                             ignition = fin_ignition)

  # return output
  fin_data_set
}
