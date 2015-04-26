/*
 * Copyright 2014-2015, Imagination Technologies Limited and/or its
 *                      affiliated group companies.
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
 * m32cache_ops.sx: MIPS32 cache support functions
 */

#include "m32cache.h"

/*
 * void m32_flush_cache (void)
 *
 * Writeback and invalidate all caches
 */
LEAF(m32_flush_cache)
	SIZE_CACHE(a1,mips_dcache_size)

	/* writeback and invalidate primary caches individually */
	lw	a2,mips_dcache_linesize
	li	a0,KSEG0_BASE
	cacheop(a0,a1,a2,Index_Writeback_Inv_D)

9:	lw	a1,mips_icache_size
	lw	a2,mips_icache_linesize
	blez	a1,9f
	li	a0,KSEG0_BASE
	cacheop(a0,a1,a2,Index_Invalidate_I)

9:	lw	a1,mips_scache_size
	lw	a2,mips_scache_linesize
	blez	a1,9f
	sync
	li	a0,KSEG0_BASE
	cacheop(a0,a1,a2,Index_Writeback_Inv_S)

9:	sync
	jr.hb	ra
END(m32_flush_cache)

/*
 * void m32_flush_dcache (void)
 *
 * Writeback and invalidate data caches only
 */
LEAF(m32_flush_dcache)
	SIZE_CACHE(a1,mips_dcache_size)

	/* writeback and invalidate primary data cache */
	lw	a2,mips_dcache_linesize
	li	a0,KSEG0_BASE
	cacheop(a0,a1,a2,Index_Writeback_Inv_D)

9:	lw	a1,mips_scache_size
	lw	a2,mips_scache_linesize
	blez	a1,9f
	sync
	li	a0,KSEG0_BASE
	cacheop(a0,a1,a2,Index_Writeback_Inv_S)

9:	sync
	jr.hb	ra
END(m32_flush_dcache)

/*
 * void m32_flush_icache (void)
 *
 * Writeback and invalidate instruction cache only
 */
LEAF(m32_flush_icache)
	SIZE_CACHE(a1,mips_icache_size)

	/* writeback and invalidate primary instruction cache */
	lw	a2,mips_icache_linesize
	li	a0,KSEG0_BASE
	cacheop(a0,a1,a2,Index_Invalidate_I)

9:	lw	a1,mips_scache_size
	blez	a1,9f
	lw	a2,mips_scache_linesize
	li	a0,KSEG0_BASE
	cacheop(a0,a1,a2,Index_Writeback_Inv_S)

9:	sync
	jr.hb	ra
END(m32_flush_icache)

/*
 * void m32_clean_cache (unsigned kva, size_t n)
 *
 * Writeback and invalidate address range in all caches
 */
LEAF(m32_clean_cache)
	SIZE_CACHE(a2,mips_dcache_linesize)
	vcacheop(a0,a1,a2,Hit_Writeback_Inv_D)

9:	lw	a2,mips_icache_linesize
	blez	a2,9f
	vcacheop(a0,a1,a2,Hit_Invalidate_I)

9:	lw	a2,mips_scache_linesize
	blez	a2,9f

	sync
	vcacheop(a0,a1,a2,Hit_Writeback_Inv_S)

9:	sync
	jr.hb	ra
END(m32_clean_cache)

/*
 * void m32_sync_icache (unsigned kva, size_t n)
 *
 * Synchronise icache and dcache for virtual address range
 */
LEAF(m32_sync_icache)
	/* check for bad size */
	addu	maxaddr,a0,a1
	blez	a1,9f

	/* get synci step and skip if not required */
	rdhwr	a2,$1
	addu	maxaddr,-1
	beqz	a2,9f

	/* ensure stores complete */
	sync

	/* align to line boundaries */
	subu	mask,a2,1
	not	mask
	and	addr,a0,mask
	subu   	addr,a2
	and	maxaddr,mask

	/* the cacheop loop */
10:	addu   	addr,a2
	synci	0(addr)
	bne     addr,maxaddr,10b

9:	sync
	jr.hb	ra
END(m32_sync_icache)

/*
 * void m32_clean_dcache (unsigned kva, size_t n)
 *
 * Writeback and invalidate address range in data caches
 */
LEAF(m32_clean_dcache)
	SIZE_CACHE(a2,mips_dcache_linesize)
	vcacheop(a0,a1,a2,Hit_Writeback_Inv_D)

9:	lw	a2,mips_scache_linesize
	blez	a2,9f
	sync
	vcacheop(a0,a1,a2,Hit_Writeback_Inv_S)

9:	sync
	jr.hb	ra
END(m32_clean_dcache)

/*
 * void m32_clean_dcache_nowrite (unsigned kva, size_t n)
 *
 * Invalidate (but don't writeback) address range in data caches
 * XXX Only safe if region is totally cache-line aligned.
 */
LEAF(m32_clean_dcache_nowrite)
	SIZE_CACHE(a2,mips_dcache_linesize)
	vcacheop(a0,a1,a2,Hit_Invalidate_D)

9:	lw	a2,mips_scache_linesize
	blez	a2,9f
	vcacheop(a0,a1,a2,Hit_Invalidate_S)

9:	sync
	jr.hb	ra
END(m32_clean_dcache_nowrite)

/*
 * Cache locking
 *
 * The MIPS32 cache architecture does support per-line cache locking.
 *
 * WARNING: if you lock any cache lines, then don't call the
 * mips_flush_xcache routines, because these will flush the
 * locked data out of the cache too; use only mips_clean_xcache.
 */

/*
 * void m32_lock_dcache (void *data, size_t n)
 *
 * Load and lock a block of date into the d-cache
 */
LEAF(m32_lock_dcache)
	SIZE_CACHE(a2,mips_dcache_linesize)
	vcacheop(a0,a1,a2,Fetch_Lock_D)
	sync
9:	jr.hb	ra
END(m32_lock_dcache)

/*
 * void m32_lock_icache (void *code, size_t n)
 *
 * Load and lock a block of instructions into the i-cache
 */
LEAF(m32_lock_icache)
	SIZE_CACHE(a2,mips_icache_linesize)
	vcacheop(a0,a1,a2,Fetch_Lock_I)
	sync
9:	jr.hb	ra
END(m32_lock_icache)

LEAF(m32_lock_scache)
	j	ra
END(m32_lock_scache)
