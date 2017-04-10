Demonstration of a bootable example suitable for placing in ROM. This includes
copying application code to RAM during boot.

Set environment variable MIPS_ELF_ROOT
	This should be set to the root of the installation directory for the
	toolchain (that is, below the bin directory)

To build big-endian
	# make

To build little-endian
	# make ENDIAN=EL

To delete temporary and built files
	# make clean
