## Process this file with automake to generate Makefile.in

AUTOMAKE_OPTIONS = cygnus

INCLUDES = $(NEWLIB_CFLAGS) $(CROSS_CFLAGS) $(TARGET_CFLAGS)

AM_CCASFLAGS = $(INCLUDES)

noinst_LIBRARIES = lib.a

lib_a_SOURCES = setjmp.S strncpy.c
lib_a_CCASFLAGS=$(AM_CCASFLAGS) -D_COMPILING_NEWLIB
lib_a_CFLAGS=$(AM_CFLAGS) -D_COMPILING_NEWLIB

if NANOMIPS
  lib_a_SOURCES += memcpy-c.c memset-c.c strcmp-r6.S strlen-c.c strcpy.c
else
  lib_a_SOURCES += memcpy.S memset.S strcmp.S strlen.c
endif


ACLOCAL_AMFLAGS = -I ../../.. -I ../../../..
CONFIG_STATUS_DEPENDENCIES = $(newlib_basedir)/configure.host
