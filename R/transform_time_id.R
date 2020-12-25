transform_time_id <- function(time_id, time_unit, interval){

  if (time_unit == "timestamps") {
    if (!is.numeric(time_id)) stop("Require numeric time_id")
    min_time <- min(time_id)
    time_id <- time_id - min_time
    time_id <- time_id %/% interval
    time_id <- time_id + 1
  } else {
    min_time <- min(time_id)
    time_id <- as.numeric(time_id - min_time, unit = time_unit)
    time_id <- time_id %/% interval
    time_id <- time_id + 1
  }

  time_id
}


