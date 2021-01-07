ignition_points <- function(lon, lat, obsTime, memberships, ignitionCenter = "mean"){

  ignition_lon <- rep(0, max(memberships))
  ignition_lat <- rep(0, max(memberships))
  ignition_obsTime <- rep(obsTime[1], max(memberships))

  for (i in 1:max(memberships)){

    earliest_time <- min(obsTime[memberships == i])
    ignition_obsTime[i] <- earliest_time
    indexes <- (obsTime == earliest_time) & (memberships == i)
    if (ignitionCenter == "mean") {
      ignition_lon[i] <- mean(lon[indexes])
      ignition_lat[i] <- mean(lat[indexes])
    } else {
      ignition_lon[i] <- median(lon[indexes])
      ignition_lat[i] <- median(lat[indexes])
    }

  }

  cat("Compute ignition points \u2713 \n")

  data.frame(ignition_lon = ignition_lon,
             ignition_lat = ignition_lat,
             ignition_obsTime = ignition_obsTime)
}
