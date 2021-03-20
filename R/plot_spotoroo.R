#' Plotting spatiotemporal clustering result
#'
#' This function takes a `spotoroo` object to produce a plot of the
#' clustering results. It can be called by [plot.spotoroo()].
#'
#' if `type` is "def", the clustering results will be plotted spatially.
#' See also [plot_def()]. Available arguments:
#' - `result`
#' - `type`
#' - `cluster`
#' - `ignition`
#' - `hotspot`
#' - `noise`
#' - `from` (**OPTIONAL**)
#' - `to` (**OPTIONAL**)
#' - `bg` (**OPTIONAL**)
#'
#' if `type` is "mov", plot of the fire movement will be made.
#' See also [plot_fire_mov()]. Available arguments:
#' - `result`
#' - `type`
#' - `cluster`
#' - `hotspot`
#' - `from` (**OPTIONAL**)
#' - `to` (**OPTIONAL**)
#' - `step`
#' - `bg` (**OPTIONAL**)
#'
#' if `type` is "timeline", plot of the timeline will be made.
#' See also [plot_timeline()]. Available arguments:
#' - `result`
#' - `type`
#' - `from` (**OPTIONAL**)
#' - `to` (**OPTIONAL**)
#' - `mainBreak` (**OPTIONAL**)
#' - `minorBreak` (**OPTIONAL**)
#' - `dateLabel` (**OPTIONAL**)
#'
#' @param result `spotoroo` object. A result of a call to [hotspot_cluster()].
#' @param type Character. Type of the plot. One of "def" (default),
#'                        "timeline" (timeline) and "mov" (fire movement).
#' @param cluster Character/Integer. If "all", plot all clusters. If an integer
#'                vector is given, plot corresponding clusters. Unavailable in
#'                [plot_timeline()].
#' @param ignition Logical. If `TRUE`, plot the ignition points. Only used in
#'                          [plot_def()].
#' @param hotspot Logical. If `TRUE`, plot the hot spots. Unavailable in
#'                         [plot_timeline()].
#' @param noise Logical. If `TRUE`, plot the noise. Only used in
#'                       [plot_def()].
#' @param from **OPTIONAL**. Date/Datetime/Numeric. Start time. The data type
#'                           needs to be the same as the provided observed time.
#' @param to **OPTIONAL**. Date/Datetime/Numeric. End time. The data type
#'                         needs to be the same as the provided observed time.
#' @param step Integer (>=0). Step size used in the calculation of the
#'                            fire movement. Only used in [plot_fire_mov()].
#' @param mainBreak **OPTIONAL**. Character/Numeric. A string/value giving the
#'                                     difference between major breaks. If the
#'                                     observed time is in date/datetime
#'                                     format,
#'                                     this value will be passed to
#'                                     [ggplot2::scale_x_date()] or
#'                                     [ggplot2::scale_x_datetime()] as
#'                                     `date_breaks`. Only used in
#'                                     [plot_timeline()].
#' @param minorBreak **OPTIONAL**. Character/Numeric. A string/value giving the
#'                                     difference between minor breaks. If the
#'                                     observed time is in date/datetime
#'                                     format,
#'                                     this value will be passed to
#'                                     [ggplot2::scale_x_date()] or
#'                                     [ggplot2::scale_x_datetime()] as
#'                                     `date_minor_breaks`. Only used in
#'                                     [plot_timeline()].
#' @param dateLabel **OPTIONAL**. Character. A string giving the formatting
#'                                specification for the labels. If the
#'                                observed
#'                                time is in date/datetime format,
#'                                this value will be passed to
#'                                [ggplot2::scale_x_date()] or
#'                                [ggplot2::scale_x_datetime()] as
#'                                `date_labels`. Unavailable if the observed
#'                                time is in numeric format. Only used in
#'                                [plot_timeline()].
#' @param bg **OPTIONAL**. `ggplot` object. If specified, plot onto this object.
#'                         Unavailable in [plot_timeline()].
#' @return A `ggplot` object. The plot of the clustering results.
#' @examples
#' \donttest{
#'
#'   # Time consuming functions (>5 seconds)
#'
#'
#'   # Get clustering result
#'   result <- hotspot_cluster(hotspots,
#'                           lon = "lon",
#'                           lat = "lat",
#'                           obsTime = "obsTime",
#'                           activeTime = 24,
#'                           adjDist = 3000,
#'                           minPts = 4,
#'                           minTime = 3,
#'                           ignitionCenter = "mean",
#'                           timeUnit = "h",
#'                           timeStep = 1)
#'
#'   # Different types of plots
#'
#'   # Default plot
#'   plot_spotoroo(result, "def", bg = plot_vic_map())
#'
#'
#'   # Fire movement plot
#'   plot_spotoroo(result, "mov", cluster = 1:3, step = 3,
#'                 bg = plot_vic_map())
#' }
#'
#'
#' @export
plot_spotoroo <- function(result,
                          type = "def",
                          cluster = "all",
                          hotspot = TRUE,
                          noise = FALSE,
                          ignition = TRUE,
                          from = NULL,
                          to = NULL,
                          step = 1,
                          mainBreak = NULL,
                          minorBreak = NULL,
                          dateLabel = NULL,
                          bg = NULL) {

  if (!"spotoroo" %in% class(result)) {
    stop('Needs a "spotoroo" object as input.')
  }

  check_type("character", type)
  is_length_one(type)

  if (type == "def") {
    p <- plot_def(result,
                  cluster,
                  hotspot,
                  noise,
                  ignition,
                  from,
                  to,
                  bg)

  }

  if (type == "mov") {

    p <- plot_fire_mov(result,
                       cluster,
                       hotspot,
                       from,
                       to,
                       step,
                       bg)
  }

  if (type == "timeline") {

    p <- plot_timeline(result,
                       from,
                       to,
                       mainBreak,
                       minorBreak,
                       dateLabel)
  }

  p

}




