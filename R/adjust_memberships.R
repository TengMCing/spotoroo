adjust_memberships <- function(memberships, max_membership) {

  as.numeric(factor(memberships)) + max_membership
}
