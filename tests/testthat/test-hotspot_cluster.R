test_that("hotspot_cluster() works", {

  temp_hotspots <- hotspots
  temp_hotspots$obsTime <- transform_time_id(temp_hotspots$obsTime, "h", 1)

  result <- hotspot_cluster(temp_hotspots,
                            lon = "lon",
                            lat = "lat",
                            obsTime = "obsTime",
                            activeTime = 24,
                            adjDist = 3000,
                            minPts = 4,
                            minTime = 3,
                            ignitionCenter = "mean")

  expect_invisible(print(result))
  expect_invisible(summary(result))
  expect_invisible(summary(result, cluster = c(1,3)))
  expect_silent(plot(result))
})
