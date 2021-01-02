handle_hotspots_cols <- function(lon, lat, obstime, time_unit, timestep){

  time_id <- obstime

  is_null_bundle(lon, lat, obstime)
  any_null_warning(time_unit, timestep)

  if (!all_null_bool(time_unit, timestep)) {
    check_type("character", time_unit)
    check_type("numeric", timestep)
    is_positive(timestep)
    check_in(c("secs", "mins", "hours", "days", "numeric"), time_unit)
    time_id <- transform_time_id(obstime, time_unit, timestep)
  }

  equal_length(lon, lat, obstime)
  check_numeric_column_bundle(lon, lat)
  check_integer_time_id(time_id)

  return(time_id)

}
