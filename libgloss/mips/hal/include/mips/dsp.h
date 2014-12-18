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
 * mips/dsp.h: MIPS DSP ASE definitions
 */


#ifndef _MIPS_ASE_H_
#define _MIPS_ASE_H_

/* 32-bit DSP Control register */
#define DSPCTL_POS_SHIFT	0
#define DSPCTL_POS_MASK		0x0000007f
#define DSPCTL_SCOUNT_SHIFT	7
#define DSPCTL_SCOUNT_MASK	0x00001f80
#define DSPCTL_C		0x00002000
#define DSPCTL_OU_SHIFT		16
#define DSPCTL_OU_MASK		0x00ff0000
#define  DSPCTL_OU_AC0OVF	 0x00010000
#define  DSPCTL_OU_AC1OVF	 0x00020000
#define  DSPCTL_OU_AC2OVF	 0x00040000
#define  DSPCTL_OU_AC3OVF	 0x00080000
#define  DSPCTL_OU_ALUOVF	 0x00100000
#define  DSPCTL_OU_MULOVF	 0x00200000
#define  DSPCTL_OU_SHFOVF	 0x00400000
#define  DSPCTL_OU_EXTOVF	 0x00800000
#define DSPCTL_CCOND_SHIFT	24
#define DSPCTL_CCOND_MASK	0x0f000000

/* RDDSP/WRDSP instruction mask bits */
#define RWDSP_POS		0x01
#define RWDSP_SCOUNT		0x02
#define RWDSP_C			0x04
#define RWDSP_OU		0x08
#define RWDSP_CCOND		0x10

#endif /* _MIPS_DSP_H_ */
