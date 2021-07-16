FROM rstudio/r-base:4.1.0-focal

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  apt-utils \
  # --- other utils 
  nano \
  # --- Tidy
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/
