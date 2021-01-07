handle_hotspots_cols <- function(lon, lat, obsTime, timeUnit, timeStep){

  timeID <- obsTime

  is_null_bundle(lon, lat, obsTime)
  any_null_warning(timeUnit, timeStep)

  if (!all_null_bool(timeUnit, timeStep)) {
    check_type("character", timeUnit)
    check_type("numeric", timeStep)
    is_positive(timeStep)
    check_in(c("secs", "mins", "hours", "days", "numeric"), timeUnit)
    timeID <- transform_timeID(obsTime, timeUnit, timeStep)
  }

  equal_length(lon, lat, obsTime)
  check_numeric_column_bundle(lon, lat)
  check_integer_timeID(timeID)

  return(timeID)

}
