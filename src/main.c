
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>
#include "logging.h"
#include "scancode.h"
#include "keycode.h"


void usage(){
  char* usage=
    "usage:\n"
    "    listenkey --keycode\n"
    "    listenkey --scancode\n";
  
  fprintf(stderr,"%s",usage);

}

void parsearg(int argc,char **argv,int *mode){

  int o;
  while(1){
    struct option options[]={
      {"scancode",no_argument,mode,1},
      {"keycode",no_argument,mode,2},
    };

    int i;
    o=getopt_long(argc,argv,"s",options,&i);

    if(o==-1)
      break;

    switch(o){
    case 0:
      DEBUGF("option: %s",options[i].name);
      break;
    default:
      usage();
      //DEBUGF("option: %s",options[i].name);      
      exit(EXIT_FAILURE);
    }
  }

  
  if(optind<argc){
    size_t len=0;
    int i=0;
    for(i=optind;i<argc;i++)
      len+=strlen(argv[i])+1;
    char* args=malloc(len);
    args[0]='\0';
    for(i=optind;i<argc;i++){
      strcat(args,argv[i]);
      if(i<argc-1)strcat(args," ");
    }
    DEBUGF("args: %s.",args);
    free(args);
  }
  
}

int main(int argc,char **argv){

  int mode=0;
  parsearg(argc,argv,&mode);

  switch(mode){
  case 0:
    usage();
    exit(EXIT_FAILURE);
  case 1:
    runiohidmanager();    
    break;
  case 2:
    runcgeventtap();
    break;
  default:
    ;
  }
 
  exit(EXIT_SUCCESS);
  
}




