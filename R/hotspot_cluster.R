#' @export
hotspot_cluster <- function(hotspots,
                            lon = "lon",
                            lat = "lat",
                            obstime = "obstime",
                            ActiveTime = 24,
                            AdjDist = 3000,
                            ignition_center = "mean",
                            time_unit = NULL,
                            timestep = NULL){

  if (!is.list(hotspots)) stop("Object hotspots is not a list or a dataframe")
  if (!is.character(lon)) stop("Argument lon is not a string")
  if (!is.character(lat)) stop("Argument lat is not a string")
  if (!is.character(obstime)) stop("Argument obstime is not a string")

  lon <- hotspots[[lon]]
  lat <- hotspots[[lat]]
  obstime <- hotspots[[obstime]]

  time_id <- obstime

  if (is.null(lon)) stop(paste0("Can't find ", lon, " in object hotspots"))
  if (is.null(lat)) stop(paste0("Can't find ", lat, " in object hotspots"))
  if (is.null(obstime)) stop(paste0("Can't find ", obstime, " in object hotspots"))

  if (ActiveTime < 0) stop("Require non-negative ActiveTime")
  if (AdjDist <= 0) stop("Require positive AdjDist")

  if ((!is.null(time_unit)) | (!is.null(timestep))){
    if (is.null(time_unit)) warning("Missing argument time_unit, ignore argument timestep")
    if (is.null(timestep)) warning("Missing argument timestep, ignore argument time_unit")
  }

  if ((!is.null(time_unit)) & (!is.null(timestep))){
    if (!is.character(time_unit)) stop("Argument time_unit is not a string")
    if (!is.numeric(timestep)) stop("Require numeric timestep")
    if (timestep <= 0) stop("Require positive timestep")

    time_options <- c("secs", "mins", "hours", "days", "numeric")
    if (!time_unit %in% time_options) {
      stop(paste0("Argument time_unit is not one of ",
                  paste0("'", time_options, "'", collapse = ", "), collapse = " "))
    }

    time_id <- transform_time_id(obstime, time_unit, timestep)
  }


  if ((length(lon) != length(lat)) | (length(lat)!= length(obstime))){
    stop("Require equal length of lon, lat and obstime")
  }

  if (!(length(lon)>0 & is.numeric(lon))) stop("Require numeric lon")
  if (!(length(lat)>0 & is.numeric(lat))) stop("Require numeric lat")
  if (!(length(time_id)>0 & is.numeric(time_id))) stop("Require numeric time_id")
  if (!ignition_center %in% c("mean", "median")){
    stop("Argument ignition_center is neither 'mean' nor 'median'")
  }

  start_time <- Sys.time()

  global_memberships <- global_clustering(lon, lat, time_id, ActiveTime, AdjDist, ignition_center)
  ignitions <- ignition_points(lon, lat, obstime, global_memberships, ignition_center)

  results <- list(hotspots = data.frame(lon, lat, obstime, memberships = global_memberships),
                  ignitions = ignitions)



  end_time <- Sys.time()
  time_taken <- end_time - start_time

  cat(paste0("Number of clusters: ", max(global_memberships), "\n"))

  cat(paste0("Time taken: ",
             as.numeric(time_taken, units = "secs") %/% 60,
             " mins ",
             round(as.numeric(time_taken, units = "secs") %% 60, 0),
             " secs for ",
             length(lon),
             " obs "
  )
  )

  cat(paste0("(",
             round(as.numeric(time_taken, units = "secs")/length(lon), 3),
             " secs/obs)\n"))



  return(results)

}

