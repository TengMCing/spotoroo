global_clustering <- function(lon, lat, timeID, activeTime, adjDist) {

  global_memberships <- rep(0, length(lon))

  barstr <- "Clustering [:bar] :current/:total (:percent) eta: :eta"

  pb <- progress::progress_bar$new(format = barstr,
                                   total = max(timeID))
  pb$tick(0)

  for (t in 1:max(timeID)) {

    pb$tick(1)

    indexes <- define_interval(timeID, t, activeTime)

    if (is.null(indexes)) next
    if (all(global_memberships[indexes] != 0)) next

    local_memberships <- local_clustering(lon[indexes], lat[indexes], adjDist)
    global_memberships <-  update_memberships(lon,
                                              lat,
                                              global_memberships,
                                              local_memberships,
                                              indexes)
  }

  cat("Clustering \u2713 \n")

  global_memberships


}
