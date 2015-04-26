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
 * mips/mips32.h : MIPS32 intrinsics
 */

#ifndef _MIPS32_H_
#define _MIPS32_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifndef __ASSEMBLER__

#if ! __mips16

/* C interface to clz/clo instructions */

/* count leading zeros */
# define mips_clz(x) __builtin_clz (x)

/* count trailing zeros */
# define mips_ctz(x) __builtin_ctz (x)

#define mips_clo(x) __extension__({ \
    unsigned int __x = (x); \
    unsigned int __v; \
    __asm__ ("clo %0,%1" : "=d" (__v) : "d" (__x)); \
    __v; \
})

#ifndef __mips64

/* Simulate 64-bit count leading zeroes */
#define mips_dclz(x) __extension__({ \
    unsigned long long __x = (x); \
    unsigned int __hx = (__x >> 32); \
    __hx ? mips_clz(__hx) : 32 + mips_clz(__x); \
})

/* Simulate 64-bit count leading ones */
#define mips_dclo(x) __extension__({ \
    unsigned long long __x = (x); \
    unsigned int __hx = (__x >> 32); \
    (~__hx) ? mips_clo(__hx) : 32 + mips_clo(__x); \
})

/* Simulate 64-bit count trailing zeroes */
#define mips_dctz(x) __extension__({ \
    unsigned long long __dx = (x); \
    unsigned int __ldx = __dx; \
    unsigned int __hdx = __dx >> 32; \
    __ldx ? mips_ctz(__ldx) : (63 ^ mips_clz(__hdx & -__hdx)); \
   })
#endif

/* MIPS32r2 wsbh opcode */
#define _mips32r2_wsbh(x) __extension__({ \
    unsigned int __x = (x), __v; \
    __asm__ ("wsbh %0,%1" \
	     : "=d" (__v) \
	     : "d" (__x)); \
    __v; \
})

/* MIPS32r2 byte-swap word */
#define _mips32r2_bswapw(x) __extension__({ \
    unsigned int __x = (x), __v; \
    __asm__ ("wsbh %0,%1; rotr %0,16" \
	     : "=d" (__v) \
	     : "d" (__x)); \
    __v; \
})

/* MIPS32r2 insert bits */
#define _mips32r2_ins(tgt,val,pos,sz) __extension__({ \
    unsigned int __t = (tgt), __v = (val); \
    __asm__ ("ins %0,%z1,%2,%3" \
	     : "+d" (__t) \
	     : "dJ" (__v), "I" (pos), "I" (sz)); \
    __t; \
})

/* MIPS32r2 extract bits */
#define _mips32r2_ext(x,pos,sz) __extension__({ \
    unsigned int __x = (x), __v; \
    __asm__ ("ext %0,%z1,%2,%3" \
	     : "=d" (__v) \
	     : "dJ" (__x), "I" (pos), "I" (sz)); \
    __v; \
})

#endif /* ! __mips16 */

#endif /* __ASSEMBLER__ */

#ifdef __cplusplus
}
#endif

#endif /* _MIPS32_H_ */
