#include <string.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

typedef struct _variable {
    char* name;
    char* value;
} variable;

variable *vars;
size_t num_of_values = 0;
size_t cap_of_values = 0;

void set_value2(char* name, char* value){
    if (num_of_values <= cap_of_values) {
        vars = realloc(vars, (cap_of_values+1024)*sizeof(variable));
        for(int i=cap_of_values;i<cap_of_values+1024;i++){
            vars[i].name ="";
            vars[i].value ="";
         }
         cap_of_values += 1024;
    }
   for(int i=0;i<1024;i++){
       if(strcmp(vars[i].name, name)==0){
           vars[i].value = value;
           return;
       }
   }
   vars[num_of_values].name = name;
   vars[num_of_values].value = value;
   num_of_values++;

}

char* get_value2(char* name){
   for(int i=0;i<1024;i++){
       if(strcmp(vars[i].name, name)==0){
           return strdup(vars[i].value);
       }
   }
   return "";
}

/*void main(){
    set_value("amogus","31");
    set_value("amogus31","31");
    puts(get_value("amogus"));
    set_value("amogus","32");
    puts(get_value("amogus"));
}
*/
