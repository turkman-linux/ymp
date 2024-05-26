#ifndef no_locale
#include <stdio.h>
#include <stdlib.h>

#include <libintl.h>
#include <locale.h>


void locale_init(){
  setlocale (LC_ALL, "");
  bindtextdomain ("ymp", "/usr/share/locale/");
  textdomain ("ymp");

}

#endif
