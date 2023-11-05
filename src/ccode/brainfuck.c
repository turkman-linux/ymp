#include <stdio.h>
#include <string.h>

#ifndef get_bool
int get_bool(char* msg);
#endif

void brainfuck(char * code, unsigned int size) {
  unsigned int ptr = 0;
  unsigned int i = 0;
  int tmp = 0;
  int values[size];
  for(i=0;i < size;i++){
      values[i] = 0;
  }
  for (i = 0; i < strlen(code); i++) {
    if(ptr >=size){
        fprintf(stderr,"Failed to run brainfuck code:  %s\n","Out of memory");
        return;
    }
    if (code[i] == '>') {
      ptr++;
    } else if (code[i] == '<') {
      ptr--;
    } else if (code[i] == '+') {
      values[ptr]++;
    } else if (code[i] == '-') {
      values[ptr]--;

    }else if (code[i] == '[') {
      if (values[ptr] == 0) {
        i++;
        while (code[i] != ']' || tmp != 0) {
          if (code[i] == '[') {
            tmp++;
          } else if (code[i] == ']') {
            tmp--;
          }
          i++;
        }
      }

    } else if (code[i] == ']') {
      if (values[ptr] != 0) {
        i--;
        while (code[i] != '[' || tmp > 0) {
          if (code[i] == ']') {
            tmp++;
          } else if (code[i] == '[') {
            tmp--;
          }
          i--;
        }
        i--;
      }
    } else if (code[i] == '.') {
      putc(values[ptr],stdout);
    } else if (code[i] == ',') {
      values[ptr] = getc(stdin);
    }
  }
}

void bf_compile(char* code){
    FILE *output;
    output = popen ("gcc -x c - $CFLAGS -O3 -s -o /tmp/bf.elf", "w");
    fputs(code, output);
    pclose(output);
}

