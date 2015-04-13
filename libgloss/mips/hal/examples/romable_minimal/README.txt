Copyright (c) 2015, Imagination Technologies LLC and Imagination Technologies 
Limited. 
 
Redistribution and use in source and binary forms, with or without 
modification, are permitted under the terms of the MIPS Free To Use 1.0 
license that you will have received with this package. If you haven't 
received this file, please contact Imagination Technologies or see the 
following URL for details.
http://codescape-mips-sdk.imgtec.com/license/IMG-free-to-use-on-MIPS-license


This example code and makefile is for use with the 
Codescape GNU Tools for MIPS Bare Metal toolchain 
(referred to as the Bare Metal Tookchain in this document).


This example code demonstrates a minimal bootable example with
a quiet exception handler. The main differences are found in the
linker script which is derived from <libgloss/mips/hal/uhi32.ld>.

The included linker script requires less external object code than
the standard version in uhi32.ld.


Set Environment variable MIPS_ELF_ROOT
        This should be set to the root of the installation 
        directory for the Bare Metal Toolchain (that is, 
        below the bin directory)

To build 32-bit big-endian 
        # make

To delete temporary and built files
        # make clean
