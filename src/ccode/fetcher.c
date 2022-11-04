#ifndef no_libcurl
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <curl/curl.h>

static size_t write_data_to_file(void *ptr, size_t size, size_t nmemb, void *stream){
  size_t written = fwrite(ptr, size, nmemb, (FILE *)stream);
  return written;
}

struct string {
  char *ptr;
  size_t len;
};

void init_string(struct string *s) {
  s->len = 0;
  s->ptr = malloc(s->len+1);
  if (s->ptr == NULL) {
    fprintf(stderr, "malloc() failed\n");
    exit(EXIT_FAILURE);
  }
  s->ptr[0] = '\0';
}


static size_t write_data_to_string(void *ptr, size_t size, size_t nmemb, void *stream){
  struct string *s = stream;
  size_t new_len = s->len + size*nmemb;
  s->ptr = realloc(s->ptr, new_len+1);
  if (s->ptr == NULL) {
    fprintf(stderr, "realloc() failed\n");
    exit(EXIT_FAILURE);
  }
  memcpy(s->ptr+s->len, ptr, size*nmemb);
  s->ptr[new_len] = '\0';
  s->len = new_len;

  return size*nmemb;
}

char fetcher_filename[PATH_MAX];

int fetcher_vala(double current, double total, char* filename);
int fetcher_process_to_vala(void* ptr, double total, double current, double TotalToUpload, double NowUploaded){
    fetcher_vala(current, total, fetcher_filename);
    return 0;
}



int fetch(char* url, char* path){
    CURL *curl;
    FILE *fp;
    strcpy(fetcher_filename,path);
    curl=curl_easy_init();
    if (curl){
        fp = fopen(path,"wb");
        curl_easy_setopt(curl, CURLOPT_URL, url);
        curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 0L);
        curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, fetcher_process_to_vala);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data_to_file);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
        CURLcode res;
        res = curl_easy_perform(curl);
        if(res != CURLE_OK){
          fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
        }
        curl_easy_cleanup(curl);
        fclose(fp);
    }
    return 0;
}

char* fetch_string(char* url){
    CURL *curl;
    curl=curl_easy_init();
    struct string s;
    init_string(&s);
    strcpy(fetcher_filename,"");
    if (curl){
        curl_easy_setopt(curl, CURLOPT_URL, url);
        curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 0L);
        curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, fetcher_process_to_vala);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data_to_string);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &s);
        CURLcode res;
        res = curl_easy_perform(curl);
        if(res != CURLE_OK){
          fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
        }

        curl_easy_cleanup(curl);
    }
    printf("%lu bytes retrieved\n", (unsigned long)s.len);
    printf("%s bytes retrieved\n", (char*)s.ptr);
    return (char*)(s.ptr);
}
#endif