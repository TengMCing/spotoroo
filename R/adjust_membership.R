#' Adjust membership labels
#'
#' Assign successive membership labels. Membership labels will start from
#' \deqn{max_membership + 1}
#'
#' @param membership numeric; a vector of membership labels.
#' @param max_membership integer; previous maximum membership label.
#' @return integer; a vector of adjusted membership labels.
#' @examples
#' membership <- c(2,3,5,2,3)
#'
#' adjust_membership(membership, 2)
#'
#' @noRd
adjust_membership <- function(membership, max_membership) {
  as.numeric(factor(membership)) + max_membership
}

