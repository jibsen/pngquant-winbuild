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

CFLAGS = -std=c99 -Wall -msse2 -mfpmath=sse -O3 -fopenmp \
  -fno-strict-aliasing -fvisibility=hidden
CPPFLAGS = -DNDEBUG -D_LARGEFILE64_SOURCE=1 -DUSE_SSE=1 -DUSE_LCMS=1 \
  -I $(ZDIR) -I $(PDIR) -I $(LDIR)/include

ifeq ($(OS),Windows_NT)
  LDFLAGS += -static -s
  ifeq ($(CC),cc)
    CC = gcc
  endif
endif

objs_lpngq := $(patsubst %.c,%.o,$(wildcard $(QDIR)/lib/*.c))

objs_lpngq_dll := $(patsubst %.c,%.pic.o,$(wildcard $(QDIR)/lib/*.c))

objs_pngq := $(QDIR)/pngquant.o $(QDIR)/rwpng.o

objs_zlib := $(patsubst %.c,%.o,$(wildcard $(ZDIR)/*.c))

# lpng authors were nice enough to put example source in the base folder
objs_lpng := $(PDIR)/png.o $(PDIR)/pngerror.o $(PDIR)/pngget.o \
  $(PDIR)/pngmem.o $(PDIR)/pngpread.o $(PDIR)/pngread.o $(PDIR)/pngrio.o \
  $(PDIR)/pngrtran.o $(PDIR)/pngrutil.o $(PDIR)/pngset.o $(PDIR)/pngtrans.o \
  $(PDIR)/pngwio.o $(PDIR)/pngwrite.o $(PDIR)/pngwtran.o $(PDIR)/pngwutil.o

objs_lcms := $(patsubst %.c,%.o,$(wildcard $(LDIR)/src/*.c))

objs = $(objs_lpngq) $(objs_lpngq_dll) $(objs_zlib) $(objs_lpng) $(objs_lcms)

target = pngquant.exe imagequant.dll

all: $(target)

$(PDIR)/pnglibconf.h: $(PDIR)/scripts/pnglibconf.h.prebuilt
	cp $< $@

$(QDIR)/%.o : $(QDIR)/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

$(QDIR)/lib/%.o : $(QDIR)/lib/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

$(QDIR)/lib/%.pic.o : $(QDIR)/lib/%.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -DIMAGEQUANT_EXPORTS -c -o $@ $<

$(ZDIR)/%.o : $(ZDIR)/%.c
	$(CC) -flto $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

$(PDIR)/%.o : $(PDIR)/%.c
	$(CC) -flto $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

$(LDIR)/src/%.o : $(LDIR)/src/%.c
	$(CC) -flto $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

pngquant.exe: $(objs_pngq) $(objs_lpngq) $(objs_zlib) $(objs_lpng) $(objs_lcms)
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

imagequant.dll: $(objs_lpngq_dll)
	$(CC) -shared $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@ \
	-Wl,--output-def,imagequant.def,--out-implib,imagequant.a

clean:
	$(RM) $(objs) $(target) $(PDIR)/pnglibconf.h

$(QDIR)/lib/libimagequant.o: $(PDIR)/pnglibconf.h

$(QDIR)/pngquant.o: $(PDIR)/pnglibconf.h
