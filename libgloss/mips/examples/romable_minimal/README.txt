Demonstration of a bootable example without some of the support code normally
needed for debug, hosted or semi-hosted environments.

The removed features are:
* No support for UHI argument handling operations (i.e. a0 == -1)
* No support for returning to a boot monitor or using a boot monitor's
  UHI support
* Quiet unhandled exceptions, no output is produced but instead the UHI
  exception operation is raised and a debugger (or application) can
  respond to it

These features are removed by modifying the the linker scripts which are
derived from uhi*.ld linker scripts, using makescripts.sh.

Set environment variable MIPS_ELF_ROOT
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
