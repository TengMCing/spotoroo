#' Adjust membership labels
#'
#' Assign successive memberships. Membership labels will start from
#' \deqn{max_memberships + 1}
#'
#' @param memberships numeric; a vector of membership labels.
#' @param max_membership integer; previous maximum membership label.
#' @return a vector of adjusted membership labels.
#' @examples
#' memberships <- c(2,3,5,2,3)
#'
#' adjust_memberships(memberships, 2)
#'
#' # 3 4 5 3 4
#' @noRd
adjust_memberships <- function(memberships, max_membership) {

  as.numeric(factor(memberships)) + max_membership
}
