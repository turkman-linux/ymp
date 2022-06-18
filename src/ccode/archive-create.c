#include <sys/types.h>

#include <sys/stat.h>

#include <archive.h>
#include <archive_entry.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define zip 0
#define tar 1

int aformat = 1;

#define filter_none 0
#define filter_gzip 1

int afilter = 0;

void write_archive(const char *outname, const char **filename) {
  struct archive *a;
  struct archive_entry *entry;
  struct stat st;
  char buff[8192];
  int len;
  int fd;

  a = archive_write_new();
  if(afilter == filter_none)
      archive_write_add_filter_none(a);
  if(afilter == filter_gzip)
      archive_write_add_filter_gzip(a);
  if(aformat == zip)
      archive_write_set_format_zip(a);
  if(aformat == tar)
      archive_write_set_format_pax_restricted(a);
  archive_write_open_filename(a, outname);
  while (*filename) {
    stat(*filename, &st);
    entry = archive_entry_new(); 
    archive_entry_set_pathname(entry, *filename);
    archive_entry_set_size(entry, st.st_size);
    archive_entry_set_filetype(entry, AE_IFREG);
    archive_entry_set_perm(entry, 0644);
    archive_write_header(a, entry);
    fd = open(*filename, O_RDONLY);
    len = read(fd, buff, sizeof(buff));
    while ( len > 0 ) {
        archive_write_data(a, buff, len);
        len = read(fd, buff, sizeof(buff));
    }
    close(fd);
    archive_entry_free(entry);
    filename++;
  }
  archive_write_close(a);
  archive_write_free(a);
}
