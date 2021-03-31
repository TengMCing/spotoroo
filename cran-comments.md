## Test environments
* local Windows 10 installation: R 3.6.3
* local mac OS X: release
* Github Actions (Mac OS X): release
* win-builder: devel, release, oldrel
* R-hub (Ubuntu Linux): devel, release
* R-hub (Debian Linux): devel, release
* R-hub (Fedora Linux): devel

## R CMD check results

There were no ERRORs or WARNINGs. 
  
## Note
This is a patched version. In this version I have:

* attempted to fix a bug to pass R CMD check on r-patched-solaris-x86 and r-oldrel-macos-x86_64. This bug would cause problems if older versions of spatial packages were used.


  
