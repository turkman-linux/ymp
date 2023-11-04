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
#if defined(__x86_64__) || defined(_M_X64)
    #define getArch() "x86_64"
    #define getDebianArch() "amd64"
#elif defined(i386) || defined(__i386__) || defined(__i386) || defined(_M_IX86)
    #define getArch() "i386"
    #define getDebianArch() "i386"
#elif defined(__aarch64__) || defined(_M_ARM64)
    #define getArch() "aarch64"
    #define getDebianArch() "arm64"
#elif defined(__ARM_ARCH_7__) || defined(__ARM_ARCH_7A__) || defined(__ARM_ARCH_7R__) || defined(__ARM_ARCH_7M__) || defined(__ARM_ARCH_7S__)
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
