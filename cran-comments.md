## Test environments
* local mac OS X: release
* win-builder: devel, release, oldrel
* R-hub (Ubuntu Linux): devel, release
* R-hub (Debian Linux): devel, release
* R-hub (Fedora Linux): devel

## R CMD check results

There were no ERRORs or WARNINGs. 
There is 1 Note: 
  Possibly mis-spelled words in DESCRIPTION:
    Spatiotemporal (2:8)
The word "Spatiotemporal" is correctly spelled.

## Note
This is a patched version. In this version I have:

* attempted to fixed a bug in package documentation caused by the use of a deprecated roxygen2 feature `@doctype package`.
* attempted to add support for new `ggbeeswarm 0.7.2` feature `orientation`, and deleted unused fallback methods from `plot_timeline()`.



  
