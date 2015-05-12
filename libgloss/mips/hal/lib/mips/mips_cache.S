/*
 * Copyright (c) 2014, Imagination Technologies LLC and Imagination
 * Technologies Limited. 
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted under the terms of the MIPS Free To Use 1.0 
 * license that you will have received with this package. If you haven't 
 * received this file, please contact Imagination Technologies or see the 
 * following URL for details.
 * http://codescape-mips-sdk.imgtec.com/license/IMG-free-to-use-on-MIPS-license
 *
 */
#include <mips/cpu.h>

EXPORTS(mips_icache_size,4)
EXPORTS(mips_icache_linesize,4)
EXPORTS(mips_icache_ways,4)

EXPORTS(mips_dcache_size,4)
EXPORTS(mips_dcache_linesize,4)
EXPORTS(mips_dcache_ways,4)

EXPORTS(mips_scache_size,4)
EXPORTS(mips_scache_linesize,4)
EXPORTS(mips_scache_ways,4)

EXPORTS(mips_tcache_size,4)
EXPORTS(mips_tcache_linesize,4)
EXPORTS(mips_tcache_ways,4)

# void mips_size_cache(void)
SLEAF(mips_size_cache)
	
	mfc0	t0,C0_CONFIG0
	andi	t0, CFG1_M
	
	# Config1 is mandatory, but we'll do this by the book.
	
	
