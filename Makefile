

CC=gcc
LDFLAGS=\
-framework Foundation \
-framework AppKit \
-framework ApplicationServices \
-framework IOKit
CFLAGS=\
-fobjc-arc
#CPPFLAGS=-DDEBUG
CPPFLAGS=-DDEBUG

EXECUTABLEDIR=bin
EXECUTABLE=$(EXECUTABLEDIR)/listenkey
SRCDIR=src
OBJDIR=obj
SRCS=$(wildcard $(SRCDIR)/*.c $(SRCDIR)/*.m)
OBJS=$(filter %.o,\
$(SRCS:$(SRCDIR)/%.c=$(OBJDIR)/%.o) \
$(SRCS:$(SRCDIR)/%.m=$(OBJDIR)/%.o))


all: run

$(OBJDIR)/%.o:$(SRCDIR)/%.c
	@mkdir -p $(OBJDIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

$(OBJDIR)/%.o:$(SRCDIR)/%.m
	@mkdir -p $(OBJDIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

build: $(OBJS)
	@mkdir -p $(EXECUTABLEDIR)
	$(CC) $(LDFLAGS) -o $(EXECUTABLE) $^

run: build
	sudo ./$(EXECUTABLE) --keycode

clean:
	rm -R $(EXECUTABLEDIR)
	rm -R $(OBJDIR)

.PHONY: clean all run build


