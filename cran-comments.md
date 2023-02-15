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

* attempted to fix a bug in `plot_timeline()` caused by the update of a upstream dependency `ggbeeswarm`.
* attempted to fixed a bug in `hotspot_cluster` that printed incorrect plural form of a noun via `cli`.
* attempted to fixed a bug in `summary_spotoroo` that printed incorrect plural form of a noun via `cli`.


  
