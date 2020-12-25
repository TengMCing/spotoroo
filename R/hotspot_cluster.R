#' @export
hotspot_cluster <- function(hotspots,
                            lon = "lon",
                            lat = "lat",
                            time_id = "time_id",
                            ActiveTime = 24,
                            AdjDist = 3000,
                            ignition_center = "mean",
                            time_unit = NULL,
                            interval = NULL){

  if (!is.list(hotspots)) stop("Object hotspots is not a list or a dataframe")
  if (!is.character(lon)) stop("Argument lon is not a string")
  if (!is.character(lat)) stop("Argument lat is not a string")
  if (!is.character(time_id)) stop("Argument time_id is not a string")

  lon <- hotspots[[lon]]
  lat <- hotspots[[lat]]
  time_id <- hotspots[[time_id]]

  if (is.null(lon)) stop(paste0("Can't find ", lon, " in object hotspots"))
  if (is.null(lat)) stop(paste0("Can't find ", lat, " in object hotspots"))
  if (is.null(time_id)) stop(paste0("Can't find ", time_id, " in object hotspots"))

  if (ActiveTime < 0) stop("Require non-negative ActiveTime")
  if (AdjDist <= 0) stop("Require positive AdjDist")

  if ((!is.null(time_unit)) | (!is.null(interval))){
    if (is.null(time_unit)) warning("Missing argument time_unit, ignore argument interval")
    if (is.null(interval)) warning("Missing argument interval, ignore argument time_unit")
  }

  if ((!is.null(time_unit)) & (!is.null(interval))){
    if (!is.character(time_unit)) stop("Argument time_unit is not a string")
    if (!is.numeric(interval)) stop("Require numeric interval")
    if (interval <= 0) stop("Require positive interval")

    time_options <- c("secs", "mins", "hours", "days", "weeks", "months", "years")
    if (!time_unit %in% time_options) {
      stop(paste0("Argument time_unit is not one of ",
                  paste0("'", time_options, "'", collapse = ", "), collapse = " "))
    }

    time_id <- transform_time_id(time_id, time_unit, interval)
  }


  if ((length(lon) != length(lat)) | (length(lat)!= length(time_id))){
    stop("Require equal length of lon, lat and time_id")
  }

  if (!(length(lon)>0 & is.numeric(lon))) stop("Require numeric lon")
  if (!(length(lat)>0 & is.numeric(lat))) stop("Require numeric lat")
  if (!(length(time_id)>0 & is.numeric(time_id))) stop("Require numeric time_id")
  if (!ignition_center %in% c("mean", "median")){
    stop("Argument ignition_center is neither 'mean' nor 'median'")
  }

  global_clustering(lon, lat, time_id, ActiveTime, AdjDist, ignition_center)

}
