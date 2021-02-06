test_that("plot_fire_mov() works", {
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

  expect_s3_class(plot_fire_mov(result), "ggplot")
  expect_s3_class(plot_fire_mov(result,
                                cluster = c(1,2),
                                bg = plot_vic_map()), "ggplot")

})

