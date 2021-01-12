hotspots_to_ignitions <- function(lon, lat, timeID, memberships, ignitions) {

  fin_vec <- rep(0, length(lon))
  time_vec <- rep(0, length(lon))

  for (i in 1:max(memberships)){
    indexes <- memberships == i
    vlon <- lon[indexes]
    vlat <- lat[indexes]

    indexes2 <- ignitions$memberships == i
    plon <- ignitions$lon[indexes2]
    plat <- ignitions$lat[indexes2]

    dist_vec <- dist_point_to_vector(plon, plat, vlon, vlat)
    fin_vec[indexes] <- dist_vec

    time_vec[indexes] <- timeID[indexes] - ignitions$timeID[indexes2]

  }

  list(fin_vec = fin_vec, time_vec = time_vec)
}
