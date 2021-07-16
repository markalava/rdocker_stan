ARG R_VERSION=4.1.0

FROM rstudio/r-base:${R_VERSION}-focal

ARG R_VERSION

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  apt-utils \
  #
  #--- R PACKAGE DEPENDENCIES --------------------------------------------------
  #--- RcppParallel
  make \
  #--- rstan, rstantools
  make pandoc \
  #--- V8
  # requires libv8-dev to install from source but using pre-compiled binaries so skip this \
  #--- loo
  pandoc pandoc-citeproc \
  #
  #--- OTHER UTILS ------------------------------------------------------------- 
  nano \
  #
  #--- TIDY --------------------------------------------------------------------
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  #
  #--- R SETUP------------------------------------------------------------------
  #--- Package repository: RStudio 'frozen' CRAN package, binaries for Ubuntu 'focal'
  && echo 'options(repos = c(REPO_NAME = "https://packagemanager.rstudio.com/cran/__linux__/focal/2021-07-15"))' >> /opt/R/${R_VERSION}/lib/R/etc/Rprofile.site \
  #--- R Packages
  && Rscript -e 'install.packages(c("dplyr", "tibble", "tidyr", "plyr", "stringr", "testthat", "ggplot2", "scales", "Rcpp", "RcppParallel", "BH", "RcppEigen", "pbapply", "gridExtra", "egg", "remotes", "ungroup", "rgl", "RCurl", "data.table", "rstan", "rstantools"))' \
  # && Rscript -e 'remotes::install_github("timriffe/DemoToolsData")' \
  # && Rscript -e 'remotes::install_github("josehcms/fertestr")'  \
  && Rscript -e 'remotes::install_github("timriffe/DemoTools")'  \
  && Rscript -e 'remotes::install_github("cimentadaj/DDSQLtools")' 

CMD ["R"]

