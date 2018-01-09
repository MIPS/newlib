Demonstration of a bootable example built for a specific cpu core, limited to
I7200, relying on compile time CONFIG_XXX values for compile time
specialization.

Set environment variable MIPS_ELF_ROOT
	This should be set to the root of the installation directory for the
	toolchain (that is, below the bin directory)

To build for the I7200
	# make CORE=I7200

To delete temporary and built files
	# make clean CORE=I7200
