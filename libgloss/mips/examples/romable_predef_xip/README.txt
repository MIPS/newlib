Demonstration of a bootable example built for a specific cpu core, limited to
I7200, relying on compile time CONFIG_XXX values for compile time
specialization.  This variant produces boot code that eXecutes In Place (XIP)
rather than copying code to RAM first.  It also eliminates all C runtime
support code leading to a very thin image which puts restrictions on what C
features can be used.  For example any code reliant on the HEAP is unsupported,
constructors and destructors are unsupported and almost all standard library
functions are unavailable for the above reasons.

Set environment variable MIPS_ELF_ROOT
	This should be set to the root of the installation directory for the
	toolchain (that is, below the bin directory)

To build for the I7200
	# make CORE=I7200

To delete temporary and built files
	# make clean CORE=I7200
