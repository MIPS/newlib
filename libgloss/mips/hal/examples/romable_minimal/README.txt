This example code demonstrates a minimal bootable example with a quiet
exception handler. The main differences are found in the linker script
which is derived from uhi*.ld linker scripts, using makescripts.sh.

Set Environment variable MIPS_ELF_ROOT
	This should be set to the root of the installation directory for the
	toolchain (that is, below the bin directory).

First prepare the linker scripts by running makescripts.sh
	# ./makescripts.sh

To build 32-bit big-endian
	# make

To build 32-bit little-endian
	# make ENDIAN=EL

To build 64-bit
	# make ABI=64

To delete temporary and built files
	# make clean
