#!/bin/bash
set -e
source @PKGBUILD@
name="$pkgname"
version="$pkgver"
release="$pkgrel"
description="$pkgdesc"
group=(archlinux unsafe)
source+=(PKGBUILD)
sha256sums+=("SKIP")
pkgdir="$installdir"
srcdir="$HOME"

function msg(){
    echo "$@"
}
readonly -f msg

function msg2(){
    echo "$@"
}
readonly -f msg2

arch-meson(){
	command meson setup \
	  --prefix        /usr \
	  --wrap-mode     nodownload \
	  "$@"
}
readonly -f arch-meson

