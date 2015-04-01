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


/*
 * m32cache.sx: MIPS32 cache support functions
 */


/*
 * Note:	 pessimistic hazard timings assumed.
 */

#if defined(__mips_isa_rev) && __mips_isa_rev >= 6
#define L2_CM3 1
#else
#define L2_SCACHE 1
#endif

#include "m32cache.h"
#ifdef L2_CM3
#include <mips/m64r6cm3.h>
#endif

#if 1 /*#cache(m32)*/

#ifndef CSMIPS_CACHE_EXTRAROUTINES

/*
 * static void _size_cache()
 *
 * Internal routine to determine cache sizes by looking at config
 * registers.  Sizes are returned in registers, as follows:
 *
 * Do not use tmp3 (reg a1) and tmp1 (reg v1) in this function.
 */
SLEAF(_size_cache)
	# Read $config,0 to check presence of $config,1
	mfc0	cfg,$config,0

	# Clear temporaries
	li	icachesize,0
	li	ilinesize,0
	li	dcachesize,0
	li	dlinesize,0
	li	scachesize,0
	li	slinesize,0

	# Check if we have $config,1 register
	and	tmp,cfg,CFG0_M
	beqz	tmp,9f

	# Read $config,1
	mfc0	cfg,$config,1

	# Get I-cache line size
	and	tmp,cfg,CFG1_IL_MASK
	srl	tmp,CFG1_IL_SHIFT
	beqz	tmp,8f		# No I-cache

	# Get number of I-cache ways
	and	iways,cfg,CFG1_IA_MASK
	srl	iways,CFG1_IA_SHIFT
	addu	iways,1
	move	icachesize,iways

	# Total icache size = lines/way * linesize * ways
	li	ilinesize,1
	addu	tmp,1
	sll	ilinesize,tmp
	sll	icachesize,tmp

	# Get I-cache lines per way
	and	tmp,cfg,CFG1_IS_MASK
	srl	tmp,CFG1_IS_SHIFT
	addu	tmp,6
	sll	icachesize,tmp

8:	# No I-cache, check for D-cache
	and	tmp,cfg,CFG1_DL_MASK
	srl	tmp,CFG1_DL_SHIFT
	beqz	tmp,8f		# No D-cache

	# Get number of dcache ways
	and	dways,cfg,CFG1_DA_MASK
	srl	dways,CFG1_DA_SHIFT
	addu	dways,1
	move	dcachesize,dways

	# Total dcache size = lines/way * linesize * ways
	li	dlinesize,1
	addu	tmp,1
	sll	dlinesize,tmp
	sll	dcachesize,tmp

	# Get dcache lines per way
	and	tmp,cfg,CFG1_DS_MASK
	srl	tmp,CFG1_DS_SHIFT
	addu	tmp,6
	sll	dcachesize,tmp

8:	# No D-cache, check for L2 cache

	# Check if we have $config,2 register present
	and	tmp,cfg,CFG1_M
	beqz	tmp,9f

	mfc0	cfg,$config,2

	/* get scache line size (log2) */
	and	tmp,cfg,CFG2_SL_MASK
	srl	tmp,CFG2_SL_SHIFT
	beqz	tmp,1f		# no s-cache
	addu	tmp,1

	/* get number of scache ways */
	and	sways,cfg,CFG2_SA_MASK
	srl	sways,CFG2_SA_SHIFT
	addu	sways,1
	move	scachesize,sways

	/* scache size = lines/way * linesize * ways */
	li	slinesize,1
	sll	slinesize,tmp
	sll	scachesize,tmp

	/* get scache lines per way */
	and	tmp,cfg,CFG2_SS_MASK
	srl	tmp,CFG2_SS_SHIFT
	addu	tmp,6
	sll	scachesize,tmp

1:
	# Check if we have $config,3 register present
	and	tmp,cfg,CFG2_M
	beqz	tmp,9f
	
	# Check if Coherency Manager memory-mapped 
	# Global Configuration Register Space is implemented.
	mfc0	tmp,$config,3
	ext	tmp,tmp,CFG3_CMGCR_SHIFT,1
	beqz	tmp,9f		# Return if not implemented

	# Read CMGCRBase to find CMGCR_BASE_ADDR
	PTR_MFC0 tmp,C0_CMGCRBASE
	sll	tmp,4
	lui	tmp2,0xb000	# Make it virtual
	or	tmp,tmp2

	# Read GCR_L2_CONFIG
	PTR_L	tmp,GCR_L2_CONFIG(tmp)

	ext	slinesize, tmp, 8, 4		# Extract line size
	li	tmp2, 2
	sllv	slinesize, tmp2, slinesize	# Now have true L2 line size in bytes
	ext	sways, tmp, 12, 4		# Extract sets/way
	li	tmp2, 64
	sllv	sways, tmp2, sways		# Now we have true L2 sets/way
	ext	tmp, tmp, 0, 8		# Extract L2 associativity
	addiu	tmp, tmp, 1
	mul	tmp, tmp, sways		# Get total number of sets
	mul	scachesize, slinesize, tmp	# L2 cache size

9:	# Return
	jr	ra
SEND(_size_cache)

/*
 * void size_cache()
 *
 * Work out size of I, D & S caches (assume already initialised)
 */
LEAF(m32_size_cache)
	lw	t0,mips_icache_size
	move	tmp3,ra
	bgtz	t0,8f				# already known?

	bal	_size_cache
	move	ra,tmp3

..savesize:
	sw	icachesize,mips_icache_size
	sw	dcachesize,mips_dcache_size
	sw	scachesize,mips_scache_size
	sw	ilinesize,mips_icache_linesize
	sw	dlinesize,mips_dcache_linesize
	sw	slinesize,mips_scache_linesize
	sw	iways,mips_icache_ways
	sw	dways,mips_dcache_ways
	sw	sways,mips_scache_ways

8:	# Return
	jr	ra
END(m32_size_cache)

/*
 * void m32_clean_icache (unsigned kva, size_t n)
 *
 * Writeback and invalidate address range in instruction caches
 */
LEAF(m32_clean_icache)
	SIZE_CACHE(a2,mips_icache_linesize)
	vcacheop(a0,a1,a2,Hit_Invalidate_I)

9:	lw	a2,mips_scache_linesize
	blez	a2,9f
	vcacheop(a0,a1,a2,Hit_Writeback_Inv_S)
	sync

9:	jr.hb	ra
END(m32_clean_icache)

#endif /* !CSMIPS_CACHE_EXTRAROUTINES */

#endif /* #cache(m32) */
