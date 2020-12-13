FROM ubuntu:xenial
ARG DEBIAN_FRONTEND=noninteractive

# Default dependencies from LINUX_BUILD.md
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      autoconf \
      libtool \
      pkg-config \
      git \
      python3-pip \
      curl \
      uuid-dev \
      libusb-1.0.0-dev \
      libblkid-dev \
      libudev-dev \
      libgl1-mesa-dev \
      libcups2-dev \
      libftdi1-dev \
      cmake

# Additional Docker dependencies
RUN apt-get update && \
    apt-get install -y \
      wget

# Create folder for dependencies
RUN mkdir /deps

# Install Python3.8
RUN apt-get update \
    && apt-get install -y \
      software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
         python3.8


# Install Qt deps
RUN apt-get update && \
    apt-get install -y \
      xz-utils \
      libdbus-1-dev \
      '^libxcb.*-dev' \
      libx11-xcb-dev \
      libglu1-mesa-dev \
      libegl1-mesa-dev \
      libxrender-dev \
      libxi-dev \
      libnss3-dev \
      libpq-dev \
      libicu-dev \
      libfontconfig1-dev \
      gperf \
      bison \
      flex \
      python2.7 \
      python3.5 \
    && ln -s python2.7 /usr/bin/python

# Upload Qt
RUN cd /deps \
    && export MAJOR_MINOR=5.12 \
    && export PATCH=3 \
    && export VERSION=$MAJOR_MINOR.$PATCH \
    && wget "http://download.qt.io/archive/qt/$MAJOR_MINOR/$VERSION/single/qt-everywhere-src-$VERSION.tar.xz" \
    && tar xJf qt-everywhere-src-$VERSION.tar.xz

# Build Qt
RUN cd /deps \
    && export MAJOR_MINOR=5.12 \
    && export PATCH=3 \
    && export VERSION=$MAJOR_MINOR.$PATCH \
    && mkdir qt-$VERSION-build \
    && cd qt-$VERSION-build \
    && /deps/qt-everywhere-src-$VERSION/configure -opensource -confirm-license -nomake examples -nomake tests \
      -shared -qt-xcb -icu -cups -fontconfig \
      -skip qt3d \
      -skip qtactiveqt \
      -skip qtandroidextras \
      -skip qtcanvas3d \
      -skip qtcharts \
      -skip qtconnectivity \
      -skip qtdatavis3d \
      -skip qtgamepad \
      -skip qtlocation \
      -skip qtmacextras \
      -skip qtmultimedia \
      -skip qtnetworkauth \
      -skip qtpurchasing \
      -skip qtremoteobjects \
      -skip qtscript \
      -skip qtscxml \
      -skip qtsensors \
      -skip qtserialbus \
      -skip qtserialport \
      -skip qtspeech \
      -skip qtvirtualkeyboard \
      -skip qtwayland \
      -skip qtwebchannel \
      -skip qtwebglplugin \
      -skip qtwebview \
      -skip qtxmlpatterns \
    && make -j$(nproc) \
    && make install

RUN mkdir -p /app/src
RUN mkdir -p /app/build
WORKDIR /app/build
