## Test environments
* local Windows 10 installation: R 3.6.3
* Github Actions (Mac OS X): release
* win-builder: devel, release, oldrel
* R-hub (Ubuntu Linux): devel, release
* R-hub (Debian Linux): devel, release
* R-hub (Fedora Linux): devel

## R CMD check results

There were no ERRORs or WARNINGs. 

There was 1 NOTE:

* checking CRAN incoming feasibility ... NOTE
  Possibly mis-spelled words in DESCRIPTION:
    Spatiotemporal (2:8)
    
  Spatiotemporal is a correct word. 
  
## Resubmission
This is a resubmission. In this version I have:

* Specificed versions of dependencies 

* Tested the pakcage on an additional platfrom: Fedora Linux
  
