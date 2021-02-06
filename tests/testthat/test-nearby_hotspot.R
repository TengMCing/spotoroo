test_that("nearby_hotspot() works", {
  hotspot_list <- c(1,2,3)
  pointer <- c(3)
  lon <- c(141,142,143,144,145)
  lat <- c(-37,-37,-37,-37,-37)
  adjDist <- 100000
  expect_equal(nearby_hotspot(hotspot_list, pointer, lon, lat, adjDist),
               c(4))
})
