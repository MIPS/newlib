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


This example code demonstrates a bootable example built for a specific
cpu core, either the P5600 or I6400.

Set Environment variable MIPS_ELF_ROOT
        This should be set to the root of the installation 
        directory for the Bare Metal Toolchain (that is, 
        below the bin directory)

To build for the P5600
        # make CORE=P5600

To build for the I6400
	# make CORE=I6400

To build little endian
	# make CORE=(I6400|P5600) ENDIAN=EL

To delete temporary and built files
        # make clean CORE=P5600
