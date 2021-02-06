test_that("plot_timeline() works", {
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



  expect_silent(plot_timeline(result))
  expect_silent(plot_timeline(result,
                              from = as.POSIXct("2020-01-20"),
                              to = as.POSIXct("2020-01-27"),
                              mainBreak = "1 hour"))

  temp_hotspots <- hotspots_fin
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

  expect_silent(plot_timeline(result))
  expect_silent(plot_timeline(result,
                              from = 500,
                              to = 800,
                              mainBreak = 3,
                              minorBreak = 1))
})
