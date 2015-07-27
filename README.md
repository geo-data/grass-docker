# GRASS Docker Images

This is an Ubuntu derived image containing [GRASS GIS](http://grass.osgeo.org)
software.

Each branch in the git repository corresponds to a GRASS major version
(e.g. `7.0`) with the master branch following GRASS trunk. These branch names
are reflected in the image tags on the Docker Index (e.g. branch `7.0`
corresponds to the image `geodata/gdal:7.0`).

## Usage

Running the container without any arguments will output the grass help:

    docker run geodata/grass

All arguments passed to the image are passed as options to grass, i.e. the
following is equivalent to the previous invocation:

    docker run geodata/grass --help

You will most likely want to work with data on the host system from within the
docker container, in which case run the container with the `-v` option along the
following lines:

    docker run -it --rm -v $(pwd):/data geodata/grass -c /data/grassdb/here

The above command will create, in the current working directory on the host, the
GRASS database `grassdb` and the GRASS location `here` with the default GRASS
mapset of `PERMANENT`.

Running the following command in the future **from the same current working
directory** will allow you to continue working with the data:

    docker run -it --rm -v $(pwd):/data geodata/grass /data/grassdb/here/PERMANENT

This works because the current working directory is set to `/data` in
the container, and you have mapped the current working directory on your host to
`/data`.

## Creating images with specific versions

You may want to create your own images based on specific versions of GRASS and
GDAL, in which case clone the GRASS docker repository and edit the
`grass-checkout.txt` and `gdal-checkout.txt` files to reference the desired
versions.  For example, the following will build GRASS 7.0.0 against GDAL 2.0.0:

```
git clone git://github.com/geo-data/grass-docker/ \
&& cd grass-docker \
&& echo "tags/release_20150220_grass_7_0_0" > grass-checkout.txt \
&& echo "2.0.0" > gdal-checkout.txt \
&& docker build -t geodata/grass:local .
```

`tags/release_20150220_grass_7_0_0` references a specific checkout of the
[GRASS subversion repository](https://svn.osgeo.org/grass/grass/).

Note that the image tagged `geodata/grass:latest` represents the latest code *at
the time the image was built*. If you want to include the most up-to-date
commits then you need to build the docker image yourself locally along these
lines:

    docker build -t geodata/grass:local git://github.com/geo-data/grass-docker/
