#ifdef libcurl
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <curl/curl.h>

#include <logger.h>
#include <error.h>
#include <value.h>


#ifdef __STRICT_ANSI__
#define strdup(A) strcpy(calloc(strlen(A) + 1, sizeof(char)), A)
#endif

#ifndef PATH_MAX
#define PATH_MAX 1024
#endif

static size_t write_data_to_file(void *ptr, size_t size, size_t nmemb, void *stream){
  size_t written = fwrite(ptr, size, nmemb, (FILE *)stream);
  return written;
}

struct string {
  char *ptr;
  size_t len;
};

struct progress {
  char *filename;
  time_t start_time;
};

void init_string(struct string *s) {
  s->len = 0;
  s->ptr = calloc(1, s->len+1);
  if (s->ptr == NULL) {
    ferror_add("calloc() failed\n");
    error(1);
  }
  s->ptr[0] = '\0';
}


static size_t write_data_to_string(void *ptr, size_t size, size_t nmemb, void *stream){
  struct string *s = stream;
  size_t new_len = s->len + size*nmemb;
  s->ptr = realloc(s->ptr, new_len+1);
  if (s->ptr == NULL) {
    ferror_add( "realloc() failed\n");
    error(1);
  }
  memcpy(s->ptr+s->len, ptr, size*nmemb);
  s->ptr[new_len] = '\0';
  s->len = new_len;

  return size*nmemb;
}


int fetcher_process_to_stderr(void *p, curl_off_t total, curl_off_t current, curl_off_t TotalToUpload, curl_off_t NowUploaded) {
    struct progress *data = p;
    if (total > 0) {
        /* Calculate percentage */
        double percentage = (double)current / total * 100.0;

        /* Calculate elapsed time */
        time_t now = time(NULL);
        double elapsed_time = difftime(now, data->start_time); /* in seconds */

        /* Calculate speed (bytes per second) */
        double speed = (elapsed_time > 0) ? current / elapsed_time : 0; /* bytes per second */

        /* Calculate ETA (in seconds) */
        double remaining = total - current;
        double eta = (speed > 0) ? remaining / speed : 0; /* in seconds */

        /* Format speed and ETA */
        char speed_str[20];
        char eta_str[20];
        snprintf(speed_str, sizeof(speed_str), "%s/s", g_format_size(speed));
        snprintf(eta_str, sizeof(eta_str), "%.0f s", eta);

        /* Print formatted output */
        fprintf(stderr, "\33[2K\r%6.2f%% %s  %s/%s  Speed: %s  ETA: %s", 
                percentage, data->filename, g_format_size(current), g_format_size(total), speed_str, eta_str);
        fflush(stderr);
    }
    return 0;
}

int fetcher_process_to_dummy(void *p, curl_off_t total, curl_off_t current, curl_off_t TotalToUpload, curl_off_t NowUploaded){
    return 0;
}

void curl_options_common(CURL *curl, char* url){
        struct curl_slist *chunk = NULL;
        chunk = curl_slist_append(chunk, "Connection: keep-alive");
        chunk = curl_slist_append(chunk, "DNT: 1");
        chunk = curl_slist_append(chunk, "Sec-GPC: 1");
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
        if (get_bool("progressbar") || getenv("PROGRESSBAR")){
            curl_easy_setopt(curl, CURLOPT_XFERINFOFUNCTION, fetcher_process_to_stderr);
        } else {
            curl_easy_setopt(curl, CURLOPT_XFERINFOFUNCTION, fetcher_process_to_dummy);
        }
        if (strcmp(get_value("ignore-ssl"),"true")==0){
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
        }
}

int fetch(char* url, char* path){
    FILE *fp;
    char fetcher_filename[PATH_MAX];
    strcpy(fetcher_filename,path);
    CURL* curl=curl_easy_init();
    finfo("Downloading: %s\n",path);
    fp = fopen(path,"wb");
    if(fp == NULL) {
        ferror_add("Failed to open file for write: %s\n", path);
        return 1;
    }
    curl_options_common(curl, url);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data_to_file);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
    struct progress data;
    data.filename = strdup(path);
    data.start_time = time(NULL);
    curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, &data);
    CURLcode res;
    res = curl_easy_perform(curl);
    if(res != CURLE_OK || res == CURLE_HTTP_RETURNED_ERROR){
        ferror_add("curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
        curl_easy_cleanup(curl);
        return 0;
    }
    curl_easy_cleanup(curl);
    fclose(fp);
    return 1;
}


char* fetch_string(char* url){
    CURL* curl=curl_easy_init();
    struct string s;
    init_string(&s);
    char fetcher_filename[PATH_MAX];
    strcpy(fetcher_filename,"");
    curl_options_common(curl, url);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data_to_string);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &s);
    CURLcode res;
    res = curl_easy_perform(curl);
    if(res != CURLE_OK){
        ferror_add("curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
        return (char*)(s.ptr);
    }
    curl_easy_cleanup(curl);
    return (char*)(s.ptr);
}


#endif
