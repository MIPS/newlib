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
 * m64r6cm3.h : MIPS64R6 CM3 definitions
 */

#ifndef _M64R6CM3_H_
#define _M64R6CM3_H_

#ifdef __cplusplus
extern "C" {
#endif

#define CMGCRBase		$15,3
#define CMGCR_BASE_ADDR_SHIFT	11

#define CFG3_CMGCRMASK		0x20000000
#define CFG3_CMGCRSHIFT		29

/* Offsets of memory-mapped registers */
#define GCR_L2_CONFIG		0x130
#define GCR_TAG_ADDR		0x600
#define GCR_TAG_STATE		0x608
#define GCR_TAG_DATA		0x610

#ifndef __ASSEMBLER__
void m64r6_size_cache (void);
void m64r6_init_cache (void);
void m64r6_flush_cache (void);
void m64r6_flush_dcache (void);
void m64r6_flush_icache (void);
void m64r6_sync_icache (vaddr_t va, unsigned int size);
void m64r6_clean_cache (vaddr_t va, unsigned int size);
void m64r6_clean_icache (vaddr_t va, unsigned int size);
void m64r6_clean_dcache (vaddr_t va, unsigned int size);
void m64r6_clean_dcache_nowrite (vaddr_t va, unsigned int size);
void m64r6_lock_dcache (vaddr_t va, unsigned int size);
void m64r6_lock_icache (vaddr_t va, unsigned int size);
void m64r6_lock_scache (vaddr_t va, unsigned int size);
#endif

#ifdef __cplusplus
}
#endif

#endif /* _M64R6CM3_H_ */
