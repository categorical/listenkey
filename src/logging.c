
#include <stdio.h>
#include <stdarg.h>
#include <time.h>

unsigned long ts(){
  
  return (unsigned long)time(0);
}

void debugf(char* format,...){
  va_list args;
  va_start(args,format);
  fprintf(stderr,"\033[37m%lu\033[0m: ",ts());
  vfprintf(stderr,format,args);
  putchar('\n');
  va_end(args);
}

void errorf(char* format,...){
  va_list args;
  va_start(args,format);
  fprintf(stderr,"\033[31m%lu\033[0m: ",ts());
  vfprintf(stderr,format,args);
  putchar('\n');
  va_end(args);
}

void infof(char* format,...){
  va_list args;
  va_start(args,format);
  fprintf(stderr,"\033[34m%lu\033[0m: ",ts());
  vfprintf(stdout,format,args);
  putchar('\n');
  va_end(args);
}

