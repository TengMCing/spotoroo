#' Define the interval for the current timestamp
#'
#' Define the interval for the current timestamp.
#' The interval is defined as \deqn{[max(1, t - activeTime),t]}
#'
#' @param timeID integer; a vector of the time indexes.
#' @param t integer; the current timestamp
#' @param activeTime numeric; a time parameter.
#' @return The indexes of the time index which is in the defined interval. An integer vector.
#' @examples
#' timeID <- c(4, 4, 5, 9, 12, 22)
#'
#' define_interval(timeID, 30, 24)
#'
#' @noRd
define_interval <- function(timeID, t, activeTime) {
  left <- max(1, t - activeTime)
  right <- t
  indexes <- (timeID >= left) & (timeID <= right)
  if (sum(indexes) == 0) return(NULL)
  which(indexes)
}

