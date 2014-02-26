#
# These are the minimum required stubs to support newlib
# for embedded MIPS targets.  Note that although read.o and write.o
# are mentioned here, they are not used for all targets.
#
close.o: ${srcdir}/../close.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
fstat.o: ${srcdir}/../fstat.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
getpid.o: ${srcdir}/../getpid.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
isatty.o: ${srcdir}/../isatty.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
kill.o: ${srcdir}/../kill.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
lseek.o: ${srcdir}/../lseek.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
open.o: ${srcdir}/../open.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
print.o: ${srcdir}/../print.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
putnum.o: ${srcdir}/../putnum.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
read.o: ${srcdir}/../read.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
stat.o: ${srcdir}/../stat.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
unlink.o: ${srcdir}/../unlink.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
write.o: ${srcdir}/../write.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?

hosted_assert.o: $(srcdir)/hosted_assert.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_close.o: $(srcdir)/hosted_close.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_exit.o: $(srcdir)/hosted_exit.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_fstat.o: $(srcdir)/hosted_fstat.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_get_mem_info.o: $(srcdir)/hosted_get_mem_info.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_lseek.o: $(srcdir)/hosted_lseek.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_open.o: $(srcdir)/hosted_open.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_plog.o: $(srcdir)/hosted_plog.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_pread.o: $(srcdir)/hosted_pread.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_pwrite.o: $(srcdir)/hosted_pwrite.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_read.o: $(srcdir)/hosted_read.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_rename.o: $(srcdir)/hosted_rename.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_stat.o: $(srcdir)/hosted_stat.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_unlink.o: $(srcdir)/hosted_unlink.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_write.o: $(srcdir)/hosted_write.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
hosted_getargs.o: $(srcdir)/hosted_getargs.S
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
yamon_read.o: $(srcdir)/yamon_read.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
yamon_write.o: $(srcdir)/yamon_write.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
yamon_exit.o: $(srcdir)/yamon_exit.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
__exit.o: $(srcdir)/__exit.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
