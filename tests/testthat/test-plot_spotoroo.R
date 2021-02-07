test_that("plot_spotoroo() works", {
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


  expect_silent(plot_spotoroo(result, type = "def"))
  expect_silent(plot_spotoroo(result, type = "def",
                              cluster = 1:3,
                              from = as.POSIXct("2020-01-20"),
                              to = as.POSIXct("2020-01-27"),
                              noise = TRUE))

  expect_silent(plot_spotoroo(result, type = "mov"))
  expect_silent(plot_spotoroo(result, type = "mov",
                              cluster = 1:3,
                              from = as.POSIXct("2019-01-20"),
                              to = as.POSIXct("2020-01-27")))

  expect_silent(plot_spotoroo(result, type = "timeline"))
  expect_silent(plot_spotoroo(result, type = "timeline",
                              from = as.POSIXct("2020-01-20"),
                              to = as.POSIXct("2020-01-27"),
                              mainBreak = "1 week",
                              minorBreak = "1 hour",
                              dateLabel = "%b %d"))


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


  expect_silent(plot_spotoroo(result, type = "def"))
  expect_silent(plot_spotoroo(result, type = "def",
                              cluster = 1:3,
                              from = 500,
                              to = 800,
                              noise = TRUE,
                              bg = plot_vic_map()))

  expect_silent(plot_spotoroo(result, type = "mov"))
  expect_silent(plot_spotoroo(result, type = "mov",
                              cluster = 1:3,
                              from = 1,
                              to = 800,
                              bg = plot_vic_map()))

  expect_silent(plot_spotoroo(result, type = "timeline"))
  expect_silent(plot_spotoroo(result, type = "timeline",
                              from = 500,
                              to = 800,
                              mainBreak = 7*24,
                              minorBreak = 1))
})
