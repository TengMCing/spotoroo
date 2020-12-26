#' Define the interval for the current timestamp
#'
#' Define the interval for the current timestamp.
#' The interval is defined as \deqn{[max(1, t - ActiveTime),t]}
#'
#' @param time_id The time indexes which is an integer vector.
#' @param t The current timestamp which is an integer number
#' @param ActiveTime The
#' @return The indexes of the time index which is in the defined interval. An integer vector.
#' @examples
#' time_id <- c(4, 4, 5, 9, 12, 22)
#' define_interval(time_id, t = 30, ActiveTime = 24)
#' # 4 5 6
#' @noRd
define_interval <- function(time_id, t, ActiveTime){
  left <- max(1, t - ActiveTime)
  right <- t
  indexes <- (time_id >= left) & (time_id <= right)
  if (sum(indexes) == 0) return(NULL)
  which(indexes)
}
