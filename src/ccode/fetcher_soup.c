#ifdef libsoup

#include <libsoup/soup.h>
#include <string.h>

int fetch (char* url, char* path){
    GError *error = NULL;
    SoupSession * session = soup_session_new();
    SoupMessage * msg = soup_message_new(SOUP_METHOD_GET, url);
    GInputStream * in_stream = soup_session_send(
        session,
        msg,
        NULL,
        &error);
    GFile * output_file = g_file_new_for_path(path);
    GFileOutputStream * out_stream = g_file_create(output_file,
        G_FILE_CREATE_NONE, NULL, NULL);
    g_output_stream_splice((GOutputStream * ) out_stream, in_stream,
        G_OUTPUT_STREAM_SPLICE_CLOSE_SOURCE | G_OUTPUT_STREAM_SPLICE_CLOSE_TARGET,
        NULL, &error);
    if(error){
        return 0;
    }
    return 1;
}

char* fetch_string(char* url){
    GError *error = NULL;
    SoupSession * session = soup_session_new();
    SoupMessage * msg = soup_message_new(SOUP_METHOD_GET, url);
    GBytes *bytes = soup_session_send_and_read (
        session,
        msg,
        NULL,
        &error);
    if(error){
        return 0;
    }
    return strdup((char*)g_bytes_get_data(bytes,NULL));   
}

#endif
