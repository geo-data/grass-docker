##
# geodata/grass
#
# This creates an Ubuntu derived base image that installs GRASS from a specific
# subversion checkout compiled against a specific GDAL version.
#

# Ubuntu 14.04 Trusty Tahyr
FROM ubuntu:trusty

MAINTAINER Homme Zwaagstra <hrz@geodata.soton.ac.uk>

# Install the application.
ADD . /usr/local/src/grass-docker/
RUN apt-get update -y && \
    apt-get install -y make && \
    make -C /usr/local/src/grass-docker install clean && \
    apt-get purge -y make

# Externally accessible data is by default put in /data.
WORKDIR /data
VOLUME ["/data"]

# Ensure the SHELL is picked up by grass.
ENV SHELL /bin/bash

# All commands are executed by grass.
ENTRYPOINT ["grass"]

# Output GRASS version by default.
CMD ["--help]
