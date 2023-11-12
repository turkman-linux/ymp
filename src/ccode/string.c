#ifndef _string
#define _string
#include <stddef.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>

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
    long cnt=0;
    long i=0;
    for(i=0; data[i]==' '; i++) {
        cnt++;
    }
    return cnt;
}

char* join(char* f, char** array){
    size_t len = 0;
    int i = 0;
    int c = 0;
    /* find output size */
    while(array[i]){
        len += strlen(array[i]) + strlen(f);
        i++;
    }
    /* allocate memory */
    char* ret = calloc(len+1, sizeof(char));
    strcpy(ret,"");
    /* copy item len and reset value */
    c = i;
    i = 0;
    /* copy items */
    while(array[i]){
        strcat(ret,array[i]);
        if(i<c-1){
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
    long i=0, j= 0, cnt=0;
    long len = strlen(data);
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

int isalnum(char ch) {
    return (ch >= 'A' && ch <= 'Z') ||
           (ch >= 'a' && ch <= 'z') ||
           (ch >= '0' && ch <= '9') ||
           ch == '-' || ch == '_' || ch == '.' || ch == '~';
}

/* Function to check if a character is a hexadecimal digit */
int isHexDigit(char ch) {
    return (ch >= '0' && ch <= '9') ||
           (ch >= 'A' && ch <= 'F') ||
           (ch >= 'a' && ch <= 'f');
}

/* Function to convert a hexadecimal character to its integer value */
int hexToInt(char ch) {
    if (ch >= '0' && ch <= '9') {
        return ch - '0';
    } else if (ch >= 'A' && ch <= 'F') {
        return ch - 'A' + 10;
    } else if (ch >= 'a' && ch <= 'f') {
        return ch - 'a' + 10;
    } else {
        /* Invalid character */
        return -1;
    }
}
int i;

/* Function to perform URL decoding */
char* url_decode(const char *input) {
    int decodedLength = 0;
    for (i = 0; input[i] != '\0'; i++) {
        if (input[i] == '%' && isHexDigit(input[i + 1]) && isHexDigit(input[i + 2])) {
            /* Skip '%', and the next two characters (assuming they are valid hexadecimal digits) */
            i += 2;
            decodedLength++;
        } else {
            decodedLength++;
        }
    }

    /* +1 for null-terminator */
    char *output = (char *)malloc((decodedLength + 1) * sizeof(char));

    if (output == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        return (char*) input;
    }

    int j = 0;
    for (i = 0; input[i] != '\0'; i++) {
        if (input[i] == '%' && isHexDigit(input[i + 1]) && isHexDigit(input[i + 2])) {
            char hex[3] = {input[i + 1], input[i + 2], '\0'};
            output[j++] = (char)strtol(hex, NULL, 16);
            /* Skip '%', and the next two characters */
            i += 2;
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
    int encodedLength = 0;
    for (i = 0; input[i] != '\0'; i++) {
        if (!isalnum(input[i])) {
            /* Two characters for % and the hexadecimal digit */
            encodedLength += 2;
        } else {
            encodedLength++;
        }
    }

    /* +1 for null-terminator */
    char *output = (char *)malloc((encodedLength + 1) * sizeof(char));

    if (output == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        return (char*) input;
    }

    int j = 0;
    for (i = 0; input[i] != '\0'; i++) {
        if (isalnum(input[i])) {
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

#endif
