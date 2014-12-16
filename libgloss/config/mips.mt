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

uhi_assert.o: $(srcdir)/uhi_assert.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_close.o: $(srcdir)/uhi_close.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_exit.o: $(srcdir)/uhi_exit.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_fstat.o: $(srcdir)/uhi_fstat.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_get_mem_info.o: $(srcdir)/uhi_get_mem_info.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_lseek.o: $(srcdir)/uhi_lseek.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_open.o: $(srcdir)/uhi_open.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_plog.o: $(srcdir)/uhi_plog.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_pread.o: $(srcdir)/uhi_pread.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_pwrite.o: $(srcdir)/uhi_pwrite.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_read.o: $(srcdir)/uhi_read.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_link.o: $(srcdir)/uhi_link.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_stat.o: $(srcdir)/uhi_stat.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_unlink.o: $(srcdir)/uhi_unlink.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_write.o: $(srcdir)/uhi_write.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
uhi_getargs.o: $(srcdir)/uhi_getargs.S
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
yamon_read.o: $(srcdir)/yamon_read.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
yamon_write.o: $(srcdir)/yamon_write.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
yamon_exit.o: $(srcdir)/yamon_exit.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
yamon_close.o: $(srcdir)/yamon_close.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
yamon_fstat.o: $(srcdir)/yamon_fstat.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
link.o: $(srcdir)/link.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
mips_excpt_handler.o: $(srcdir)/mips_excpt_handler.c $(srcdir)/excpt.h
	$(CC) $(CFLAGS_FOR_TARGET) -I ${srcdir}/hal/include -O2 $(INCLUDES) -c $(CFLAGS) $?
mips_excpt_entry.o: $(srcdir)/mips_excpt_entry.S $(srcdir)/excpt.h
	$(CC) $(CFLAGS_FOR_TARGET) -I ${srcdir}/hal/include -O2 $(INCLUDES) -c $(CFLAGS) $?
