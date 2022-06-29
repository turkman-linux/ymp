#ifndef _archive
#define _archive
#include <sys/types.h>

#include <sys/stat.h>

#include <archive.h>
#include <archive_entry.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <limits.h>

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
    lstat(*filename, &st);
    entry = archive_entry_new(); 
    archive_entry_set_pathname(entry, *filename);
    archive_entry_set_size(entry, st.st_size);
    #ifdef DEBUG
    char* type;
    #endif
    switch (st.st_mode & S_IFMT) {
            case S_IFBLK:
                 // block device
                archive_entry_set_filetype(entry, AE_IFBLK);
                #ifdef DEBUG
                type = "block device";
                #endif
                break;
            case S_IFCHR:
                // character device
                #ifdef DEBUG
                type = "character device";
                #endif
                archive_entry_set_filetype(entry, AE_IFCHR);
                break;
            case S_IFDIR:
                // directory
                #ifdef DEBUG
                type = "directory";
                #endif
                archive_entry_set_filetype(entry, AE_IFDIR);
                break;
            case S_IFIFO:
                // FIFO/pipe
                #ifdef DEBUG
                type = "fifo";
                #endif
                archive_entry_set_filetype(entry, AE_IFIFO);
                break;
            case S_IFLNK:
                // symlink
                #ifdef DEBUG
                type = "symlink";
                #endif
                char link[PATH_MAX];
                if(readlink(*filename,link,sizeof(link)) < 0){
                    fprintf(stderr,"Broken symlink: %s\n",*filename);
                    continue;
                }
                archive_entry_set_filetype(entry, AE_IFLNK);
                archive_entry_set_symlink(entry, link);
                break;
            case S_IFREG:
                // regular file
                #ifdef DEBUG
                type = "file";
                #endif
                archive_entry_set_filetype(entry, AE_IFREG);
                break;
            case S_IFSOCK:
                // socket
                #ifdef DEBUG
                type = "socket";
                #endif
                archive_entry_set_filetype(entry, AE_IFSOCK);
                break;                
            default:
                // unknown
                #ifdef DEBUG
                type = "unknown";
                #endif
                archive_entry_set_filetype(entry, AE_IFREG);
                break;
    }
    #ifdef DEBUG
    fprintf(stderr,"Compress: %s type %s (%d)\n",*filename,type,st.st_mode);
    #endif
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
#endif
