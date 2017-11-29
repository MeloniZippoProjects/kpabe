top_srcdir = .
prefix = /usr/local
exec_prefix = ${prefix}
bindir = ${exec_prefix}/bin
mandir = ${prefix}/share/man

CC = gcc
CFLAGS  = -O3 -Wall \
	 \
	-I/usr/include/pbc -I/usr/local/include/pbc \
	-I/usr/local/include/ \
	-I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include \
	-DPACKAGE_NAME=\"kpabe\" -DPACKAGE_TARNAME=\"kpabe\" -DPACKAGE_VERSION=\"0.3\" -DPACKAGE_STRING=\"kpabe\ 0.3\" -DPACKAGE_BUGREPORT=\"zhengyao@wpi.edu\" -DPACKAGE_URL=\"\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DSTDC_HEADERS=1 -DHAVE_FCNTL_H=1 -DHAVE_STDDEF_H=1 -DHAVE_STRING_H=1 -DHAVE_STDLIB_H=1 -DHAVE_MALLOC=1 -DLSTAT_FOLLOWS_SLASHED_SYMLINK=1 -DHAVE_VPRINTF=1 -DHAVE_LIBCRYPTO=1 -DHAVE_LIBCRYPTO=1 -DHAVE_STRCHR=1 -DHAVE_STRDUP=1 -DHAVE_MEMSET=1 -DHAVE_GMP=1 -DHAVE_PBC=1 -DHAVE_CELIA=1
LDFLAGS = -O3 -Wall \
	-lcelia \
	-Wl,-rpath /usr/local/lib -lpbc \
	-L/usr/local/lib/ -Wl,-rpath /usr/local/lib/ -Wl,-rpath /usr/local/lib -lgmp \
	-lglib-2.0 -lintl \
	-lcrypto -lcrypto 

DISTNAME = kpabe-0.3

TARGETS  = kpabe-setup   kpabe-enc   kpabe-keygen   kpabe-dec

MANUALS  = $(TARGETS:=.1)
HTMLMANS = $(MANUALS:.1=.html)

all: $(TARGETS)

# user-level compilation

kpabe-setup: setup.o common.o policy_lang.o
	$(CC) -o $@ $^ $(LDFLAGS)

kpabe-enc: enc.o common.o policy_lang.o
	$(CC) -o $@ $^ $(LDFLAGS)

kpabe-keygen: keygen.o common.o policy_lang.o
	$(CC) -o $@ $^ $(LDFLAGS)

kpabe-dec: dec.o common.o
	$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c *.h Makefile
	$(CC) -c -o $@ $< $(CFLAGS)

# installation

dist: *.y policy_lang.c *.c *.h *.more-man \
	AUTHORS COPYING INSTALL NEWS README $(MANUALS) \
	aclocal.m4 acinclude.m4 configure configure.ac install-sh Makefile.in \
	missing mkinstalldirs
	rm -rf $(DISTNAME)
	mkdir $(DISTNAME)
	cp $^ $(DISTNAME)
	tar zc $(DISTNAME) > $(DISTNAME).tar.gz
	rm -rf $(DISTNAME)

install: $(TARGETS) $(MANUALS)
	$(top_srcdir)/mkinstalldirs -m 755 $(bindir)
	$(top_srcdir)/mkinstalldirs -m 755 $(mandir)
	$(top_srcdir)/mkinstalldirs -m 755 $(mandir)/man1
	for PROG in $(TARGETS); \
	do \
	  $(top_srcdir)/install-sh -m 755 $$PROG   $(bindir); \
	  $(top_srcdir)/install-sh -m 644 $$PROG.1 $(mandir)/man1; \
	done

uninstall:
	for PROG in $(TARGETS); \
	do \
	  /bin/rm -f $(bindir)/$$PROG; \
	  /bin/rm -f $(mandir)/man1/$$PROG.1; \
	done

# developer-level processing and meta stuff

%.c: %.y *.h Makefile
	if which bison 2> /dev/null; then \
	   bison -o $@ $<; \
	fi

%.1: % %.more-man
	if which help2man 2> /dev/null; then \
	   help2man --section=1 --source="SRI International" --no-info \
	            -I $<.more-man -o $@ ./$<; \
	fi

%.html: %.1
	groff -man -Thtml $< > $@

html: $(HTMLMANS)

TAGS: *.c *.h *.y
	@(etags $^ || true) 2> /dev/null

Makefile: Makefile.in config.status
	./config.status

config.status: configure
	./config.status --recheck

configure: configure.ac aclocal.m4 acinclude.m4
	autoconf

# cleanup

# remove everything an installing user can rebuild
clean:
	rm -f *.o $(TARGETS) *.tar.gz pub_key master_key priv_key *~

# remove everything a package developer can rebuild
distclean: clean
	rm -rf policy_lang.c autom4te.cache Makefile config.status config.log config.cache \
		configure configure.scan autoscan*.log *.1 *.html *.lineno
