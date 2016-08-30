##
## pngquant
##
## GCC Makefile
##

.SUFFIXES:

.PHONY: clean all

ZDIR = zlib
PDIR = libpng
LDIR = lcms2
QDIR = pngquant

# Building pngquant using -flto may fail on older versions of GCC
CFLAGS = -Wall -O2 -msse -fopenmp -fvisibility=hidden
CPPFLAGS = -DNDEBUG -D_LARGEFILE64_SOURCE=1 -DUSE_SSE=1 -DUSE_LCMS=1 \
  -DIMAGEQUANT_EXPORTS \
  -I $(ZDIR) -I $(PDIR) -I $(LDIR)/include

pngq_flags = -fno-math-errno -funroll-loops -fomit-frame-pointer \
  -fexcess-precision=fast -fno-strict-aliasing

ifeq ($(OS),Windows_NT)
  LDFLAGS += -static -s
  ifeq ($(CC),cc)
    CC = gcc
  endif
endif

objs_lpngq := $(patsubst %.c,%.o,$(wildcard $(QDIR)/lib/*.c))

objs_pngq := $(QDIR)/pngquant.o $(QDIR)/rwpng.o

objs_zlib := $(patsubst %.c,%.o,$(wildcard $(ZDIR)/*.c))

# lpng authors were nice enough to put example source in the base folder
objs_lpng := $(PDIR)/png.o $(PDIR)/pngerror.o $(PDIR)/pngget.o \
  $(PDIR)/pngmem.o $(PDIR)/pngpread.o $(PDIR)/pngread.o $(PDIR)/pngrio.o \
  $(PDIR)/pngrtran.o $(PDIR)/pngrutil.o $(PDIR)/pngset.o $(PDIR)/pngtrans.o \
  $(PDIR)/pngwio.o $(PDIR)/pngwrite.o $(PDIR)/pngwtran.o $(PDIR)/pngwutil.o

objs_lcms := $(patsubst %.c,%.o,$(wildcard $(LDIR)/src/*.c))

objs = $(objs_lpngq) $(objs_zlib) $(objs_lpng) $(objs_lcms)

target = pngquant.exe imagequant.dll

all: $(target)

$(PDIR)/pnglibconf.h: $(PDIR)/scripts/pnglibconf.h.prebuilt
	cp $< $@

$(QDIR)/%.o : $(QDIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(pngq_flags) -c -o $@ $<

$(QDIR)/lib/%.o : $(QDIR)/lib/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(pngq_flags) -c -o $@ $<

$(ZDIR)/%.o : $(ZDIR)/%.c
	$(CC) -flto $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

$(PDIR)/%.o : $(PDIR)/%.c
	$(CC) -flto $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

$(LDIR)/src/%.o : $(LDIR)/src/%.c
	$(CC) -flto -fno-strict-aliasing $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

pngquant.exe: $(objs_pngq) $(objs_lpngq) $(objs_zlib) $(objs_lpng) $(objs_lcms)
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

imagequant.dll: $(objs_lpngq)
	$(CC) -shared $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@ \
	-Wl,--output-def,imagequant.def,--out-implib,imagequant.a

clean:
	$(RM) $(objs) $(target) $(PDIR)/pnglibconf.h

$(QDIR)/lib/libimagequant.o: $(PDIR)/pnglibconf.h

$(QDIR)/pngquant.o: $(PDIR)/pnglibconf.h
