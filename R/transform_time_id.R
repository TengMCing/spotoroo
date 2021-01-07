transform_timeID <- function(timeID, timeUnit, timeStep){

  if (timeUnit == "numeric") {
    if (!is.numeric(timeID)) stop("Require numeric timeID")
    min_time <- min(timeID)
    timeID <- timeID - min_time
    timeID <- timeID %/% timeStep
    timeID <- as.integer(timeID) + 1L
  } else {

    timeID <- difftime(timeID, min(timeID), units = timeUnit) / timeStep
    timeID <- as.integer(round(as.numeric(timeID))) + 1L
  }

  cat("Transform timeID \u2713 \n")

  timeID
}


