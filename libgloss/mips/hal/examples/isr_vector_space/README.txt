Demonstration of defining custom interrupt vector spacing and overriding the
interrupt vector. This extends the interrupt handler demo to include both
a C and assembly coded handler.

Set environment variable MIPS_ELF_ROOT
	This should be set to the root of the installation directory for the
	toolchain (that is, below the bin directory).

To build with different vector spacing (e.g. 128)
	# make ISR_VEC_SPACE=128

To build big-endian
	# make

To build little-endian
	# make ENDIAN=EL

To delete temporary and built files
	# make clean
