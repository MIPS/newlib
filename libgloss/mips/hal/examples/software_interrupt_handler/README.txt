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



Set Environment variable MIPS_ELF_ROOT
	This should be set to the root of the installation 
        directory for the Bare Metal Toolchain (that is, 
        below the bin directory)

To build big-endian
	# make

To build little-endian
	# make ENDIAN=EL

To delete temporary and built files
	# make clean
