#' Define the interval for the current timestamp
#'
#' Define the interval for the current timestamp.
#' The interval is defined as \deqn{[max(1, t - activeTime),t]}
#'
#' @param timeID The time indexes which is an integer vector.
#' @param t The current timestamp which is an integer number
#' @param activeTime The
#' @return The indexes of the time index which is in the defined interval. An integer vector.
#' @examples
#' timeID <- c(4, 4, 5, 9, 12, 22)
#' define_interval(timeID, t = 30, activeTime = 24)
#' # 4 5 6
#' @noRd
define_interval <- function(timeID, t, activeTime) {
  left <- max(1, t - activeTime)
  right <- t
  indexes <- (timeID >= left) & (timeID <= right)
  if (sum(indexes) == 0) return(NULL)
  which(indexes)
}
