
#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDManager.h>
#include "logging.h"

@interface Qux:NSObject

@end

@implementation Qux{

  IOHIDManagerRef manager;
}

void inputvaluecallback(void * context,
                        IOReturn err,
                        void * sender,
                        IOHIDValueRef v){
  
  IOHIDElementRef element=IOHIDValueGetElement(v);
  int scancode=IOHIDElementGetUsage(element);
  int type=IOHIDElementGetType(element); /* IOHIDKeys.h */
  
  int iv=IOHIDValueGetIntegerValue(v);

  if (scancode<4 ||scancode>231)
    return; /* http://www.freebsddiary.org/APC/usb_hid_usages.php */
  
  if (iv==1)
    return; /* Key released. */

  DEBUGF("`IOHIDElement': `kIOHIDElementType'=%d usage=%d",
         type,scancode);
  INFOF("Scancode is \033[36m%d\033[0m.",scancode);
  
}


CFDictionaryRef deviceusagecriteria(int page,int usage){
  CFMutableDictionaryRef criteria=
    CFDictionaryCreateMutable(kCFAllocatorDefault,
                              0,
                              &kCFTypeDictionaryKeyCallBacks,
                              &kCFTypeDictionaryValueCallBacks);
  
  CFDictionarySetValue(criteria,
                       CFSTR(kIOHIDDeviceUsagePageKey),
                       CFNumberCreate(kCFAllocatorDefault,
                                      kCFNumberIntType,
                                      &page));                          
  CFDictionarySetValue(criteria,
                       CFSTR(kIOHIDDeviceUsageKey),
                       CFNumberCreate(kCFAllocatorDefault,
                                      kCFNumberIntType,
                                      &usage));
  return criteria;
}

CFArrayRef devicecriteriamultiple(int length,CFDictionaryRef acriteria[]){
  CFMutableArrayRef cfacriteria=CFArrayCreateMutable(kCFAllocatorDefault,
                                  0,
                                  &kCFTypeArrayCallBacks);
  int i;
  for(i=0;i<length;i++){
    CFArrayAppendValue(cfacriteria,acriteria[i]);
    CFRelease(acriteria[i]);
  }

  return cfacriteria;
}



-(void)manager{
  if(manager){
    return;
  }
  
  manager=IOHIDManagerCreate(kCFAllocatorDefault,
                             kIOHIDManagerOptionNone);
  DEBUGF("`IOHIDManager' created: %p.",manager);

  [self setcallback];
  [self setdevices];
    
}

-(void)run{
  if(!manager){
    ERRORF("%s","`IOHIDManager' is absent.");    
    return;
  }
    
  IOHIDManagerOpen(manager,kIOHIDOptionsTypeNone);
  CFRunLoopRun();
}

-(void)setcallback{
  if(!manager)
    return;

  IOHIDManagerRegisterInputValueCallback(manager,
                                         inputvaluecallback,
                                         (__bridge void*)self);
  IOHIDManagerScheduleWithRunLoop(manager,
                                  CFRunLoopGetCurrent(),
                                  kCFRunLoopDefaultMode);

}

-(void)setdevices{
  if(!manager)
    return;

  CFDictionaryRef keyboard=deviceusagecriteria(kHIDPage_GenericDesktop,
                                               kHIDUsage_GD_Keyboard);
  CFDictionaryRef keypad=deviceusagecriteria(kHIDPage_GenericDesktop,
                                             kHIDUsage_GD_Keypad);

  CFArrayRef devices=
    devicecriteriamultiple(2,(CFDictionaryRef []) {keyboard,keypad});

  
  IOHIDManagerSetDeviceMatchingMultiple(manager,devices);
  CFRelease(devices);
}


-(void)dealloc{
  if(manager){
    IOHIDManagerUnscheduleFromRunLoop(manager,
                                      CFRunLoopGetCurrent(),
                                      kCFRunLoopDefaultMode);
    IOHIDManagerClose(manager,kIOHIDManagerOptionNone);
    CFRelease(manager);
  }
}


@end



void runiohidmanager(){
  @autoreleasepool{
    
    Qux *q=[[Qux alloc] init];
    [q manager];
    [q run];    
  }
}
