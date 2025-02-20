#!/bin/bash

#
# Build script for Solaris 11.4 sysroot creation.
#

# This script uses `mf2tar` from https://github.com/illumos/sysroot.git
which mf2tar > /dev/null 2>&1 || { echo "mf2tar is not in PATH, exiting..."; exit 1; }

# sysroot version date
VERS_DATE="2025-02-21"

# Name of sysroot archive
ARCHIVE=solaris-`uname -v`-`mach`-sysroot-v$VERS_DATE

# Solaris 11.4 packages used for sysroot build
PACKAGES+=" library/zlib"
PACKAGES+=" system/header" 
PACKAGES+=" system/library" 
PACKAGES+=" system/library/libc" 
PACKAGES+=" system/library/math"
PACKAGES+=" system/library/security/crypto"
PACKAGES+=" system/linker"
PACKAGES+=" system/library/gcc/gcc-c-runtime"

# Cherry picked libraries, object files for sysroot
LIBS+=" libc"
LIBS+=" libdl"
LIBS+=" libcryptoutil"
LIBS+=" libelf"
LIBS+=" libinetutil"
LIBS+=" libm"
LIBS+=" libnsl"
LIBS+=" libpthread"
LIBS+=" libposix4"
LIBS+=" libresolv"
LIBS+=" librt"
LIBS+=" libsocket"
LIBS+=" libsendfile"
LIBS+=" libbsm"
LIBS+=" libkstat"
LIBS+=" libkstat2"
LIBS+=" libucrypto"
LIBS+=" libtsol"
LIBS+=" libz"
LIBS+=" ld"
USRLIBS+=" liblgrp"
USRLIBS+=" libgcc_s"
USRLIBCRTS+=" crt1"
USRLIBCRTS+=" crti"
USRLIBCRTS+=" crtn"
USRLIBCRTS+=" gcrt1"
USRLIBCRTS+=" ld"
USRLIBCRTS+=" values-Xa"
USRLIBCRTS+=" values-Xc"
USRLIBCRTS+=" values-Xs"
USRLIBCRTS+=" values-Xt"
USRLIBCRTS+=" values-xpg4"
USRLIBCRTS+=" values-xpg6"
USRLIBCRTS+=" watchmalloc"

OTHER_PLATFORM=`mach | grep sparc >/dev/null && echo i386 || echo sparc`

mkdir -p build
rm -rf build/*

for p in $PACKAGES ; do
  manifest=`mktemp`
  pkg contents -m $p | grep -v variant.arch=$OTHER_PLATFORM > $manifest
  mf2tar -m $manifest -E usr/share -E usr/gnu -E usr/bin -p / $manifest.tar > /dev/null
  (cd build; gtar xf $manifest.tar)
  rm -f $manifest $manifest.tar
done

MACH64=`mach | grep sparc >/dev/null && echo sparcv9 || echo amd64`

# no need for these
rm -rf \
  build/lib/crypto \
  build/lib/secure \
  build/usr/lib/iconv \
  build/usr/lib/scsi \
  build/usr/lib/lwp \
  build/usr/lib/elfedit \
  build/usr/lib/secure \
  build/usr/lib/ld \
  build/usr/lib/libc \
  build/usr/lib/security \
  build/usr/lib/mdb

rm -rf build/usr/lib/pkgconfig
rm -rf build/usr/lib/$MACH64/pkgconfig

# no need for lint files
rm build/lib/*.ln
rm build/lib/$MACH64/*.ln
rm build/usr/lib/*.ln
rm build/usr/lib/$MACH64/*.ln

# no need for these directories
rm -rf build/var
rm -rf build/usr/platform
rm -rf build/usr/xpg4

# Do cherry picking
mv build/lib build/lib.orig
mv build/usr/lib build/usr/lib.orig
mkdir -p build/lib
mkdir -p build/lib/$MACH64
mkdir -p build/usr/lib
mkdir -p build/usr/lib/$MACH64
# /lib
for l in $LIBS ; do
  gcp -a build/lib.orig/$l.so* build/lib
  gcp -a build/lib.orig/$MACH64/$l.so* build/lib/$MACH64
done
# /usr/lib - libraries
for l in $USRLIBS ; do
  gcp -a build/usr/lib.orig/$l.so* build/usr/lib/
  gcp -a build/usr/lib.orig/$MACH64/$l.so* build/usr/lib/$MACH64
done
# /usr/lib - system object files
for l in $USRLIBCRTS ; do
  gcp build/usr/lib.orig/$l* build/usr/lib
  gcp build/usr/lib.orig/$MACH64/$l* build/usr/lib/$MACH64
done
rm -rf build/lib.orig
rm -rf build/usr/lib.orig

# Create bz2 GNU tar archive for exact archive reproducibility
(cd build; TZ=UTC gtar cjf ../$ARCHIVE.tar.bz2 --mtime="$VERS_DATE" --sort=name --owner=root --group=root *)
# Print SHA256 checksum
sha256sum $ARCHIVE.tar.bz2
