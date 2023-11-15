#ifndef _archive
#define _archive


#define zip 0
#define tar 1
#define p7zip 2
#define cpio 3
#define ar 4

#define filter_none 0
#define filter_gzip 1
#define filter_xz 2

int aformat = 1;
int afilter = 0;

#define _XOPEN_SOURCE 700

#ifndef no_libarchive
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

#ifndef PATH_MAX
#define PATH_MAX 1024
#endif

#ifdef __STRICT_ANSI__
/* lstat missing if code is ansi */
int lstat(const char *pathname, struct stat *statbuf);
#endif

#ifndef get_bool
int get_bool(char*variable);
#endif

#ifndef isexists
int isexists(const char*path);
#endif

#ifndef error_add
void error_add(char* msg);
void debug(char* msg);
int has_error();
void error(int num);
#endif

void set_archive_type(char* form, char* filt){
    debug("Archive type changed");
    debug(form);
    debug(filt);
    if(strcmp(form,"zip")==0)
        aformat=zip;
    else if(strcmp(form,"tar")==0)
        aformat=tar;
    else if(strcmp(form,"p7zip")==0)
        aformat=p7zip;
    else if(strcmp(form,"cpio")==0)
        aformat=cpio;
    else if(strcmp(form,"ar")==0)
        aformat=ar;

    if(strcmp(filt,"none")==0)
        afilter=filter_none;
    else if(strcmp(filt,"gzip")==0)
        afilter=filter_gzip;
    else if(strcmp(filt,"xz")==0)
        afilter=filter_xz;
}

void write_archive(const char *outname, const char **filename) {
  struct archive *a;
  struct archive_entry *entry;
  struct stat st;
  char buff[8192];
  int len;
  int fd;
  int e;

  a = archive_write_new();
  /* compress format */
  if(afilter == filter_gzip){
      archive_write_add_filter_gzip(a);
  }else if(afilter == filter_xz){
      archive_write_add_filter_xz(a);
  }else{
      archive_write_add_filter_none(a);
  }
  /* archive format */
  if(aformat == tar){
      e = (archive_write_set_format_gnutar(a) != ARCHIVE_OK);
  }else if (aformat == p7zip){
      e = (archive_write_set_format_7zip(a) != ARCHIVE_OK);
  }else if (aformat == cpio){
      e = (archive_write_set_format_cpio(a) != ARCHIVE_OK);
  }else if (aformat == ar){
      e = (archive_write_set_format_ar_bsd(a) != ARCHIVE_OK);
  }else{
      e = (archive_write_set_format_zip(a) != ARCHIVE_OK);
  }
  if (e){
      error_add("Libarchive error!");
      return;
  }
  
  archive_write_open_filename(a, outname);
  char link[PATH_MAX];
  #ifdef DEBUG
  char* type;
  #endif
  entry = NULL;
  while (*filename) {
    if(!isexists(*filename)){
        fprintf(stderr,"Non-existent enty detected: %s\n",*filename);
        continue;
    }
    lstat(*filename, &st);
    entry = archive_entry_new();
    archive_entry_set_pathname(entry, *filename);
    archive_entry_set_size(entry, st.st_size);
    if (S_ISBLK(st.st_mode)) {
        /* block device */
        archive_entry_set_filetype(entry, AE_IFBLK);
        #ifdef DEBUG
        type = "block device";
        #endif
    } else if (S_ISCHR(st.st_mode)) {
        /* character device */
        #ifdef DEBUG
        type = "character device";
        #endif
        archive_entry_set_filetype(entry, AE_IFCHR);
    } else if (S_ISDIR(st.st_mode)) {
        /* directory */
        #ifdef DEBUG
        type = "directory";
        #endif
        archive_entry_set_filetype(entry, AE_IFDIR);
    } else if (S_ISDIR(st.st_mode)) {
        /* FIFO/pipe */
        #ifdef DEBUG
        type = "fifo";
        #endif
        archive_entry_set_filetype(entry, AE_IFIFO);
    } else if (S_ISLNK(st.st_mode)) {
        /* symlink */
        #ifdef DEBUG
        type = "symlink";
        #endif
        len = readlink(*filename,link,sizeof(link));
        if(len < 0){
            fprintf(stderr,"Broken symlink: %s\n",*filename);
            error_add("Failed to create archive");
            break;
        }
        link[len] = '\0';
        #ifdef DEBUG
        if(get_bool("debug")){
            fprintf(stderr,"Symlink: %s %s\n",*filename, link);
        }
        #endif
        archive_entry_set_filetype(entry, AE_IFLNK);
        archive_entry_set_symlink(entry, link);
    } else if (S_ISREG(st.st_mode)) {
        /* regular file */
        #ifdef DEBUG
        type = "file";
        #endif
        archive_entry_set_filetype(entry, AE_IFREG);
    } else if (S_ISSOCK(st.st_mode)) {
        /* socket */
        #ifdef DEBUG
        type = "socket";
        #endif
        archive_entry_set_filetype(entry, AE_IFSOCK);
     } else {
        /* unknown */
        #ifdef DEBUG
        type = "unknown";
        #endif
        archive_entry_set_filetype(entry, AE_IFREG);
        fprintf(stderr,"Unknown enty detected: %s (%d %d)\n",*filename,st.st_mode,AE_IFREG);
        error_add("Failed to create archive");
    }
    if(has_error()){
        error(2);
    }
    #ifdef DEBUG
    if(get_bool("debug")){
        fprintf(stderr,"Compress: %s type %s (%d)\n",*filename,type,st.st_mode);
    }
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
    filename++;
  }
  archive_entry_free(entry);
  archive_write_close(a);
  archive_write_free(a);
}
#endif
#endif
