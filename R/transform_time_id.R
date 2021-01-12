#' Transform observed time to time indexes
#'
#' Transform observed time to time indexes.
#'
#' The earliest observed time has a corresponding time index \code{1}. The
#' difference between any time to the earliest observed time will be transformed
#' using the given time unit and divided by the given time step. The final
#' indexes will be floored to integer.
#'
#' @param obsTime date/numeric; a vector of observed time of hotspots. If
#'                              \code{timeUnit} = \code{"n"}, \code{obsTime}
#'                              can be a numeric vector, otherwise, it needs
#'                              to be in date time format.
#' @param timeUnit character; the unit of time, one of "s" (secs), "m"(mins),
#'                            "h"(hours), "d"(days) and "n"(numeric).
#' @param timeStep numeric (>0); the number of units of timeUnit as a time
#'                               step.
#' @return integer; a vector of time indexes.
#' @examples
#' obsTime <- as.Date(c("2020-01-01",
#'                      "2020-01-02",
#'                      "2020-01-04"))
#'
#' transform_time_id(obsTime, "h", 1)
#'
#' # 1 25 73
#' @export
transform_time_id <- function(obsTime, timeUnit, timeStep) {

  tb <- list(s = "secs", m = "mins", h = "hours", d = "days", n = "numeric")
  timeUnit <- tb[[timeUnit]]

  if (timeUnit == "numeric") {
    if (!is.numeric(obsTime)) stop("Require numeric obsTime")
    min_time <- min(obsTime)
    timeID <- obsTime - min_time
    timeID <- timeID %/% timeStep
    timeID <- as.integer(timeID) + 1L
  } else {

    timeID <- difftime(obsTime, min(obsTime), units = timeUnit) / timeStep
    timeID <- as.integer(floor(as.numeric(timeID))) + 1L
  }

  cli::cli_alert_success("Transform timeID")

  timeID
}


