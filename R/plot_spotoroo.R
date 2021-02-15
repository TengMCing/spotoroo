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
#' @param result `spotoroo` object; a result of a call to [hotspot_cluster()].
#' @param type character; type of the plot; one of "def" (default),
#'                        "timeline" (timeline) and "mov" (fire movement).
#' @param cluster character/integer; if "all", plot all clusters. if a integer
#'                vector is given, plot corresponding clusters; unavailable in
#'                [plot_timeline()].
#' @param ignition logical; if `TRUE`, plot the ignition points; only used in
#'                          [plot_def()].
#' @param hotspot logical; if `TRUE`, plot the hot spots; unavailable in
#'                         [plot_timeline()].
#' @param noise logical; if `TRUE`, plot the noise; only used in
#'                       [plot_def()].
#' @param from **OPTIONAL**; date/datetime/numeric; start time; the data type
#'                           needs to be the same as the provided observed time.
#' @param to **OPTIONAL**; date/datetime/numeric; end time; the data type
#'                         needs to be the same as the provided observed time.
#' @param step integer (>=0); step size used in the calculation of the
#'                            fire movement; only used in [plot_fire_mov()].
#' @param mainBreak **OPTIONAL**; character/numeric; a string/value giving the
#'                                     difference between major breaks; if the
#'                                     observed time is in date/datetime
#'                                     format,
#'                                     this value will pass to
#'                                     [ggplot2::scale_x_date()] or
#'                                     [ggplot2::scale_x_datetime()] as
#'                                     `date_breaks`; only used in
#'                                     [plot_timeline()].
#' @param minorBreak **OPTIONAL**; character/numeric; a string/value giving the
#'                                     difference between minor breaks; if the
#'                                     observed time is in date/datetime
#'                                     format,
#'                                     this value will pass to
#'                                     [ggplot2::scale_x_date()] or
#'                                     [ggplot2::scale_x_datetime()] as
#'                                     `date_breaks`. only used in
#'                                     [plot_timeline()].
#' @param dateLabel **OPTIONAL**; character; a string giving the formatting
#'                                specification for the labels; if the
#'                                observed
#'                                time is in date/datetime format,
#'                                this value will pass to
#'                                [ggplot2::scale_x_date()] or
#'                                [ggplot2::scale_x_datetime()] as
#'                                `date_labels`; unavailable if the observed
#'                                time is in numeric format; only used in
#'                                [plot_timeline()].
#' @param bg **OPTIONAL**; `ggplot` object; if specified, plot onto this object;
#'                         unavailable in [plot_timeline()].
#' @return `ggplot` object; the plot of the clustering results.
#' @examples
#' # get clustering result
#' result <- hotspot_cluster(hotspots,
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
#' # different types of plots
#'
#' # default plot
#' plot_spotoroo(result, "def", bg = plot_vic_map())
#'
#'
#' # fire movement plot
#' plot_spotoroo(result, "mov", cluster = 1:3, step = 3, bg = plot_vic_map())
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




