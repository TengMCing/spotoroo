test_that("extract_fire() works", {
  result <- hotspot_cluster(hotspots_fin,
                            lon = "lon",
                            lat = "lat",
                            obsTime = "obsTime",
                            activeTime = 24,
                            adjDist = 3000,
                            minPts = 4,
                            minTime = 3,
                            ignitionCenter = "mean",
                            timeUnit = "h",
                            timeStep = 1)

  expect_equal(nrow(extract_fire(result)),
               1066)

  expect_equal(nrow(extract_fire(result, noise = TRUE)),
               1076)

  expect_equal(nrow(extract_fire(result, 1:3)),
               440)
})
