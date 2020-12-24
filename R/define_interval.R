define_interval <- function(time_id, t, ActiveTime){
  left <- max(1, t - ActiveTime)
  right <- t
  indexes <- (time_id >= left) & (time_id <= right)
  if (sum(indexes) == 0) return(NULL)
  which(indexes)
}
