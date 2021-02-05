test_that("update_membership() works 1", {

  lon <- c(140, 141, 142, 143)
  lat <- c(-37, -37, -37, -37)
  global_membership <- c(1,1,2,0)
  local_membership <- c(1,1,1,1)
  indexes <- c(3,4)

  expect_equal(update_membership(lon,
                                 lat,
                                 global_membership,
                                 local_membership,
                                 indexes),
               c(1,1,2,2)
               )
})


test_that("update_membership() works 2", {

  lon <- c(140, 141, 142, 143)
  lat <- c(-37, -37, -37, -37)
  global_membership <- c(0,0,0,0)
  local_membership <- c(1,2,3,4)
  indexes <- c(1,2,3,4)

  expect_equal(update_membership(lon,
                                 lat,
                                 global_membership,
                                 local_membership,
                                 indexes),
               c(1,2,3,4)
  )
})


test_that("update_membership() works 3", {

  lon <- c(140, 141, 142, 143, 144)
  lat <- c(-37, -37, -37, -37, -37)
  global_membership <- c(1,1,2,0,0)
  local_membership <- c(1,1,1,1,2)
  indexes <- c(1,2,3,4,5)

  expect_equal(update_membership(lon,
                                 lat,
                                 global_membership,
                                 local_membership,
                                 indexes),
               c(1,1,2,2,3)
  )
})
