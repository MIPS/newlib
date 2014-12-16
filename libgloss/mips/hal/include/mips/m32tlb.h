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
 * m32tlb.h : MIPS32 MMU definitions
 */


#ifndef _M32TLB_H_
#define _M32TLB_H_

#ifdef __cplusplus
extern "C" {
#endif

/* XXX For the moment we just share the R4000 definitions, but
   we need to add support for BAT based processor variants. */
#include <mips/r4ktlb.h>

/* MIPS32r2 EntryLo extended page frame address bits */
#if __mips == 64 || __mips64
#define TLB_PFNXMASK	0x007fffffc0000000LL
#else
#define TLB_PFNXMASK	0xc0000000
#endif
#define TLB_PFNXSHIFT	29

#ifdef __cplusplus
}
#endif
#endif /* _M32TLB_H_ */

