# spotoroo 0.1.4

* Fixed a bug in package documentation due to the use of a deprecated roxygen2 feature `@doctype package`.
* Add support for new `ggbeeswarm 0.7.2` feature `orientation`. `plot_timeline()` no longer uses `geom_point()` to draw noise as a fallback method. 

# spotoroo 0.1.3

* Fixed a bug in `plot_timeline()` that draws incorrect noise.
* Fixed a bug in `hotspot_cluster()` that printed incorrect plural form of a noun via `cli`.
* Fixed a bug in `summary_spotoroo()` that printed incorrect plural form of a noun via `cli`.

# spotoroo 0.1.2

* Fixed a bug in `hotspot_to_ignition()` that caused problems with time calculation of noise points.
* Fixed a bug in `plot_timeline()` that caused problems with counting number of fires.
* Fixed the aspect ratio of `plot_fire_mov()`. It now equals to `cos(mean(range(lat))*pi/180)`. 

# spotoroo 0.1.1

* Fixed a bug in `plot_vic_map()` that caused problems with older version of spatial packages.

# spotoroo 0.1.0

**First release**

* Added 13 exported functions

    - `hotspot_cluster()`
    - `global_clustering()`
    - `local_clustering()`
    - `handle_noise()`
    - `ignition_point()`
    - `get_fire_mov()`
    - `plot.spotoroo()`
    - `plot_spotoroo()`
    - `plot_def()`
    - `plot_fire_mov()`
    - `plot_timeline()`
    - `plot_vic_map()`
    - `summary.spotoroo()`
    - `summary_spotoroo()`
    - `print.spotoroo()`
    - `transform_time_id()`
    - `dist_point_to_vector()`

* Added 2 data objects

    - `hotspots`
    - `vic_map`


# spotoroo 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.

