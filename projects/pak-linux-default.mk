#
#   pak-linux-default.mk -- Makefile to build Embedthis Pak for linux
#

NAME                  := pak
VERSION               := 0.9.7
PROFILE               ?= default
ARCH                  ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
CC_ARCH               ?= $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                    ?= linux
CC                    ?= gcc
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
BUILD                 ?= build/$(CONFIG)
LBIN                  ?= $(BUILD)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_EJS            ?= 1
ME_COM_EST            ?= 0
ME_COM_HTTP           ?= 1
ME_COM_OSDEP          ?= 1
ME_COM_PCRE           ?= 1
ME_COM_SQLITE         ?= 0
ME_COM_SSL            ?= 1
ME_COM_VXWORKS        ?= 0
ME_COM_WINSDK         ?= 1
ME_COM_ZLIB           ?= 1

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_EJS),1)
    ME_COM_ZLIB := 1
endif

CFLAGS                += -fPIC -w
DFLAGS                += -D_REENTRANT -DPIC $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
IFLAGS                += "-I$(BUILD)/inc"
LDFLAGS               += '-rdynamic' '-Wl,--enable-new-dtags' '-Wl,-rpath,$$ORIGIN/'
LIBPATHS              += -L$(BUILD)/bin
LIBS                  += -lrt -ldl -lpthread -lm

DEBUG                 ?= debug
CFLAGS-debug          ?= -g
DFLAGS-debug          ?= -DME_DEBUG
LDFLAGS-debug         ?= -g
DFLAGS-release        ?= 
CFLAGS-release        ?= -O2
LDFLAGS-release       ?= 
CFLAGS                += $(CFLAGS-$(DEBUG))
DFLAGS                += $(DFLAGS-$(DEBUG))
LDFLAGS               += $(LDFLAGS-$(DEBUG))

ME_ROOT_PREFIX        ?= 
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local
ME_DATA_PREFIX        ?= $(ME_ROOT_PREFIX)/
ME_STATE_PREFIX       ?= $(ME_ROOT_PREFIX)/var
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)/lib/$(NAME)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)/$(VERSION)
ME_BIN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/bin
ME_INC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/include
ME_LIB_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/lib
ME_MAN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/share/man
ME_SBIN_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local/sbin
ME_ETC_PREFIX         ?= $(ME_ROOT_PREFIX)/etc/$(NAME)
ME_WEB_PREFIX         ?= $(ME_ROOT_PREFIX)/var/www/$(NAME)
ME_LOG_PREFIX         ?= $(ME_ROOT_PREFIX)/var/log/$(NAME)
ME_SPOOL_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)
ME_CACHE_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)/cache
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)$(NAME)-$(VERSION)


ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(BUILD)/bin/ejs.mod
endif
TARGETS               += $(BUILD)/bin/ca.crt
TARGETS               += $(BUILD)/bin/libmprssl.so
TARGETS               += $(BUILD)/bin/pak

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(ME_APP_PREFIX)" = "" ] ; then echo WARNING: ME_APP_PREFIX not set ; exit 255 ; fi
	@[ ! -x $(BUILD)/bin ] && mkdir -p $(BUILD)/bin; true
	@[ ! -x $(BUILD)/inc ] && mkdir -p $(BUILD)/inc; true
	@[ ! -x $(BUILD)/obj ] && mkdir -p $(BUILD)/obj; true
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/pak-linux-default-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/pak-linux-default-me.h >/dev/null ; then\
		cp projects/pak-linux-default-me.h $(BUILD)/inc/me.h  ; \
	fi; true
	@if [ -f "$(BUILD)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != "`cat $(BUILD)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(BUILD)/.makeflags`"" ; \
		fi ; \
	fi
	@echo "$(MAKEFLAGS)" >$(BUILD)/.makeflags

clean:
	rm -f "$(BUILD)/obj/ejsLib.o"
	rm -f "$(BUILD)/obj/ejsc.o"
	rm -f "$(BUILD)/obj/httpLib.o"
	rm -f "$(BUILD)/obj/mprLib.o"
	rm -f "$(BUILD)/obj/mprSsl.o"
	rm -f "$(BUILD)/obj/pak.o"
	rm -f "$(BUILD)/obj/pcre.o"
	rm -f "$(BUILD)/obj/zlib.o"
	rm -f "$(BUILD)/bin/ejsc"
	rm -f "$(BUILD)/bin/ca.crt"
	rm -f "$(BUILD)/bin/libejs.so"
	rm -f "$(BUILD)/bin/libhttp.so"
	rm -f "$(BUILD)/bin/libmpr.so"
	rm -f "$(BUILD)/bin/libmprssl.so"
	rm -f "$(BUILD)/bin/libpcre.so"
	rm -f "$(BUILD)/bin/libzlib.so"
	rm -f "$(BUILD)/bin/pak"

clobber: clean
	rm -fr ./$(BUILD)

#
#   me.h
#

$(BUILD)/inc/me.h: $(DEPS_1)

#
#   osdep.h
#
DEPS_2 += src/paks/osdep/osdep.h
DEPS_2 += $(BUILD)/inc/me.h

$(BUILD)/inc/osdep.h: $(DEPS_2)
	@echo '      [Copy] $(BUILD)/inc/osdep.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/osdep/osdep.h $(BUILD)/inc/osdep.h

#
#   mpr.h
#
DEPS_3 += src/paks/mpr/mpr.h
DEPS_3 += $(BUILD)/inc/me.h
DEPS_3 += $(BUILD)/inc/osdep.h

$(BUILD)/inc/mpr.h: $(DEPS_3)
	@echo '      [Copy] $(BUILD)/inc/mpr.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/mpr/mpr.h $(BUILD)/inc/mpr.h

#
#   http.h
#
DEPS_4 += src/paks/http/http.h
DEPS_4 += $(BUILD)/inc/mpr.h

$(BUILD)/inc/http.h: $(DEPS_4)
	@echo '      [Copy] $(BUILD)/inc/http.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/http/http.h $(BUILD)/inc/http.h

#
#   ejs.slots.h
#

src/paks/ejs/ejs.slots.h: $(DEPS_5)

#
#   pcre.h
#
DEPS_6 += src/paks/pcre/pcre.h

$(BUILD)/inc/pcre.h: $(DEPS_6)
	@echo '      [Copy] $(BUILD)/inc/pcre.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/pcre/pcre.h $(BUILD)/inc/pcre.h

#
#   zlib.h
#
DEPS_7 += src/paks/zlib/zlib.h
DEPS_7 += $(BUILD)/inc/me.h

$(BUILD)/inc/zlib.h: $(DEPS_7)
	@echo '      [Copy] $(BUILD)/inc/zlib.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/zlib/zlib.h $(BUILD)/inc/zlib.h

#
#   ejs.h
#
DEPS_8 += src/paks/ejs/ejs.h
DEPS_8 += $(BUILD)/inc/me.h
DEPS_8 += $(BUILD)/inc/osdep.h
DEPS_8 += $(BUILD)/inc/mpr.h
DEPS_8 += $(BUILD)/inc/http.h
DEPS_8 += src/paks/ejs/ejs.slots.h
DEPS_8 += $(BUILD)/inc/pcre.h
DEPS_8 += $(BUILD)/inc/zlib.h

$(BUILD)/inc/ejs.h: $(DEPS_8)
	@echo '      [Copy] $(BUILD)/inc/ejs.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/ejs/ejs.h $(BUILD)/inc/ejs.h

#
#   ejs.slots.h
#
DEPS_9 += src/paks/ejs/ejs.slots.h

$(BUILD)/inc/ejs.slots.h: $(DEPS_9)
	@echo '      [Copy] $(BUILD)/inc/ejs.slots.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/ejs/ejs.slots.h $(BUILD)/inc/ejs.slots.h

#
#   ejsByteGoto.h
#
DEPS_10 += src/paks/ejs/ejsByteGoto.h

$(BUILD)/inc/ejsByteGoto.h: $(DEPS_10)
	@echo '      [Copy] $(BUILD)/inc/ejsByteGoto.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/ejs/ejsByteGoto.h $(BUILD)/inc/ejsByteGoto.h

#
#   ejs.h
#

src/paks/ejs/ejs.h: $(DEPS_11)

#
#   ejsLib.o
#
DEPS_12 += src/paks/ejs/ejs.h
DEPS_12 += $(BUILD)/inc/mpr.h
DEPS_12 += $(BUILD)/inc/pcre.h
DEPS_12 += $(BUILD)/inc/me.h

$(BUILD)/obj/ejsLib.o: \
    src/paks/ejs/ejsLib.c $(DEPS_12)
	@echo '   [Compile] $(BUILD)/obj/ejsLib.o'
	$(CC) -c -o $(BUILD)/obj/ejsLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/ejs/ejsLib.c

#
#   ejsc.o
#
DEPS_13 += src/paks/ejs/ejs.h

$(BUILD)/obj/ejsc.o: \
    src/paks/ejs/ejsc.c $(DEPS_13)
	@echo '   [Compile] $(BUILD)/obj/ejsc.o'
	$(CC) -c -o $(BUILD)/obj/ejsc.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/ejs/ejsc.c

#
#   http.h
#

src/paks/http/http.h: $(DEPS_14)

#
#   httpLib.o
#
DEPS_15 += src/paks/http/http.h

$(BUILD)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_15)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c -o $(BUILD)/obj/httpLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/http/httpLib.c

#
#   mpr.h
#

src/paks/mpr/mpr.h: $(DEPS_16)

#
#   mprLib.o
#
DEPS_17 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c -o $(BUILD)/obj/mprLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/mpr/mprLib.c

#
#   mprSsl.o
#
DEPS_18 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/mprSsl.o'
	$(CC) -c -o $(BUILD)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/paks/mpr/mprSsl.c

#
#   pak.o
#
DEPS_19 += $(BUILD)/inc/ejs.h

$(BUILD)/obj/pak.o: \
    src/pak.c $(DEPS_19)
	@echo '   [Compile] $(BUILD)/obj/pak.o'
	$(CC) -c -o $(BUILD)/obj/pak.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/pak.c

#
#   pcre.h
#

src/paks/pcre/pcre.h: $(DEPS_20)

#
#   pcre.o
#
DEPS_21 += $(BUILD)/inc/me.h
DEPS_21 += src/paks/pcre/pcre.h

$(BUILD)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c -o $(BUILD)/obj/pcre.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/pcre/pcre.c

#
#   zlib.h
#

src/paks/zlib/zlib.h: $(DEPS_22)

#
#   zlib.o
#
DEPS_23 += $(BUILD)/inc/me.h
DEPS_23 += src/paks/zlib/zlib.h

$(BUILD)/obj/zlib.o: \
    src/paks/zlib/zlib.c $(DEPS_23)
	@echo '   [Compile] $(BUILD)/obj/zlib.o'
	$(CC) -c -o $(BUILD)/obj/zlib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/zlib/zlib.c

#
#   libmpr
#
DEPS_24 += $(BUILD)/inc/osdep.h
DEPS_24 += $(BUILD)/inc/mpr.h
DEPS_24 += $(BUILD)/obj/mprLib.o

$(BUILD)/bin/libmpr.so: $(DEPS_24)
	@echo '      [Link] $(BUILD)/bin/libmpr.so'
	$(CC) -shared -o $(BUILD)/bin/libmpr.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/mprLib.o" $(LIBS) 

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_25 += $(BUILD)/inc/pcre.h
DEPS_25 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.so: $(DEPS_25)
	@echo '      [Link] $(BUILD)/bin/libpcre.so'
	$(CC) -shared -o $(BUILD)/bin/libpcre.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/pcre.o" $(LIBS) 
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_26 += $(BUILD)/bin/libmpr.so
ifeq ($(ME_COM_PCRE),1)
    DEPS_26 += $(BUILD)/bin/libpcre.so
endif
DEPS_26 += $(BUILD)/inc/http.h
DEPS_26 += $(BUILD)/obj/httpLib.o

LIBS_26 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_26 += -lpcre
endif

$(BUILD)/bin/libhttp.so: $(DEPS_26)
	@echo '      [Link] $(BUILD)/bin/libhttp.so'
	$(CC) -shared -o $(BUILD)/bin/libhttp.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/httpLib.o" $(LIBPATHS_26) $(LIBS_26) $(LIBS_26) $(LIBS) 
endif

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_27 += $(BUILD)/inc/zlib.h
DEPS_27 += $(BUILD)/obj/zlib.o

$(BUILD)/bin/libzlib.so: $(DEPS_27)
	@echo '      [Link] $(BUILD)/bin/libzlib.so'
	$(CC) -shared -o $(BUILD)/bin/libzlib.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/zlib.o" $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   libejs
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_28 += $(BUILD)/bin/libhttp.so
endif
ifeq ($(ME_COM_PCRE),1)
    DEPS_28 += $(BUILD)/bin/libpcre.so
endif
DEPS_28 += $(BUILD)/bin/libmpr.so
ifeq ($(ME_COM_ZLIB),1)
    DEPS_28 += $(BUILD)/bin/libzlib.so
endif
DEPS_28 += $(BUILD)/inc/ejs.h
DEPS_28 += $(BUILD)/inc/ejs.slots.h
DEPS_28 += $(BUILD)/inc/ejsByteGoto.h
DEPS_28 += $(BUILD)/obj/ejsLib.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_28 += -lhttp
endif
LIBS_28 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_28 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_28 += -lzlib
endif

$(BUILD)/bin/libejs.so: $(DEPS_28)
	@echo '      [Link] $(BUILD)/bin/libejs.so'
	$(CC) -shared -o $(BUILD)/bin/libejs.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejsLib.o" $(LIBPATHS_28) $(LIBS_28) $(LIBS_28) $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejsc
#
DEPS_29 += $(BUILD)/bin/libejs.so
DEPS_29 += $(BUILD)/obj/ejsc.o

LIBS_29 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_29 += -lhttp
endif
LIBS_29 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_29 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_29 += -lzlib
endif

$(BUILD)/bin/ejsc: $(DEPS_29)
	@echo '      [Link] $(BUILD)/bin/ejsc'
	$(CC) -o $(BUILD)/bin/ejsc $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejsc.o" $(LIBPATHS_29) $(LIBS_29) $(LIBS_29) $(LIBS) $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejs.mod
#
DEPS_30 += src/paks/ejs/ejs.es
DEPS_30 += $(BUILD)/bin/ejsc

$(BUILD)/bin/ejs.mod: $(DEPS_30)
	( \
	cd src/paks/ejs; \
	echo '   [Compile] ejs.mod' ; \
	../../../$(BUILD)/bin/ejsc --out ../../../$(BUILD)/bin/ejs.mod --optimize 9 --bind --require null ejs.es ; \
	)
endif

#
#   http-ca-crt
#
DEPS_31 += src/paks/http/ca.crt

$(BUILD)/bin/ca.crt: $(DEPS_31)
	@echo '      [Copy] $(BUILD)/bin/ca.crt'
	mkdir -p "$(BUILD)/bin"
	cp src/paks/http/ca.crt $(BUILD)/bin/ca.crt

#
#   libmprssl
#
DEPS_32 += $(BUILD)/bin/libmpr.so
DEPS_32 += $(BUILD)/obj/mprSsl.o

LIBS_32 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_32 += -lssl
    LIBPATHS_32 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_32 += -lcrypto
    LIBPATHS_32 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_32 += -lest
endif

$(BUILD)/bin/libmprssl.so: $(DEPS_32)
	@echo '      [Link] $(BUILD)/bin/libmprssl.so'
	$(CC) -shared -o $(BUILD)/bin/libmprssl.so $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/mprSsl.o" $(LIBPATHS_32) $(LIBS_32) $(LIBS_32) $(LIBS) 

#
#   pak.mod
#
DEPS_33 += src/Package.es
DEPS_33 += src/pak.es
DEPS_33 += src/paks/ejs-version/Version.es
ifeq ($(ME_COM_EJS),1)
    DEPS_33 += $(BUILD)/bin/ejs.mod
endif

$(BUILD)/bin/pak.mod: $(DEPS_33)
	./$(BUILD)/bin/ejsc  --out ./$(BUILD)/bin/pak.mod --optimize 9 src/Package.es src/pak.es src/paks/ejs-version/Version.es

#
#   pak
#
ifeq ($(ME_COM_EJS),1)
    DEPS_34 += $(BUILD)/bin/libejs.so
endif
DEPS_34 += $(BUILD)/bin/pak.mod
DEPS_34 += $(BUILD)/obj/pak.o

ifeq ($(ME_COM_EJS),1)
    LIBS_34 += -lejs
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_34 += -lhttp
endif
LIBS_34 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_34 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_34 += -lzlib
endif

$(BUILD)/bin/pak: $(DEPS_34)
	@echo '      [Link] $(BUILD)/bin/pak'
	$(CC) -o $(BUILD)/bin/pak $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/pak.o" $(LIBPATHS_34) $(LIBS_34) $(LIBS_34) $(LIBS) $(LIBS) 

#
#   stop
#

stop: $(DEPS_35)

#
#   installBinary
#

installBinary: $(DEPS_36)
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "0.9.7" "$(ME_APP_PREFIX)/latest" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/pak $(ME_VAPP_PREFIX)/bin/pak ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/pak" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/pak" "$(ME_BIN_PREFIX)/pak" ; \
	if [ "$(ME_COM_OPENSSL)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libssl*.so* $(ME_VAPP_PREFIX)/bin/libssl*.so* ; \
	cp $(BUILD)/bin/libcrypto*.so* $(ME_VAPP_PREFIX)/bin/libcrypto*.so* ; \
	fi ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/ca.crt $(ME_VAPP_PREFIX)/bin/ca.crt ; \
	cp $(BUILD)/bin/ejs.mod $(ME_VAPP_PREFIX)/bin/ejs.mod ; \
	cp $(BUILD)/bin/pak.mod $(ME_VAPP_PREFIX)/bin/pak.mod ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libejs.so $(ME_VAPP_PREFIX)/bin/libejs.so ; \
	cp $(BUILD)/bin/libhttp.so $(ME_VAPP_PREFIX)/bin/libhttp.so ; \
	cp $(BUILD)/bin/libmpr.so $(ME_VAPP_PREFIX)/bin/libmpr.so ; \
	cp $(BUILD)/bin/libmprssl.so $(ME_VAPP_PREFIX)/bin/libmprssl.so ; \
	cp $(BUILD)/bin/libpcre.so $(ME_VAPP_PREFIX)/bin/libpcre.so ; \
	cp $(BUILD)/bin/libzlib.so $(ME_VAPP_PREFIX)/bin/libzlib.so ; \
	if [ "$(ME_COM_EST)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libest.so $(ME_VAPP_PREFIX)/bin/libest.so ; \
	fi ; \
	mkdir -p "$(ME_VAPP_PREFIX)/doc/man/man1" ; \
	cp doc/public/man/pak.1 $(ME_VAPP_PREFIX)/doc/man/man1/pak.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/pak.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man/man1/pak.1" "$(ME_MAN_PREFIX)/man1/pak.1"

#
#   start
#

start: $(DEPS_37)

#
#   install
#
DEPS_38 += stop
DEPS_38 += installBinary
DEPS_38 += start

install: $(DEPS_38)

#
#   uninstall
#
DEPS_39 += stop

uninstall: $(DEPS_39)
	rm -fr "$(ME_VAPP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	rmdir -p "$(ME_APP_PREFIX)" 2>/dev/null ; true

#
#   version
#

version: $(DEPS_40)
	echo 0.9.7

