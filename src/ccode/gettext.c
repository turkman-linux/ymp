#include <stdio.h>
#include <stdlib.h>

#include <libintl.h>
#include <locale.h>

char* GETTEXT_PACKAGE="ymp";

void locale_init(){
  setlocale (LC_ALL, "");
  bindtextdomain ("ymp", "/usr/share/locale/");
  textdomain ("ymp");

}
