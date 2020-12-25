global_clustering <- function(lon, lat, time_id, ActiveTime, AdjDist, ignition_center){

  global_memberships <- rep(0, length(lon))

  start_time <- Sys.time()

  pb <- progress::progress_bar$new(format = "Clustering [:bar] :current/:total (:percent) eta: :eta",
                                   total = max(time_id))
  pb$tick(0)

  for (t in 1:max(time_id)){

    pb$tick(1)

    indexes <- define_interval(time_id, t, ActiveTime)

    if (is.null(indexes)) next
    if (all(global_memberships[indexes] != 0)) next

    local_memberships <- local_clustering(lon[indexes], lat[indexes], AdjDist)
    global_memberships <-  update_memberships(lon,
                                              lat,
                                              global_memberships,
                                              local_memberships,
                                              indexes)
  }

  cat("Clustering \u2713 \n")

  results <- ignition_points(lon, lat, time_id, global_memberships, ignition_center)
  results$memberships <- global_memberships

  end_time <- Sys.time()
  time_taken <- end_time - start_time
  cat(paste0("Time taken: ",
                 as.numeric(time_taken, units = "secs") %/% 60,
                 " mins ",
                 round(as.numeric(time_taken, units = "secs") %% 60, 0),
                 " secs for ",
                 length(lon),
                 " observations\n"
  )
  )

  cat(paste0("(",
                 round(as.numeric(time_taken, units = "secs")/length(lon), 3),
                 " secs/obs)\n"))



  return(results)
}
