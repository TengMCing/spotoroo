% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{vic_map}
\alias{vic_map}
\title{simple features map of Victoria}
\format{
A "\code{sf}" object with 1 row.
}
\source{
\url{https://www.naturalearthdata.com/}
}
\usage{
vic_map
}
\description{
A dataset containing the simple features of Victoria, Australia.
}
\details{
The dataset is obtained via the following codes:\cr
\code{library(rnaturalearth)}\cr
\code{au_map <- ne_states(country = "Australia", returnclass = "sf")}\cr
\code{vic_map <- au_map[7,]$geometry}
}
\keyword{datasets}
