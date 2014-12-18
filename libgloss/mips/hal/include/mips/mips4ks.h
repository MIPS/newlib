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
 * mips/mips4ks.h : MIPS 4KS family coprocessor 0 definitions
 */


#ifndef _MIPS4KS_H_
#define _MIPS4KS_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __ASSEMBLER__

#define C0_SCTRL	$22,0	/* SecurityCtrl */
#define C0_SSWPRNG	$22,1	/* SecuritySwPRNG */
#define C0_SHWSPRN	$22,2	/* SecurityHwPRNG (w/o) */
#define C0_SSCRAMBL	$22,3	/* SecurityScrambling (w/o) */

#else

/* 
 * 4KS SecurityCtrl register  (CP0 Register 22, Select 0)
 */
#define mips32_getsctrl()	_m32c0_mfc0(22,0)
#define mips32_setsctrl(x)	_m32c0_mtc0(22,0,x)
#define mips32_xchsctrl(x)	_m32c0_mxc0(22,0,x)

/* 
 * 4KS SecuritySwPRNG register  (CP0 Register 22, Select 1)
 */
#define mips32_getsswprng()	_m32c0_mfc0(22,1)
#define mips32_setsswprng(x)	_m32c0_mtc0(22,1,x)

/* 
 * 4KS SecurityHwPRNG register  (CP0 Register 22, Select 2)
 * Note: write-only
 */
#define mips32_setshwprng(x)	_m32c0_mtc0(22,2,x)

/* 
 * 4KS SecurityScramble register  (CP0 Register 22, Select 3)
 * Note: write-only
 */
#define mips32_setsscrmbl(x)	_m32c0_mtc0(22,3,x)

#endif

/* 
 * 4KS SecurityCtrl register  (CP0 Register 22, Select 0)
 */
#define C0_SCTRL_SEL_MASK	0x00ff0000
#define C0_SCTRL_SEL_SHFT	16
#define C0_SCTRL_CL		0x00000100
#define C0_SCTRL_RSI_MASK	0x00000007
#define C0_SCTRL_RSI_SHFT	0

#ifdef __cplusplus
}
#endif
#endif /* _MIPS4KS_H_ */
