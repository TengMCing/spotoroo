test_that("adjust_membership() works", {
  expect_equal(adjust_membership(c(0,2,2,5,6), 5),
               c(6,7,7,8,9))
})
