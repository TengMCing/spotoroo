#' Transforming a series of time or datetime to time indexes
#'
#' This function transforms a series of time or datetime to
#' time indexes.
#'
#' The earliest time is assigned with a time index \code{1}.
#' The difference between any other time to the earliest
#' time is transformed using the `timeUnit` and divided
#' by the `timeStep`. These differences are floored to integer and
#' used as the time indexes.
#'
#' @param obsTime date/datetime/numeric; a vector of observed time of
#' hot spots.
#'                                       If `timeUnit` is "n", `obsTime`
#'                                       needs to be a numeric vector,
#'                                       otherwise, it needs to be in
#'                                       date or datetime format.
#' @param timeUnit character; the unit of time, one of "s" (seconds),
#'                            "m"(minutes),
#'                            "h"(hours), "d"(days) and "n"(numeric).
#' @param timeStep numeric (>0); number of units of `timeUnit` in a time step.
#' @return integer; a vector of time indexes.
#' @examples
#' # define obsTime
#' obsTime <- as.Date(c("2020-01-01",
#'                      "2020-01-02",
#'                      "2020-01-04"))
#'
#' # transform it to time index under different settings
#' transform_time_id(obsTime, "h", 1)
#' transform_time_id(obsTime, "m", 60)
#' transform_time_id(obsTime, "s", 3600)
#'
#' # define numeric obsTime
#' obsTime <- c(1,
#'              1.5,
#'              4.5,
#'              6)
#'
#' # transform it to time index under different settings
#' transform_time_id(obsTime, "n", 1)
#' transform_time_id(obsTime, "n", 1.5)
#'
#'
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

  cli::cli_div(theme = list(span.vrb = list(color = "yellow",
                                            `font-weight` = "bold"),
                            span.unit = list(color = "magenta"),
                            .val = list(digits = 3),
                            span.side = list(color = "grey")))
  cli::cli_h3("{.val 1} {.unit time index} = {.val {timeStep}} {.unit {timeUnit}}")
  cli::cli_alert_success("{.vrb Transform} {.field observed time} {cli::symbol$arrow_right} {.field time indexes}")
  cli::cli_alert_info("{.val {max(timeID)}} {.unit time indexes} {.side found}")

  cli::cli_end()

  timeID
}


