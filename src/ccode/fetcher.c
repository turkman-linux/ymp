#ifndef no_libcurl
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <curl/curl.h>

#ifndef get_value
char* get_value(char* variable);;
#endif

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

int fetcher_process_to_vala(void *p, curl_off_t total, curl_off_t current, curl_off_t TotalToUpload, curl_off_t NowUploaded){
    return fetcher_vala(current, total, fetcher_filename);
}

CURL *curl;
void curl_options_common(char* url){
        struct curl_slist *chunk = NULL;
        chunk = curl_slist_append(chunk, "Connection: keep-alive");
        chunk = curl_slist_append(chunk, "DNT: 1");
        chunk = curl_slist_append(chunk, "Ymp: \"NE MUTLU TURKUM DIYENE\"");
        if(strcmp(get_value("debug"),"true")==0){
            curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
        }
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, chunk);
        curl_easy_setopt(curl, CURLOPT_URL, url);
        curl_easy_setopt(curl, CURLOPT_USERAGENT, get_value("useragent"));
        curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 0L);
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        curl_easy_setopt(curl, CURLOPT_TCP_KEEPALIVE, 1L);
        curl_easy_setopt(curl, CURLOPT_ACCEPT_ENCODING, "");
        curl_easy_setopt(curl, CURLOPT_XFERINFOFUNCTION, fetcher_process_to_vala);
        if(strcmp(get_value("ignore-ssl"),"true")==0){
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
        }
}

int fetch(char* url, char* path){
    FILE *fp;
    strcpy(fetcher_filename,path);
    curl=curl_easy_init();
    printf("Downloading: %s\n",path);
    if (curl){
        fp = fopen(path,"wb");
        curl_options_common(url);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data_to_file);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
        CURLcode res;
        res = curl_easy_perform(curl);
        if(res != CURLE_OK || res == CURLE_HTTP_RETURNED_ERROR){
          fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
          curl_easy_cleanup(curl);
          return 0;
        }
        curl_easy_cleanup(curl);
        fclose(fp);
    }
    return 1;
}


char* fetch_string(char* url){
    curl=curl_easy_init();
    struct string s;
    init_string(&s);
    strcpy(fetcher_filename,"");
    if (curl){
        curl_options_common(url);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data_to_string);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &s);
        CURLcode res;
        res = curl_easy_perform(curl);
        if(res != CURLE_OK){
          fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
          return (char*)(s.ptr);
        }
        curl_easy_cleanup(curl);
    }
    return (char*)(s.ptr);
}

char* url_encode(char* data){
    curl=curl_easy_init();
    char* ret = curl_easy_escape(curl, data, strlen(data));
    return ret;
}

char* url_decode(char* data){
    int i=0;
    char* ret = curl_easy_unescape(curl, data, strlen(data), &i);
    return ret;
}

# else
char* url_encode(char* data){
    //FIXME: write non-curl url encode function
    return data;
}
char* url_decode(char* data){
    //FIXME: write non-curl url decode function
    return data;
}

#endif
