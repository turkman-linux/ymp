#!/bin/bash
set -e
source PKGBUILD
name="$pkgname"
version="$pkgver"
release="$pkgrel"
description="$pkgdesc"
group=(archlinux unsafe)
source+=(PKGBUILD)
sha256sums+=("SKIP")
pkgdir="$installdir"
function msg(){
    echo "$@"
}
function msg2(){
    echo "$@"
}

arch-meson(){
	command meson setup \
	  --prefix        /usr \
	  --wrap-mode     nodownload \
	  "$@"

}

