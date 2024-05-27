#include <stdio.h>
#include <string.h>

#include <logger.h>
#include <error.h>

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
        ferror_add("Failed to run brainfuck code:  %s\n","Out of memory");
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
#ifndef popen
FILE *popen(const char *command, const char *type);
int pclose(FILE *stream);
#endif

void bf_compile(char* code){
    FILE *output;
    output = popen ("gcc -x c - $CFLAGS -o /tmp/bf.elf", "w");
    fputs("#include <stdio.h>\n",output);
    fputs("#include <stdlib.h>\n",output);
    fputs("int ptr = 0;",output);
    fputs("unsigned char cell[1024*1024];",output);
    fputs("void main(){",output);
    int i=0;
    for(i=0;code[i];i++){
        switch (code[i]) {
            case '<':
                fputs("ptr--;",output);
                break;
            case '>':
                fputs("ptr++;",output);
                break;
            case '+':
                fputs("cell[ptr]++;",output);
                break;
            case '-':
                fputs("cell[ptr]--;",output);
                break;
            case '[':
                fputs("while(cell[ptr]){",output);
                break;
            case ']':
                fputs("}",output);
                break;
            case '.':
                fputs("putc(cell[ptr],stdout);",output);
                break;
            case ',':
                fputs("cell[ptr] = getchar();",output);
                break;
        }
    }
    fputs("}",output);
    pclose(output);
}

