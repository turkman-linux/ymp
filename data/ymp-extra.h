#ifndef _ymp_extra
#define _ymp_extra
#include <stdbool.h>

#define try bool __HadError=false;
#define catch(x) ExitJmp:if(__HadError)
#define throw(x) {__HadError=true;goto ExitJmp;}

#endif _ymp_extra
