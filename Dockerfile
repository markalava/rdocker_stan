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
  # libv8-dev
  #--- loo
  pandoc pandoc-citeproc \
  #--- DemoTools
  libv8-dev \
  #
  #--- stan
  # based on 'https://github.com/andrewheiss/tidyverse-stan/blob/master/3.5.1/Dockerfile'
  # Install ed, since nloptr needs it to compile
  # Install clang and ccache to speed up Stan installation
  # Install libxt-dev for Cairo
  curl \
  ed \
  libnlopt-dev \
  clang \
  ccache \
  libxt-dev \
  libv8-dev \
  build-essential \
  libgl1-mesa-dev libglu1-mesa-dev \
  #
  #--- OTHER UTILS -------------------------------------------------------------
  sudo \
  nano \
  #
  #--- TIDY --------------------------------------------------------------------
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  #
  #--- STAN SETUP---------------------------------------------------------------
  mkdir -p $HOME/.R \
    # Add global configuration files
    # Docker chokes on memory issues when compiling with gcc, so use ccache and clang++ instead
    && echo '\n \
        \nCC=/usr/bin/ccache clang \
        \n \
        \n# Use clang++ and ccache \
        \nCXX=/usr/bin/ccache clang++ -Qunused-arguments  \
        \n \
        \n# Optimize building with clang \
        \nCXXFLAGS=-g -O3 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2 -g -pedantic -g0 \
        \n \
        \n# Stan stuff \
        \nCXXFLAGS+=-O3 -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -Wno-macro-redefined \
        \n' >> $HOME/.R/Makevars \
    # Make R use ccache correctly: http://dirk.eddelbuettel.com/blog/2017/11/27/
    && mkdir -p $HOME/.ccache/ \
    && echo "max_size = 5.0G \
        \nsloppiness = include_file_ctime \
        \nhash_dir = false \
        \n" >> $HOME/.ccache/ccache.conf \
  # CmdStan ---
  && cd /opt \
    && git clone https://github.com/stan-dev/cmdstan.git --recursive \
    && cd cmdstan \
    && make build \
    && export PATH="/opt/cmdstan/bin:$PATH" \
  #
  #--- R SETUP------------------------------------------------------------------
  #--- Package repository: RStudio 'frozen' CRAN package, binaries for Ubuntu 'focal'
  && echo 'options(repos = c(REPO_NAME = "https://packagemanager.rstudio.com/cran/__linux__/focal/2021-07-15"))' >> /opt/R/${R_VERSION}/lib/R/etc/Rprofile.site \
  && Rscript -e 'install.packages("remotes")' \
  && Rscript -e 'remotes::install_github("timriffe/DemoTools")'  \
  && Rscript -e 'remotes::install_github("cimentadaj/DDSQLtools")'

CMD ["R"]
