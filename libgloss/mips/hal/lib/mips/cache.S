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
 * cache.sx: switchable cache support
 */

#include "cache.h"

DECL(mips_icache_size,-1)
DECL(mips_icache_linesize,-1)
DECL(mips_icache_ways,1)

DECL(mips_dcache_size,-1)
DECL(mips_dcache_linesize,-1)
DECL(mips_dcache_ways,1)

DECL(mips_scache_size,-1)
DECL(mips_scache_linesize,-1)
DECL(mips_scache_ways,1)

DECL(mips_tcache_size,-1)
DECL(mips_tcache_linesize,-1)
DECL(mips_tcache_ways,1)

/*
 * void mips_size_cache (void)
 *
 * Size caches without reinitialising and losing dirty cache lines.
 */
SWCACHE(size_cache)

/*
 * void mips_clean_icache (vaddr_t va, unsigned int size)
 *
 * Writeback and invalidate a virtual address range in instruction caches.
 * Joint caches (i.e. combined I & D) will be cleaned too.
 */
SWCACHE(clean_icache)
