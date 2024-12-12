# Outbreak analytics in R training
sessionInfo()
#R version 4.3.1 (2023-06-16 ucrt) -- "Beagle Scouts"
#Copyright (C) 2023 The R Foundation for Statistical Computing
#Platform: x86_64-w64-mingw32/x64 (64-bit)

install.packages("pak")
new_packages <- c(
  # for Introduction tutorial
  "here",
  "tidyverse",
  "visdat",
  "skimr",
  "rmarkdown",
  "quarto",
  # for Early Task tutorials
  "epiverse-trace/cleanepi",
  "rio",
  "DBI",
  "RSQLite",
  "dbplyr",
  "linelist",
  "epiverse-trace/simulist",
  "incidence2",
  "epiverse-trace/tracetheme",
  # for Middle Task tutorials
  "EpiNow2",
  "epiverse-trace/epiparameter",
  "cfr",
  "outbreaks",
  "epicontacts",
  "fitdistrplus",
  "epiverse-trace/superspreading",
  "epichains",
  # for Late task tutorials
  "socialmixr",
  "epiverse-trace/epidemics",
  "scales"
)

pak::pak(new_packages)