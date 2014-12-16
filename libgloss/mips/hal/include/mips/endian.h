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
 * mips/endian.h : MIPS-specific endian definitions
 */

#ifndef _MIPS_ENDIAN_H_
#define _MIPS_ENDIAN_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifndef __ASSEMBLER__
#include <stdint.h>	/* get compiler types */
#include <sys/types.h>
#endif

#ifndef BYTE_ORDER
/*
 * Definitions for byte order,
 * according to byte significance from low address to high.
 */
#define LITTLE_ENDIAN   1234    /* least-significant byte first (vax) */
#define BIG_ENDIAN      4321    /* most-significant byte first (IBM, net) */

#if defined(__MIPSEB__) || defined(MIPSEB)
#define BYTE_ORDER      BIG_ENDIAN
#elif defined(__MIPSEL__) || defined(MIPSEL)
#define BYTE_ORDER      LITTLE_ENDIAN
#else
#error BYTE_ORDER 
#endif

#ifndef __ASSEMBLER__

#if __mips_isa_rev >= 2 && ! __mips16

/* MIPS32r2 & MIPS64r2 can use the wsbh and rotate instructions, define
   MD_SWAP so that <sys/endian.h> will use them. */

#define MD_SWAP

#define __swap16md(x) __extension__({					\
    uint16_t __swap16md_x = (x);					\
    uint16_t __swap16md_v;						\
    __asm__ ("wsbh %0,%1" 						\
	     : "=d" (__swap16md_v) 					\
	     : "d" (__swap16md_x)); 					\
    __swap16md_v; 							\
})

#define __swap32md(x) __extension__({					\
    uint32_t __swap32md_x = (x);					\
    uint32_t __swap32md_v;						\
    __asm__ ("wsbh %0,%1; rotr %0,16" 					\
	     : "=d" (__swap32md_v) 					\
	     : "d" (__swap32md_x)); 					\
    __swap32md_v; 							\
})

#elif defined(__OPTIMIZE_SIZE__) && !defined(_POSIX_SOURCE)

#define MD_SWAP

/* When optimizing for size, better to call a shared worker function,
   unless the code is small enough or there's only one use of the
   function, in which case it will be inlined. */

#include <sys/cdefs.h>
#include <sys/swap.h>

#ifdef __cplusplus
extern "C" {
#endif

extern __inline__ uint16_t __swap16md (uint16_t x)
{
    return __swap16gen(x);
}

extern __inline__ uint32_t __swap32md (uint32_t x)
{
    return __swap32gen(x);
}

#ifdef __cplusplus
}
#endif

#endif
#endif /* __ASSEMBLER__ */
#endif	/* BYTE_ORDER */

#include <machine/endian.h>

#ifdef __cplusplus
}
#endif
#endif /*_MIPS_ENDIAN_H_*/
