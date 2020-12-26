transform_time_id <- function(time_id, time_unit, timestep){

  if (time_unit == "numeric") {
    if (!is.numeric(time_id)) stop("Require numeric time_id")
    min_time <- min(time_id)
    time_id <- time_id - min_time
    time_id <- time_id %/% timestep
    time_id <- time_id + 1
  } else {

    time_id <- difftime(time_id, min(time_id), units = time_unit) / timestep
    time_id <- as.integer(round(as.numeric(time_id))) + 1
  }

  cat("Transform time_id \u2713 \n")

  time_id
}


