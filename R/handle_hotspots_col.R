#' Handle columns of the main data set
#'
#' Handle columns of the main data set. Check relevant columns and transform
#' time column.
#'
#' @param lon numeric; a vector of longitude value.
#' @param lat numeric; a vector of latitude value.
#' @param obsTime date/datetime; a vector of observed time.
#' @param timeUnit character; one of "s" (seconds), "m" (minutes), "h" (hours),
#'                            "d" (days) and "n" (numeric).
#' @param timeStep numeric; how many units of timeUnit as a time step.
#' @return integer; a vector of time indexes.
#' @noRd
handle_hotspots_col <- function(lon, lat, obsTime, timeUnit, timeStep) {

  bool1 <- "Date" %in% class(obsTime)
  bool2 <- "POSIXct" %in% class(obsTime)
  bool3 <- is.numeric(obsTime)

  if (sum(bool1, bool2, bool3) == 0) {
    stop("obsTime needs to be either date, datetime or numeric.")
  }

  timeID <- obsTime

  # safety checks
  is_not_null_bundle(lon, lat, obsTime)

  # transform time col
  timeID <- transform_time_id(obsTime, timeUnit, timeStep)


  equal_length(lon, lat, obsTime, timeID)
  check_numeric_column_bundle(lon, lat)
  check_integer_timeID(timeID)

  return(timeID)

}


