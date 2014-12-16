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
 * notlb.h : MIPS stub MMU/TLB definitions
 */


#ifndef _NOTLB_H_
#define _NOTLB_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifndef ROM_BASE
#define ROM_BASE	0xbfc00000	/* standard ROM base address */
#endif

#ifdef __ASSEMBLER__

/* 
 * Stub 32-bit memory regions 
 */
#define	KSEG0_BASE	0x80000000
#define	KSEG1_BASE	0xa0000000
#define KSEG0_SIZE	0x20000000
#define KSEG1_SIZE	0x20000000
#define RVEC_BASE	ROM_BASE

/* 
 * Translate a kernel address in KSEG0 or KSEG1 to a real
 * physical address and back.
 */
#define KVA_TO_PA(v) 	((v) & 0x1fffffff)
#define PA_TO_KVA0(pa)	((pa) | 0x80000000)
#define PA_TO_KVA1(pa)	((pa) | 0xa0000000)

/* translate between KSEG0 and KSEG1 addresses */
#define KVA0_TO_KVA1(v)	((v) | 0x20000000)
#define KVA1_TO_KVA0(v)	((v) & ~0x20000000)

#else /* __ASSEMBLER__ */
/*
 * Standard address types
 */
#ifndef _PADDR_T_DEFINED_
typedef unsigned long		paddr_t;	/* a physical address */
#define _PADDR_T_DEFINED_
#endif
#ifndef _VADDR_T_DEFINED_
typedef unsigned long		vaddr_t;	/* a virtual address */
#define _VADDR_T_DEFINED_
#endif

/* 
 * Stub 32-bit memory regions 
 */
#define KSEG0_BASE	((void  *)0x80000000)
#define KSEG1_BASE	((void  *)0xa0000000)
#define KSEG0_SIZE	0x20000000u
#define KSEG1_SIZE	0x20000000u

#define RVEC_BASE	((void *)ROM_BASE)	/* reset vector base */

/* 
 * Translate a kernel virtual address in KSEG0 or KSEG1 to a real
 * physical address and back.
 */
#define KVA_TO_PA(v) 	((paddr_t)(v) & 0x1fffffff)
#define PA_TO_KVA0(pa)	((void *) ((pa) | 0x80000000))
#define PA_TO_KVA1(pa)	((void *) ((pa) | 0xa0000000))

/* translate between KSEG0 and KSEG1 virtual addresses */
#define KVA0_TO_KVA1(v)	((void *) ((unsigned)(v) | 0x20000000))
#define KVA1_TO_KVA0(v)	((void *) ((unsigned)(v) & ~0x20000000))

/* Test for KSEGS */
#define IS_KVA(v)	((int)(v) < 0)
#define IS_KVA0(v)	(((unsigned)(v) >> 29) == 0x4)
#define IS_KVA1(v)	(((unsigned)(v) >> 29) == 0x5)
#define IS_KVA01(v)	(((unsigned)(v) >> 30) == 0x2)

/* convert register type to address and back */
#define VA_TO_REG(v)	((long)(v))		/* sign-extend 32->64 */
#define REG_TO_VA(v)	((void *)(long)(v))	/* truncate 64->32 */

#endif /* __ASSEMBLER__ */

#ifdef __cplusplus
}
#endif
#endif /* _NOTLB_H_*/
