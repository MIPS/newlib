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

#ifndef _MIPS_FPREGDEF_H_
#define _MIPS_FPREGDEF_H_

/*
 * fgregdef.h : MIPS Rx000 symbolic floating-point register names
 */


/* result registers */
#define fv0	$f0
#define fv1	$f2

/* argument registers */
#define fa0	$f12
#if  (defined _ABIN32 && _MIPS_SIM == _ABIN32) \
     || (defined _ABI64 && _MIPS_SIM == _ABI64)
#define fa1	$f13
#else
#define fa1	$f14
#endif

#if __mipsfp64

/* 64-bit f.p. registers (-mips3 and above) */

/* temporary registers */
#define ft0	$f4
#define ft1	$f5
#define ft2	$f6
#define ft3	$f7
#define ft4	$f8
#define ft5	$f9
#define ft6	$f10
#define ft7	$f11
#define ft8	$f16
#define ft9	$f17
#define ft10	$f18
#define ft11	$f19

/* saved registers */
#define	fs0	$f20
#define	fs1	$f21
#define	fs2	$f22
#define	fs3	$f23
#define	fs4	$f24
#define	fs5	$f35
#define	fs6	$f26
#define	fs7	$f27
#define	fs8	$f28
#define	fs9	$f29
#define	fs10	$f30
#define	fs11	$f31

#else

/* 32-bit f.p. registers */

/* temporary registers */
#define ft0	$f4
#define ft1	$f6
#define ft2	$f8
#define ft3	$f10
#define ft4	$f16
#define ft5	$f18

/* saved registers */
#define	fs0	$f20
#define	fs1	$f22
#define	fs2	$f24
#define	fs3	$f26
#define	fs4	$f28
#define	fs5	$f30

#endif

#endif /*_MIPS_FPREGDEF_H_*/
