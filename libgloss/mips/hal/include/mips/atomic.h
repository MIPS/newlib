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
 * mips/atomic.h: atomic r-m-w memory operations
 */

#ifndef _MIPS_ATOMIC_H_
#ifdef __cplusplus
extern "C" {
#endif
#define _MIPS_ATOMIC_H_

/* 
 * The atomic_update() primitive provides a range of atomic operations
 * on the 32-bit word pointed to by its first argument.  In all cases 
 * the previous value of the word is returned.
 * 
 * The primitive is used to implement the following functions: 
 * bis = bit set; bic = bit clear; flip = bit clear and set;
 * swap = swap; add = increment/decrement.
 */

/* FIXME it's not true that all MIPS II+ ISAs support ll/sc */

#if __mips >= 2 
#define _mips_atomic_update(wp, clear, addend)		\
    __extension__ ({unsigned int __old, __tmp;		\
      __asm__ __volatile__ (				\
"1:	ll	%0,%1\n"				\
"	and	%2,%0,%3\n"				\
"	addu	%2,%4\n"				\
"	sc	%2,%1\n"				\
"	beqz	%2,1b"					\
	: "=&d" (__old), "+m" (*(wp)), "=&d" (__tmp)	\
	: "dJK" (~(clear)), "dJI" (addend)); 		\
      __old; })

/*
 * The atomic_cas() primitive implements compare-and-swap.
 * The old value of the word is returned.
 */
#define _mips_atomic_cas(wp, new, cmp)			\
    __extension__ ({unsigned int __old, __tmp;		\
      __asm__ __volatile__ (				\
"1:	ll	%0,%1\n"				\
"	%(bne	%0,%z3,2f\n"				\
"	move	%2,%z4%)\n"				\
"	sc	%2,%1\n"				\
"	beqz	%2,1b\n"				\
"2:"							\
	: "=&d" (__old), "+m" (*(wp)), "=&d" (__tmp)	\
	: "dJ" (cmp), "dJ" (new)); 			\
      __old; })
#else
extern unsigned int	_mips_atomic_update (volatile unsigned int *,
					     unsigned int, unsigned int);
extern unsigned int	_mips_atomic_cas (volatile unsigned int *,
					  unsigned int, unsigned int);
#endif

#define mips_atomic_bis(wp, val)	_mips_atomic_update(wp,val,val)
#define mips_atomic_bic(wp, val)	_mips_atomic_update(wp,val,0)
#define mips_atomic_bcs(wp, clr, set)	_mips_atomic_update(wp,(clr)|(set),set)
#define mips_atomic_flip(wp, clr, set)	_mips_atomic_update(wp,(clr)|(set),set)
#define mips_atomic_swap(wp, val)	_mips_atomic_update(wp,~0,val)
#define mips_atomic_add(wp, val)	_mips_atomic_update(wp,0,val)
#define mips_atomic_inc(wp)		_mips_atomic_update(wp,0,1)
#define mips_atomic_dec(wp)		_mips_atomic_update(wp,0,-1)
#define mips_atomic_cas(wp, new, cmp)	_mips_atomic_cas(wp,new,cmp)

#ifdef __cplusplus
}
#endif
#endif /*_MIPS_ATOMIC_H_*/
