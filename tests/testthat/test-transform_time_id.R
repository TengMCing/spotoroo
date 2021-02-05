test_that("transform_time_id() works", {

  # numeric
  obsTime <- c(0,1.5,3)
  expect_equal(transform_time_id(obsTime, timeUnit = "n", timeStep = 1),
               c(1,2,4))

  expect_equal(transform_time_id(obsTime, timeUnit = "n", timeStep = 1.5),
               c(1,2,3))

  # date
  obsTime <- as.Date(c("2020-01-01", "2020-01-02", "2020-01-04"))
  expect_equal(transform_time_id(obsTime, timeUnit = "d", timeStep = 1.5),
               c(1,1,3))
  expect_equal(transform_time_id(obsTime, timeUnit = "h", timeStep = 24),
               c(1,2,4))
  expect_equal(transform_time_id(obsTime, timeUnit = "h", timeStep = 12),
               c(1,3,7))
  expect_equal(transform_time_id(obsTime, timeUnit = "m", timeStep = 60),
               c(1,25,73))
  expect_equal(transform_time_id(obsTime, timeUnit = "s", timeStep = 3600),
               c(1,25,73))

  # POSIXct
  obsTime <- as.POSIXct(c("2020-01-01", "2020-01-02", "2020-01-04"))
  expect_equal(transform_time_id(obsTime, timeUnit = "d", timeStep = 1.5),
               c(1,1,3))
  expect_equal(transform_time_id(obsTime, timeUnit = "h", timeStep = 24),
               c(1,2,4))
  expect_equal(transform_time_id(obsTime, timeUnit = "h", timeStep = 12),
               c(1,3,7))
  expect_equal(transform_time_id(obsTime, timeUnit = "m", timeStep = 60),
               c(1,25,73))
  expect_equal(transform_time_id(obsTime, timeUnit = "s", timeStep = 3600),
               c(1,25,73))
})
