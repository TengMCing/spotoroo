test_that("multiplication works", {
  timeID <- c(1,1,3,4,5,6,7)
  expect_equal(define_interval(timeID, 3, 3),
               c(1,2,3))
})
