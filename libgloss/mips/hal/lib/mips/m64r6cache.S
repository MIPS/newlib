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
 * m64r6cache.sx: MIPS64R6 cache support functions
*/
#include <mips/asm.h>
#include "m64r6cache.h"
#include <mips/m64r6cm3.h>
#include <mips/regdef.h>

#ifndef CSMIPS_CACHE_EXTRAROUTINES

/*
 * static void _internal_m64r6_size_cache (void)
 *
 * Internal routine to determine cache sizes by looking at MIPS64R6 config
 * and GCR registers.  Sizes are returned in registers, as follows:
 *
 * Do not use tmp3 (reg a1) in this function.
*/
	.text
	.hidden	_internal_m64r6_size_cache
	.ent	_internal_m64r6_size_cache
_internal_m64r6_size_cache:

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
	beqz	tmp,1f

	# Read $config,1
	mfc0	cfg,$config,1

	# Get I-cache line size
	and	tmp,cfg,CFG1_ILMASK
	srl	tmp,CFG1_ILSHIFT
	beqz	tmp,2f		# No I-cache

	# Get number of I-cache ways
	and	iways,cfg,CFG1_IAMASK
	srl	iways,CFG1_IASHIFT
	addu	iways,1
	move	icachesize,iways

	# Total icache size = lines/way * linesize * ways
	li	ilinesize,1
	addu	tmp,1
	sll	ilinesize,tmp
	sll	icachesize,tmp

	# Get I-cache lines per way
	and	tmp,cfg,CFG1_ISMASK
	srl	tmp,CFG1_ISSHIFT
	addu	tmp,6
	sll	icachesize,tmp

2:	# No I-cache, check for D-cache
	and	tmp,cfg,CFG1_DLMASK
	srl	tmp,CFG1_DLSHIFT
	beqz	tmp,3f		# No D-cache

	# Get number of dcache ways
	and	dways,cfg,CFG1_DAMASK
	srl	dways,CFG1_DASHIFT
	addu	dways,1
	move	dcachesize,dways

	# Total dcache size = lines/way * linesize * ways
	li	dlinesize,1
	addu	tmp,1
	sll	dlinesize,tmp
	sll	dcachesize,tmp

	# Get dcache lines per way
	and	tmp,cfg,CFG1_DSMASK
	srl	tmp,CFG1_DSSHIFT
	addu	tmp,6
	sll	dcachesize,tmp

3:	# No D-cache, check for L2 cache

	# Check if we have $config,2 register present
	and	tmp,cfg,CFG1_M
	beqz	tmp,1f

	# Check if we have $config,3 register present
	mfc0	cfg,$config,2
	and	tmp,cfg,CFG2_M
	beqz	tmp,1f
	
	# Check if Coherency Manager memory-mapped 
	# Global Configuration Register Space is implemented.
	mfc0	tmp,$config,3
	and	tmp,CFG3_CMGCRMASK
	srl	tmp,CFG3_CMGCRSHIFT
	beqz	tmp,1f		# Return if not implemented

	# Read CMGCRBase to find CMGCR_BASE_ADDR
	dmfc0	tmp,CMGCRBase
	sll	tmp,4
	lui	tmp1,0xb000	# Make it virtual
	or	tmp,tmp1

	# Read GCR_L2_CONFIG
	PTR_L	tmp1,GCR_L2_CONFIG(tmp)

	ext	slinesize, tmp1, 8, 4		# Extract line size
	li	tmp2, 2
	sllv	slinesize, tmp2, slinesize	# Now have true L2 line size in bytes
	ext	sways, tmp1, 12, 4		# Extract sets/way
	li	tmp2, 64
	sllv	sways, tmp2, sways		# Now we have true L2 sets/way
	ext	tmp1, tmp1, 0, 8		# Extract L2 associativity
	addiu	tmp1, tmp1, 1
	mul	tmp1, tmp1, sways		# Get total number of sets
	mul	scachesize, slinesize, tmp1	# L2 cache size

1:	# Return
	jr	ra

	.end _internal_m64r6_size_cache

/*
 * void m64r6_size_cache (void)
 *
 * Work out size of I, D & S caches (assume already initialised)
*/
	.text
	.global	m64r6_size_cache
	.ent	m64r6_size_cache
m64r6_size_cache:

	lw	tmp,mips_icache_size
	bgtz	tmp,1f				# already known?

	move	tmp3,ra
	bal	_internal_m64r6_size_cache

	move	ra,tmp3
	sw	icachesize,mips_icache_size
	sw	dcachesize,mips_dcache_size
	sw	scachesize,mips_scache_size
	sw	ilinesize,mips_icache_linesize
	sw	dlinesize,mips_dcache_linesize
	sw	slinesize,mips_scache_linesize
	sw	iways,mips_icache_ways
	sw	dways,mips_dcache_ways
	sw	sways,mips_scache_ways

1:	# Return
	jr	ra

	.end m64r6_size_cache

/*
 * void m64r6_init_cache (void)
 *
 * Work out size of and initialize I, D & S caches.
 *
*/
	.text
	.global	m64r6_init_cache
	.ent	m64r6_init_cache
m64r6_init_cache:

	move	tmp3,ra
	bal	_internal_m64r6_size_cache
	
	move	ra,tmp3
	
	.set	noreorder
	.set	nomacro
	# Run uncached (PIC)
	move	tmp4,ra
	li	tmp1,KSEG1_BASE
	bal	4f
	nop
4:	or	tmp1,ra
	addu	tmp1,20
	move	ra,tmp4
	jr	tmp1
	nop
	.set	macro
	.set	reorder

	# 
	# The caches may be in an indeterminate state,
	# so we force good parity into them by doing an
	# invalidate, load/fill, invalidate for each line.
	# 

	# Disable all i/u and cache exceptions
	.set noreorder
	mfc0	t1,$sr
	li	t0,~SR_IE
	and	t0,t1
	or	t0,SR_ERL
	mtc0	t0,$sr
#if __mips_isa_rev < 2
	ssnop; ssnop
#endif
	ehb
	.set reorder

	#
	# Initialise secondary cache
	#

	# Read CMGCRBase to find CMGCR_BASE_ADDR
	dmfc0	tmp,CMGCRBase
	sll	tmp,4
	lui	tmp1,0xb000	# Make it virtual
	or	tmp,tmp1

	# Read GCR_L2_CONFIG and check L2 size
	PTR_L	tmp1,GCR_L2_CONFIG(tmp)

	# Read L2 Line Size
	ext	tmp2, tmp1, 11, 4

	# Check if there is L2
	beqz	tmp2, 9f

	li	tmp3, 2
	sllv	tmp2, tmp3, tmp2

	# Read L2 Sets per Way
	ext	tmp4, tmp1, 12, 4
	li	tmp3, 64
	sllv	tmp4, tmp3, tmp4

	# Read L2 Associativity
	ext	tmp5, tmp1, 0, 8
	addu	tmp5, 1
	mul	tmp4, tmp4, tmp5
	lui	tmp3, 0x8000

	# Clear GCR Tag/Data registers
	sd	zero, GCR_TAG_ADDR(tmp)
	sd	zero, GCR_TAG_STATE(tmp)
	sd	zero, GCR_TAG_DATA(tmp)
	li	tmp5, 0xfcffffff
	and	tmp1, tmp5			# clear bits 25:24 to make sure ECC is calculated by HW
	li	tmp5, 0x04000000
	or	tmp1, tmp5			# set bit 26 of GCR_L2_CONFIG to make sure LRU is written
	sd	tmp1, GCR_L2_CONFIG(tmp)
	sync

	# L2 Index Store Tag Cache Op
	# Will invalidate the tag entry
1:	cache	Index_Store_Tag_S, 0(tmp3)
	addu	tmp4, -1
	add	tmp3, tmp2
	bnez	tmp4, 1b
	# End of L2 init

9:
	mtc0	zero,$errctl
	mtc0	zero,$taglo		# 4K taglo / 2*K itaglo
	mtc0	zero,$taghi		# 4K taghi / 2*K itaghi
	mtc0	zero,$taglo,2		# 2*K dtaglo
	mtc0	zero,$taghi,2		# 2*K dtaghi
	ehb

4:
	# 
	# Assume bottom of RAM or scache will generate good parity for the
	# primary caches (max 32K)
	# 

	# Initialise primary instruction cache.
	.set	noreorder
	li	a0,KSEG0_BASE
	addu	a1,a0,icachesize		# limit = base + icachesize
	beqz	icachesize,8f
	nop
1:	addu	a0,ilinesize
	cache	Index_Store_Tag_I,-4(a0)	# BDSLOT: clear tag
	bne	a0,a1,1b
	nop
	.set	reorder

	# Initialise primary data cache.
	.set	noreorder
8:	li	a0,KSEG0_BASE
	addu	a1,a0,dcachesize        	# limit = base + dcachesize
	beqz	dcachesize,8f
	nop
1:	addu	a0,dlinesize
	cache	Index_Store_Tag_D,-4(a0)	# BDSLOT: clear tag
	bne	a0,a1,1b
	nop
	.set	reorder

8:	sync

	# We store the sizes only after the caches are initialised
4:	sw	icachesize,mips_icache_size
	sw	dcachesize,mips_dcache_size
	sw	scachesize,mips_scache_size
	sw	ilinesize,mips_icache_linesize
	sw	dlinesize,mips_dcache_linesize
	sw	slinesize,mips_scache_linesize
	sw	iways,mips_icache_ways
	sw	dways,mips_dcache_ways
	sw	sways,mips_scache_ways

	.set	noreorder
	mtc0	t1,$sr
#if __mips_isa_rev < 2
	ssnop; ssnop
#endif
	ehb
	.set	reorder

	jr.hb	ra

	.end	m64r6_init_cache

	.text
	.global	m64r6_clean_icache
	.ent	m64r6_clean_icache
m64r6_clean_icache:

	SIZE_CACHE64(a2,mips_icache_linesize)
	vcacheop64(a0,a1,a2,Hit_Invalidate_I)

9:	lw	a2,mips_scache_linesize
	blez	a2,9f
	vcacheop64(a0,a1,a2,Hit_Writeback_Inv_S)
	sync

9:	jr.hb	ra

	.end	m64r6_clean_icache

	.text
	.global	m64r6_flush_cache
	.ent	m64r6_flush_cache
m64r6_flush_cache:

	SIZE_CACHE64(a1,mips_dcache_size)

	/* writeback and invalidate primary caches individually */
	lw	a2,mips_dcache_linesize
	li	a0,KSEG0_BASE
	cacheop64(a0,a1,a2,Index_Writeback_Inv_D)

9:	lw	a1,mips_icache_size
	lw	a2,mips_icache_linesize
	blez	a1,9f
	li	a0,KSEG0_BASE
	cacheop64(a0,a1,a2,Index_Invalidate_I)

9:	lw	a1,mips_scache_size
	lw	a2,mips_scache_linesize
	blez	a1,9f
	sync
	li	a0,KSEG0_BASE
	cacheop64(a0,a1,a2,Index_Writeback_Inv_S)

9:	sync
	jr.hb	ra

	.end	m64r6_flush_cache

	.text
	.global	m64r6_flush_dcache
	.ent	m64r6_flush_dcache
m64r6_flush_dcache:

	SIZE_CACHE64(a1,mips_dcache_size)

	/* writeback and invalidate primary data cache */
	lw	a2,mips_dcache_linesize
	li	a0,KSEG0_BASE
	cacheop64(a0,a1,a2,Index_Writeback_Inv_D)

9:	lw	a1,mips_scache_size
	lw	a2,mips_scache_linesize
	blez	a1,9f
	sync
	li	a0,KSEG0_BASE
	cacheop64(a0,a1,a2,Index_Writeback_Inv_S)

9:	sync
	jr.hb	ra

	.end	m64r6_flush_dcache

	.text
	.global	m64r6_flush_icache
	.ent	m64r6_flush_icache
m64r6_flush_icache:

	SIZE_CACHE64(a1,mips_icache_size)

	/* writeback and invalidate primary instruction cache */
	lw	a2,mips_icache_linesize
	li	a0,KSEG0_BASE
	cacheop64(a0,a1,a2,Index_Invalidate_I)

9:	lw	a1,mips_scache_size
	blez	a1,9f
	lw	a2,mips_scache_linesize
	li	a0,KSEG0_BASE
	cacheop64(a0,a1,a2,Index_Writeback_Inv_S)

9:	sync
	jr.hb	ra

	.end	m64r6_flush_icache

	.text
	.global	m64r6_clean_cache
	.ent	m64r6_clean_cache
m64r6_clean_cache:

	SIZE_CACHE64(a2,mips_dcache_linesize)
	vcacheop64(a0,a1,a2,Hit_Writeback_Inv_D)

9:	lw	a2,mips_icache_linesize
	blez	a2,9f
	vcacheop64(a0,a1,a2,Hit_Invalidate_I)

9:	lw	a2,mips_scache_linesize
	blez	a2,9f

	sync
	vcacheop64(a0,a1,a2,Hit_Writeback_Inv_S)

9:	sync
	jr.hb	ra

	.end	m64r6_clean_cache

	.text
	.global	m64r6_sync_icache
	.ent	m64r6_sync_icache
m64r6_sync_icache:
	daddu	maxaddr,a0,a1
	blez	a1,9f

	/* get synci step and skip if not required */
	rdhwr	a2,$1
	daddu	maxaddr,-1
	beqz	a2,9f

	/* ensure stores complete */
	sync

	/* align to line boundaries */
	dsubu	mask,a2,1
	not	mask
	and	addr,a0,mask
	and	maxaddr,mask

	/* the cacheop loop */
	.set	noreorder
10: 	synci	0(addr)
	bne	addr,maxaddr,10b
	daddu	addr,a2
	.set	reorder

9:	sync
	jr.hb	ra

	.end	m64r6_sync_icache

	.text
	.global	m64r6_clean_dcache
	.ent	m64r6_clean_dcache
m64r6_clean_dcache:
	SIZE_CACHE64(a2,mips_dcache_linesize)
	vcacheop64(a0,a1,a2,Hit_Writeback_Inv_D)

9:	lw	a2,mips_scache_linesize
	blez	a2,9f
	sync
	vcacheop64(a0,a1,a2,Hit_Writeback_Inv_S)

9:	sync
	jr.hb	ra
	.end	m64r6_clean_dcache

	.text
	.global	m64r6_clean_dcache_nowrite 
	.ent	m64r6_clean_dcache_nowrite 
m64r6_clean_dcache_nowrite:
	SIZE_CACHE64(a2,mips_dcache_linesize)
	vcacheop64(a0,a1,a2,Hit_Invalidate_D)

9:	lw	a2,mips_scache_linesize
	blez	a2,9f
	vcacheop64(a0,a1,a2,Hit_Invalidate_S)

9:	sync
	jr.hb	ra
	.end	m64r6_clean_dcache_nowrite 


	.text
	.global	m64r6_lock_dcache
	.ent	m64r6_lock_dcache
m64r6_lock_dcache:
	SIZE_CACHE64(a2,mips_dcache_linesize)
	vcacheop64(a0,a1,a2,Fetch_Lock_D)
	sync
9:	jr.hb	ra
	.end	m64r6_lock_dcache

	.text
	.global	m64r6_lock_icache
	.ent	m64r6_lock_icache
m64r6_lock_icache:
	SIZE_CACHE64(a2,mips_icache_linesize)
	vcacheop64(a0,a1,a2,Fetch_Lock_I)
	sync
9:	jr.hb	ra
	.end	m64r6_lock_icache

	.text
	.global	m64r6_lock_scache
	.ent	m64r6_lock_scache
m64r6_lock_scache:
	j	ra
	.end	m64r6_lock_scache

#endif /* !CSMIPS_CACHE_EXTRAROUTINES */

