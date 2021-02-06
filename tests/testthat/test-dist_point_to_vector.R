test_that("multiplication works", {
  lon <- c(141,142,143,144,145)
  lat <- c(-37,-37,-37,-37,-37)
  expect_equal(round(dist_point_to_vector(lon[1], lat[1], lon, lat)),
               c(0, 88755, 177509 , 266264 , 355019))
})
