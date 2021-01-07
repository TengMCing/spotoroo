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
    timeID <- as.integer(round(as.numeric(timeID))) + 1L
  }

  cat("Transform timeID \u2713 \n")

  timeID
}


