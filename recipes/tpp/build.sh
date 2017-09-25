#!/bin/bash

BUILD_DIR="${SRC_DIR}/build"

export CXXFLAGS="${CXXFLAGS} -fPIC -w"
export CFLAGS="-I$PREFIX/include"
export CPATH=${PREFIX}/include
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

# TODO: mz5 support is nearly working but needs a few fixes in linking certain
# targets
#export HDF5_SUPPORT = 1
#export MZ5_SUPPORT  = 1

echo "INSTALL_DIR  = ${PREFIX}"      >  site.mk
echo "TPP_BASEURL  = /tpp"           >> site.mk
echo "TPP_DATADIR  = ${PREFIX}/data" >> site.mk

# install the dependencies

cpanm FindBin::libs

make --silent extern

# we don't want/need these extra binaries, especially since some may conflict
# with those provided by other conda packages
rm -rf $BUILD_DIR/bin/*

# These are the actual TPP targets that we want (we skip the Search target
# because those search engines are packaged separately in conda)
make --silent Quantitation
make --silent Validation
make --silent Visualization
make --silent Parsers
make --silent Util
make --silent spectrast
make --silent perl
make --silent mayu

# Move everything to the final destination. This is done instead of 'make
# install' because that command will try to build everything that we've
# intentionally skipped

mkdir -p $PREFIX/html
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/cgi-bin

chmod +x $BUILD_DIR/bin/*.pl

cp -R $BUILD_DIR/bin          $PREFIX
cp -R $BUILD_DIR/conf         $PREFIX
cp -R $BUILD_DIR/lic          $PREFIX
cp -R $BUILD_DIR/html/PepXML* $PREFIX/html
cp -R $BUILD_DIR/lib/perl/*   $PREFIX/lib

# Generally we don't want the CGI stuff, but these files are specifically
# wanted by GalaxyP
chmod +x $BUILD_DIR/cgi-bin/PepXMLViewer.cgi
chmod +x $BUILD_DIR/cgi-bin/protxml2html.pl
cp -R $BUILD_DIR/cgi-bin/PepXMLViewer.cgi $PREFIX/bin
cp -R $BUILD_DIR/cgi-bin/PepXMLViewer.cgi $PREFIX/cgi-bin
cp -R $BUILD_DIR/cgi-bin/protxml2html.pl  $PREFIX/bin
