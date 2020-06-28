
#import <Foundation/Foundation.h>
#import <AppKit/NSEvent.h>
#include "logging.h"

@interface Bar:NSObject

@end

@implementation Bar{

  CFMachPortRef tap;
  CFRunLoopSourceRef rls;
}


CGEventRef cgeventtapcallback(CGEventTapProxy p,
                              CGEventType t,
                              CGEventRef cgevent,
                              void *context){
  @autoreleasepool{
    Bar *b=(__bridge Bar*)context;
    
    if(t==kCGEventTapDisabledByTimeout){
      DEBUGF("%s","`CGEventTap' has expired.");      
      return nil;
    }
    if(t==kCGEventTapDisabledByUserInput){
      
      DEBUGF("%s","`CGEventTap' is disabled because of user input.");
      return nil;
    }
    
    [b parseevent:cgevent];
    return cgevent;
  }

}

-(CGEventRef)parseevent:(CGEventRef)cgevent{
  NSEvent *event=[NSEvent eventWithCGEvent:cgevent];

  DEBUGF("%s",[[NSString stringWithFormat:@"`NSEvent':%@",event] UTF8String]);


  if(event.type==NSEventTypeFlagsChanged
     ||event.type==NSEventTypeKeyDown)
  INFOF("Key code is \033[32m%d\033[0m.",event.keyCode);
    
  return cgevent;

}

-(void)cgeventtap{
  if(tap && CGEventTapIsEnabled(tap)){
    return;
  }

  CGEventMask types=
    CGEventMaskBit(kCGEventKeyDown)
    |CGEventMaskBit(kCGEventFlagsChanged)
    |CGEventMaskBit(NSEventTypeSystemDefined);
  
  tap=CGEventTapCreate(kCGSessionEventTap,
                       kCGTailAppendEventTap,
                       kCGEventTapOptionDefault,
                       types,
                       (CGEventTapCallBack)cgeventtapcallback,
                       (__bridge void *)self);

  CGEventTapEnable(tap,true);

  DEBUGF("`CGEventTap' created: %p",tap);
  
  return;
}

-(void)runloopsource{
  if(rls){
    return;
  }
  if(!tap){
    ERRORF("%s","`CGEventTap' is absent.");
    return;
  }
  rls=CFMachPortCreateRunLoopSource(kCFAllocatorDefault,tap,0);
  CFRunLoopRef rl=CFRunLoopGetCurrent();
  CFRunLoopAddSource(rl,rls,kCFRunLoopCommonModes);
  
}

-(void)run{
  CFRunLoopRun();
}


-(void)dealloc{
  DEBUGF("%s","dealloc");
  if(tap){
    CGEventTapEnable(tap,false);
    CFRelease(tap);
  }
  if(rls){
    CFRunLoopRef rl=CFRunLoopGetCurrent();
    CFRunLoopRemoveSource(rl,rls,kCFRunLoopCommonModes);
    CFRelease(rls);
  }
}

@end



void runcgeventtap(){
  @autoreleasepool{

    Bar *b=[[Bar alloc]init];
    [b cgeventtap];
    [b runloopsource];
    [b run];
  }
}
