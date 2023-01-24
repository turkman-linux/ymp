# YMP (Yerli ve Milli Paket sistemi)
![ymp logo](data/application-x-ymp.svg)

A package manager for Turkish

## Features
* 🇹🇷 Made in Turkiye 🇹🇷
* Binary / Source package support
* Use flag support (for source packages only)
* Built-in httpd
* Sandbox environment support
* Static build support
* Built-in yaml & ini parser
* Simple package format
* Built-in repository mirror tool
* Shell mode
* Built-in revdep-rebuild

## Dependencies
* libarchive
* libcurl
* glib2.0
* libreadline

## Build Dependencies
* meson
* valac
* gcc

## Building from source
### 1. Install dependencies
#### Debian (testing/unstable):
```bash
# install compilers
apt install meson gcc valac --no-install-recommends -y
# install dependencies
apt install libarchive-dev libreadline-dev libcurl4-openssl-dev libbrotli-dev --no-install-recommends -y
```
#### Archlinux:
```bash
# install compilers
pacman -Sy gcc vala --noconfirm
# install dependencies
pacman -Sy meson curl libarchive readline --noconfirm
```

#### Alpine:
```bash
# install compilers
apk add gcc vala
# install dependencies
apk add meson musl-dev bash glib-dev readline-dev libarchive-dev libcurl curl-dev
```

### 2. Build source code
For options please see **meson_options.txt**
```bash
meson build -Dshared=true <options>
ninja -C build
```
* For debian: You may need `-Dlibbrotli=false` option.

### 3. Install source code
```bash
ninja -C build install
ldconfig
```
