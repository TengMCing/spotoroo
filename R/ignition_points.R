ignition_points <- function(lon, lat, time_id, memberships, ignition_center = "mean"){

  ignition_lon <- rep(0, max(memberships))
  ignition_lat <- rep(0, max(memberships))

  for (i in 1:max(memberships)){

    earliest_time <- min(time_id[memberships == i])
    indexes <- (time_id == earliest_time) & (memberships == i)
    if (ignition_center == "mean") {
      ignition_lon[i] <- mean(lon[indexes])
      ignition_lat[i] <- mean(lat[indexes])
    } else {
      ignition_lon[i] <- median(lon[indexes])
      ignition_lat[i] <- median(lat[indexes])
    }

  }

  cat("Compute ignition points \u2713 \n")

  list(ignition_lon = ignition_lon, ignition_lat = ignition_lat)
}
