##
# Install GRASS from within a docker container
#
# This Makefile is designed to be run from within a docker container in order to
# install GRASS.  The following is an example invocation:
#
# make -C /usr/local/src/grass-docker install clean
#
# The targets in this Makefile are derived from instructions at
# <http://grasswiki.osgeo.org/wiki/Compile_and_Install_Ubuntu> and the Travis CI
# `.travis.yml` file in the repository.
#

# Version related variables.
GRASS_VERSION := $(shell cat ./grass-checkout.txt)
GDAL_VERSION := $(shell cat ./gdal-checkout.txt)

# Buildtime dependencies satisfied by packages.
BUILD_PACKAGES := build-essential \
flex bison cmake ccache \
checkinstall

# Runtime dependencies satisfied by packages.
DEPS_PACKAGES := python python-dev \
python-dateutil libgsl0-dev python-numpy \
python-opengl \
python-wxversion python-wxtools python-wxgtk2.8 \
python-dateutil libgsl0-dev python-numpy \
wx2.8-headers wx-common libwxgtk2.8-dev libwxgtk2.8-dbg \
libwxbase2.8-dev  libwxbase2.8-dbg \
libncurses5-dev \
zlib1g-dev gettext \
libtiff-dev libpnglite-dev \
libcairo2 libcairo2-dev \
sqlite3 libsqlite3-dev \
libpq-dev \
libreadline6 libreadline6-dev libfreetype6-dev \
libfftw3-3 libfftw3-dev \
libboost-thread-dev libboost-program-options-dev liblas-c-dev \
resolvconf \
libjasper-dev \
libav-tools libavutil-dev ffmpeg2theora \
libffmpegthumbnailer-dev \
libavcodec-dev \
libxmu-dev \
libavformat-dev libswscale-dev \
libglu1-mesa-dev libxmu-dev \
ghostscript \
libmysqlclient-dev \
netcdf-bin libnetcdf-dev

# GRASS dependency targets.
GRASS := /usr/local/bin/grass
GDAL_CONFIG := /usr/local/bin/gdal_config
BUILD_ESSENTIAL := /usr/share/build-essential

# Build tools.
SVN := /usr/bin/svn
GIT := /usr/bin/git

# The number of processors available.
NPROC := $(shell nproc)

install: $(GRASS)

$(GRASS): /tmp/grass $(BUILD_ESSENTIAL) $(GDAL_CONFIG)
	cd /tmp/grass/ \
	&& CFLAGS="-O2 -Wall" LDFLAGS="-s" ./configure \
		--enable-largefile=yes \
		--with-nls \
		--with-cxx \
		--with-readline \
		--with-pthread \
		--with-proj-share=/usr/share/proj \
		--with-geos \
		--with-wxwidgets \
		--with-cairo \
		--with-opengl-libs=/usr/include/GL \
		--with-freetype=yes --with-freetype-includes="/usr/include/freetype2/" \
		--with-postgres=yes --with-postgres-includes="/usr/include/postgresql" \
		--with-sqlite=yes \
		--with-mysql=yes --with-mysql-includes="/usr/include/mysql" \
		--with-odbc=yes \
		--with-netcdf=yes \
		--with-liblas=yes \
	&& make -j$(NPROC) \
	&& make install \
	&& ldconfig \
	&& ln -fs /usr/local/bin/grass$$(head -2 /tmp/grass/include/VERSION | tr -d "\n") $(GRASS) \
	&& touch -c $(GRASS)

$(GDAL_CONFIG): /usr/local/src/gdal-docker
	make -C /usr/local/src/gdal-docker install \
	&& touch -c $(GDAL_CONFIG)
/usr/local/src/gdal-docker: $(GIT)
	$(GIT) clone --branch $(GDAL_VERSION) --depth 1 http://github.com/geo-data/gdal-docker /usr/local/src/gdal-docker \
	&& touch -c /usr/local/src/gdal-docker

/tmp/grass: $(SVN)
	$(SVN) checkout --quiet "http://svn.osgeo.org/grass/grass/$(GRASS_VERSION)/" /tmp/grass/ \
	&& touch -c /tmp/grass

$(SVN): /tmp/apt-updated
	apt-get install -y subversion && touch -c $(SVN)

$(GIT): /tmp/apt-updated
	apt-get install -y git && touch -c $(GIT)

$(BUILD_ESSENTIAL): /tmp/apt-updated
	apt-get install -y $(BUILD_PACKAGES) $(DEPS_PACKAGES) \
	&& touch -c $(BUILD_ESSENTIAL)

/tmp/apt-updated:
	apt-get update -y && touch /tmp/apt-updated

# Remove build time dependencies.
clean:
	make -C /usr/local/src/gdal-docker clean \
	&& apt-get purge -y \
		$(BUILD_PACKAGES) \
		subversion \
		git \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/partial/* /tmp/* /var/tmp/*

.PHONY: install clean
