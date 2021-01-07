nearby_hotspots <- function(hotspot_list, pointer, lon, lat, adjDist){

  if (length(lon) == 1) return(NULL)

  dist_vector <- dist_point_to_vector(lon[pointer], lat[pointer], lon, lat)
  potential <- which(dist_vector <= adjDist)
  indexes <- !(potential %in% hotspot_list)

  if (sum(indexes) == 0) return(NULL)

  potential[!(potential %in% hotspot_list)]
}
