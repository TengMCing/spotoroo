dist_point_to_vector <- function(plon, plat, vlon, vlat){

  dist_mat <- suppressMessages(geodist::geodist_vec(plon, plat, vlon, vlat))
  as.vector(dist_mat)
}
