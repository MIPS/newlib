Demonstration of exception handling by triggering a memory fault, recovering
and then continuing.

Set environment variable MIPS_ELF_ROOT
	This should be set to the root of the installation directory for the
	toolchain (that is, below the bin directory)

To build big-endian
	# make

To build little-endian
	# make ENDIAN=EL

To delete temporary and built files
	# make clean
