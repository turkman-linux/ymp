#include <stdio.h>
#include <string.h>
void brainfuck(char * code, int size) {
  int ptr = 0;
  int tmp = 0;
  int values[size];
  for(int i=0;i < size;i++){
      values[i] = 0;
  }
  for (int i = 0; i < strlen(code); i++) {
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