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
 * mips/mips64.h : MIPS64 intrinsics
 */

#ifndef _MIPS64_H_
#define _MIPS64_H_

#include <mips/mips32.h>

#if __mips_isa_rev >= 6
#include <mips/m64r6cm3.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifndef __ASSEMBLER__

#if __mips == 64 && ! __mips16

# if __GNUC__ > 3 || (__GNUC__ == 3 && __GNUC_MINOR__ >= 4)
/* use GCC builtins for better optimisation */

/* 64-bit count leading zeroes */
# define mips_dclz(x) __builtin_clzll (x)

/* 64-bit count trailing zeroes */
# define mips_dctz(x) __builtin_ctzll (x)

#else

/* 64-bit count leading zeroes */
#define mips_dclz(x) __extension__({ \
    unsigned long long __x = (x); \
    unsigned int __v; \
    __asm__ ("dclz %0,%1" : "=d" (__v) : "d" (__x)); \
    __v; \
})

/* 64-bit count trailing zeroes */
#define mips_dctz(x) (63 ^ mips_dclz ((x) & -(x)))

#endif

#define mips_dclo(x) __extension__({ \
    unsigned long long __x = (x); \
    unsigned int __v; \
    __asm__ ("dclo %0,%1" : "=d" (__v) : "d" (__x)); \
    __v; \
})

#if __mips_isa_rev >= 2

/* MIPS64r2 dshd opcode */
#define _mips64r2_dshd(x) __extension__({ \
    unsigned long long __x = (x), __v; \
    __asm__ ("dshd %0,%1" \
	     : "=d" (__v) \
	     : "d" (__x)); \
    __v; \
})

/* MIPS64r2 dsbh opcode */
#define _mips64r2_dsbh(x) __extension__({ \
    unsigned long long __x = (x), __v; \
    __asm__ ("dsbh %0,%1" \
	     : "=d" (__v) \
	     : "d" (__x)); \
    __v; \
})

/* MIPS64r2 byte-swap doubleword */
#define _mips64r2_bswapd(x) __extension__({ \
    unsigned long long __x = (x), __v; \
    __asm__ ("dsbh %0,%1; dshd %0,%0" \
	     : "=d" (__v) \
	     : "d" (__x)); \
    __v; \
})

/* MIPS64r2 insert bits */
#define _mips64r2_dins(tgt,val,pos,sz) __extension__({ \
    unsigned long long __t = (tgt), __v = (val); \
    __asm__ ("dins %0,%z1,%2,%3" \
	     : "+d" (__t) \
	     : "dJ" (__v), "I" (pos), "I" (sz)); \
    __t; \
})

/* MIPS64r2 extract bits */
#define _mips64r2_dext(x,pos,sz) __extension__({ \
    unsigned long long __x = (x), __v; \
    __asm__ ("dext %0,%z1,%2,%3" \
	     : "=d" (__v) \
	     : "dJ" (__x), "I" (pos), "I" (sz)); \
    __v; \
})

#endif /* __mips_isa_rev >= 2 */

#endif /* __mips == 64 && ! __mips16 */

#endif /* __ASSEMBLER__ */

#ifdef __cplusplus
}
#endif

#endif /* _MIPS64_H_ */
