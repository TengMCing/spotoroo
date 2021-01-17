#' Handle columns of the main data set
#'
#' Handle columns of the main data set. Check relevant columns and transform
#' time column.
#'
#' @param lon numeric; a vector of longitude value.
#' @param lat numeric; a vector of latitude value.
#' @param obsTime numeric; a vector of observed time.
#' @param timeUnit character; one of "s" (seconds), "m" (minutes), "h" (hours),
#'                 "d" (days) and "n" (numeric).
#' @param timeStep numeric; how many units of timeUnit as a time step.
#' @return integer; a vector of time indexes.
#' @noRd
handle_hotspots_col <- function(lon, lat, obsTime, timeUnit, timeStep) {

  timeID <- obsTime

  # safe checks
  is_not_null_bundle(lon, lat, obsTime)
  if (!all_null_bool(timeUnit, timeStep)) {
    any_null_warning(timeUnit, timeStep)
  }


  if (!any_null_bool(timeUnit, timeStep)) {
    check_type("character", timeUnit)
    check_type("numeric", timeStep)
    is_positive(timeStep)
    check_in(c("s", "m", "h", "d", "n"), timeUnit)

    # transform time col
    timeID <- transform_time_id(obsTime, timeUnit, timeStep)
  }

  equal_length(lon, lat, obsTime)
  check_numeric_column_bundle(lon, lat)
  check_integer_timeID(timeID)

  return(timeID)

}
