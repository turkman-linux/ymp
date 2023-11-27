#ifndef _string
#define _string
#include <stddef.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>

/*generic counters*/
long i;
long j;
long cnt = 0;
long len = 0;

int iseq(char* str1, char* str2){
    return strcmp(str1,str2) == 0;
}

static int string_compare(const void* a, const void* b){
    return strcmp(*(const char**)a, *(const char**)b);
}

void csort(const char* arr[], int n){
    qsort(arr, n, sizeof(const char*), string_compare);
}

long count_tab(char* data){
    cnt = 0;
    while (*data == ' ') {
        cnt++;
        data++;
    }
    return cnt;
}

char* join(char* f, char** array){
    i = 0;
    len = 0;
    /* find output size */
    while(array[i]){
        len += strlen(array[i]) + strlen(f);
        i++;
    }
    /* allocate memory */
    char* ret = calloc(len+1, sizeof(char));
    strcpy(ret,"");
    /* copy item len and reset value */
    cnt = i;
    i = 0;
    /* copy items */
    while(array[i]){
        strcat(ret,array[i]);
        if(i<cnt-1){
            strcat(ret,f);
        }
	i++;
    }
    return ret;
}

char* str_add(char* str1, char* str2){
    char* ret = calloc( (strlen(str1)+strlen(str2)+1),sizeof(char) );
    strcpy(ret,str1);
    strcat(ret,str2);
    return ret;
}

char* trim(char* data) {
    i=0;
    j=0;
    cnt=0;
    len = strlen(data);
    char* str = calloc(len+1, sizeof(char));
    strcpy(str,data);
    cnt = count_tab (data);
    j=cnt-1;
    for(i=0; i<len; i++) {
        j += 1;
        if(j >= len || str[i] == '\0') {
            str[i] = '\0';
            break;
        }
        str[i] = data[j];
        if(str[i] == '\n'){
            j += cnt;

        }
    }
    return str;
}

char* int_to_string(int num){
    char *ret = calloc(((sizeof(num) - 1) / 3 + 2), sizeof(char));
    sprintf(ret, "%d", num);
    return ret;
}

#define isalnum_c(A) \
    (A >= 'A' && A <= 'Z') || \
    (A >= 'a' && A <= 'z') || \
    (A >= '0' && A <= '9') || \
    A == '-' || A == '_' || A == '.' || A == '~'

/* Function to check if a character is a hexadecimal digit */
#define isHexDigit(A) \
    (A >= '0' && A <= '9') || \
    (A >= 'A' && A <= 'F') || \
    (A >= 'a' && A <= 'f')


/* Function to perform URL decoding */
char* url_decode(const char *input) {
    cnt = 0;
    for (i = 0; input[i] != '\0'; i++) {
        if (input[i] == '%'){
           if (isHexDigit(input[i + 1])){
               if (isHexDigit(input[i + 2])) {
                   /* Skip '%', and the next two characters (assuming they are valid hexadecimal digits) */
                   i += 2;
                   cnt++;
                }
            }
        } else {
            cnt++;
        }
    }

    /* +1 for null-terminator */
    char *output = (char *)calloc((cnt + 1), sizeof(char));

    if (output == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        return (char*) input;
    }

    j = 0;
    for (i = 0; input[i] != '\0'; i++) {
        if (input[i] == '%') {
            if (isHexDigit(input[i + 1])){
                if (isHexDigit(input[i + 2])) {
                    char hex[3] = {input[i + 1], input[i + 2], '\0'};
                    output[j++] = (char)strtol(hex, NULL, 16);
                    /* Skip '%', and the next two characters */
                    i += 2;
                }
            }
        } else {
            output[j++] = input[i];
        }
    }
    /* Null-terminate the output string */
    output[j] = '\0';

    return output;
}

/* Function to perform URL encoding */
char* url_encode(const char *input) {
    cnt = 0;
    for (i = 0; input[i] != '\0'; i++) {
        if (!isalnum_c(input[i])) {
            /* Two characters for % and the hexadecimal digit */
            cnt += 2;
        } else {
            cnt++;
        }
    }

    /* +1 for null-terminator */
    char *output = (char *)malloc((cnt + 1) * sizeof(char));

    if (output == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        return (char*) input;
    }

    j = 0;
    for (i = 0; input[i] != '\0'; i++) {
        if (isalnum_c(input[i])) {
            output[j++] = input[i];
        } else {
            sprintf(output + j, "%%%02X", (unsigned char)input[i]);
            /* Move to the next position in the output string */
            j += 3;
        }
    }
    /* Null-terminate the output string */
    output[j] = '\0';

    return output;
}


int endswith(const char* data, const char* f) {
    i = strlen(data);
    j = strlen(f);

    if (i < j) {
        return 0;
    }

    return strcmp(data + i - j, f) == 0;
}

int startswith(const char* data, const char* f) {
    i = strlen(data);
    j = strlen(f);

    if (i < j) {
        return 0;
    }

    return strncmp(data, f, j) == 0;
}

char medium_buffer[1024*1024];
char* build_string(char* format, ...){
    strcpy(medium_buffer,"");
    va_list args;
    va_start (args, format);
    vsprintf (medium_buffer, format, args);
    va_end (args);
    return medium_buffer;

}


#endif
