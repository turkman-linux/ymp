// Colors
#define black 30
#define red 31
#define green 32
#define yellow 33
#define blue 34
#define magenta 35
#define cyan 36
#define white 37
// CPU Architecture
#if defined(__x86_64__)
    #define getArch() "x86_64"
    #define getDebianArch() "amd64"
#elif defined(__i386__) || defined(__i486__) || defined(__i586__) || defined(__i686__)
    #define getArch() "i386"
    #define getDebianArch() "i386"
#elif defined(__aarch64__)
    #define getArch() "aarch64"
    #define getDebianArch() "arm64"
#elif defined(__ARM_EABI__)
    #define getArch() "arm"
    #define getDebianArch() "armhf"
#else
    #define getArch() "UNKNOWN"
    #define getDebianArch() "UNKNOWN"
#endif
// debug function remove if non debug
#ifndef DEBUG
    #define debug(A)
#endif
// no locale option
#ifdef no_locale
    #define _(A) A
#endif
// define some functions
#define pwd GLib.Environment.get_current_dir
