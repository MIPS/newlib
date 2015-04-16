This example code demonstrates a bootable example built for a specific cpu 
core, either the P5600 or I6400, relying on compile time CONFIG_C$X values
for compile time specialization.

Set Environment variable MIPS_ELF_ROOT
        This should be set to the root of the installation directory for the 
	toolchain (that is, below the bin directory)

To build for the P5600
	# make CORE=P5600

To build for the I6400
	# make CORE=I6400

To build little endian
	# make CORE=(I6400|P5600) ENDIAN=EL

To delete temporary and built files
        # make clean CORE=P5600
