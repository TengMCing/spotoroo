global_clustering <- function(lon, lat, time_id, ActiveTime, AdjDist, ignition_center){

  global_memberships <- rep(0, length(lon))

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

  global_memberships


}
