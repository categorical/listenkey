
#ifndef LOGGING_H
#define LOGGING_H

void debugf(char* format,...);
#ifdef DEBUG
#define DEBUGF(...) debugf(__VA_ARGS__)
#else
#define DEBUGF(...) do{}while(0)
#endif

void infof(char* format,...);
#define INFOF(...) infof(__VA_ARGS__)

void errorf(char* format,...);
#define ERRORF(...) errorf(__VA_ARGS__)

#endif /* LOGGING_H */

