# YMP (Yerli ve Milli Paket sistemi)
![ymp logo](data/application-x-ymp.svg)

A package manager for Sulix Project

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

## Building from source

```bash
meson build <options>
ninja -C build
```

For options please see **meson_options.txt**

## Dependencies
* libarchive
* libcurl
