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
 * cache_ops.sx: switchable cache support
 */

#include "cache.h"

/*
 * void mips_flush_cache (void)
 *
 * Writeback and invalidate all caches in the quickest way possible.
 */
SWCACHE(flush_cache)

/*
 * void mips_flush_dcache (void)
 *
 * Writeback and invalidate only the data caches.
 * Joint caches (i.e. combined I & D) will be flushed too.
 */
SWCACHE(flush_dcache)

/*
 * void mips_flush_icache (void)
 *
 * Writeback and invalidate only the instruction caches.
 * Joint caches (i.e. combined I & D) will be flushed too.
 */
SWCACHE(flush_icache)

/*
 * void mips_clean_cache (vaddr_t va, unsigned int size)
 *
 * Writeback and invalidate a virtual address range in all caches.
 */
SWCACHE(clean_cache)

/*
 * void mips_sync_icache (vaddr_t va, unsigned int size)
 *
 * Synchronise i-cache with d-cache in this virtual address range;
 * often same as mips_clean_cache.
 */
SWCACHE(sync_icache)

/*
 * void mips_clean_dcache (vaddr_t va, unsigned int size)
 *
 * Writeback and invalidate a virtual address range in data caches.
 * Joint caches (i.e. combined I & D) will be cleaned too.
 */
SWCACHE(clean_dcache)

/*
 * void mips_clean_dcache_nowrite (vaddr_t va, unsigned int size)
 *
 * Invalidate a virtual address range in data caches.
 * Joint caches (i.e. combined I & D) will be cleaned too.
 * XXX Only safe if region is totally cache line aligned,
 * i.e. it doesn't share a cache line with other data.
 */
SWCACHE(clean_dcache_nowrite)

/*
 * void mips_lock_dcache (vaddr_t va, unsigned int size)
 *
 * Load and lock a block of data into the primary data cache
 */
SWCACHE(lock_dcache)

/*
 * void mips_lock_icache (vaddr_t va, unsigned int size)
 *
 * Load and lock a block of instructions into the primary instruction cache
 */
SWCACHE(lock_icache)

/*
 * void mips_lock_scache (vaddr_t va, unsigned int size)
 *
 * Load and lock a block of memory into the secondary cache
 */
SWCACHE(lock_scache)
