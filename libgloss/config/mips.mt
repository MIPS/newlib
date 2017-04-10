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

get_ram_range.o: ${srcdir}/hal/get_ram_range.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?
link.o: $(srcdir)/hal/link.c
	$(CC) $(CFLAGS_FOR_TARGET) -O2 $(INCLUDES) -c $(CFLAGS) $?

# Exception and interrupt handling support
mips_excpt_handler.o: $(srcdir)/hal/mips_excpt_handler.c
	$(CC) $(CFLAGS_FOR_TARGET) $(HALINCLUDE) -DVERBOSE_EXCEPTIONS=1 -O2 $(INCLUDES) -c $(CFLAGS) $<
mips_excpt_handler_quiet.o: $(srcdir)/hal/mips_excpt_handler.c
	$(CC) $(CFLAGS_FOR_TARGET) $(HALINCLUDE) -O2 $(INCLUDES) -c $(CFLAGS) $< -o $@
%.o: $(srcdir)/hal/%.S
	$(CC) $(CFLAGS_FOR_TARGET) $(HALINCLUDE) -O2 $(INCLUDES) -c $(CFLAGS) $< -o $@
%.o: $(srcdir)/hal/%.c
	$(CC) $(CFLAGS_FOR_TARGET) $(HALINCLUDE) -O2 $(INCLUDES) -c $(CFLAGS) $< -o $@
mips_excpt_isr_0.o:
	$(CC) $(CFLAGS_FOR_TARGET) $(INCLUDES) $(CFLAGS) $(HALINCLUDE) -c -DDEF=__isr_vec_0 -DREF=__isr_vec_0 -DISR=_mips_isr_0 -DZERO ${srcdir}/hal/mips_excpt_isr_fragment.S -o $@
mips_excpt_isr_%.o:
	$(CC) $(CFLAGS_FOR_TARGET) $(INCLUDES) $(CFLAGS) $(HALINCLUDE) -c -DDEF=__isr_vec_$* -DREF=__isr_vec_$(shell expr $* - 1) -DISR=_mips_isr_$* ${srcdir}/hal/mips_excpt_isr_fragment.S -o $@
