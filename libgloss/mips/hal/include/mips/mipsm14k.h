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
 * mips/m14k.h : MIPS M14K family coprocessor 0 definitions
 */


#ifndef _MIPSM14K_H_
#define _MIPSM14K_H_

#ifdef __cplusplus
extern "C" {
#endif

/* MIPS32 compliant */
#include "mips/m32c0.h"

/*
 * Processor-specific fields in Status Register  (CP0 Register 12, Select 0)
 * (Pro cores only)
 */
#define SR_CEE		0x00020000 	/* CorExtend Enable */

/*
 * Processor-specific exceptions in Cause Register (CP0 Register 13, Select 0)
 * (Pro cores only)
 */
#define EXC_CEU		17		/* CorExtend Unusable */

/*
 * Processor-specific fields in Config0 Register  (CP0 Register 16, Select 0)
 */
#define CFG0_K23MASK	0x70000000	/* KSEG2/3 cacheability */
#define CFG0_K23SHIFT	28
#define CFG0_KUMASK	0x0e000000	/* KUSEG cacheability */
#define CFG0_KUSHIFT	25
#define CFG0_ISP	0x01000000	/* I-side scratchpad ram */
#define CFG0_DSP	0x00800000	/* D-side scratchpad ram */
#define CFG0_UDI	0x00400000	/* UDI present */
#define CFG0_SB		0x00200000	/* SimpleBE bus mode */
#define CFG0_MDU	0x00100000	/* multiplier type (1=slow) */
#define CFG0_WC		0x00080000	/* config write enable */
#define CFG0_MM		0x00060000	/* write buffer merge mode */
#define  CFG0_MM_NONE	 0x00000000	 /* no merging */
#define  CFG0_MM_SYSAD	 0x00020000	 /* SysAD valid merging */
#define  CFG0_MM_FULL	 0x00040000	 /* full merging */
#define  CFG0_MM_RES	 0x00060000	 /* reserved */
#define CFG0_BM		0x00010000	/* burst order (0 = incremental) */

/* 
 * Implementation depedent cache coherency attributes for Config0.K0 field 
 */
#define CFG_C_WTHRU_NOALLOC	0
#define CFG_C_WTHRU_ALLOC	1

/*
 * Processor-specific fields in Debug Register  (CP0 Register 23, Select 0)
 */
#define DBG_DBD		0x80000000	/* branch delay slot */
#define DBG_DM		0x40000000	/* in debug mode */
#define DBG_NoDCR	0x20000000	/* dseg is not present */
#define DBG_LSNM	0x10000000	/* load/store dseg/remain */
#define DBG_DOZE	0x08000000	/* was in low power mode */
#define DBG_HALT	0x04000000	/* system bus clock was running */
#define DBG_COUNTDM	0x02000000	/* count reg counts in debug mode */
#define DBG_IBusEP	0x01000000	/* instruction bus error pending */
#define DBG_MCheckP	0x00800000	/* machine check pending */
#define DBG_CacheEP	0x00400000	/* cache error pending */
#define DBG_DBusEP	0x00200000	/* data bus error pending */
#define DBG_IEXI	0x00100000	/* imprecise exception inhibit */
#define DBG_DDBSimpr	0x00080000	/* debug data break store imprecise */
#define DBG_DDBLimpr	0x00040000	/* debug data break load imprecise */
#define DBG_VERMASK	0x00038000	/* EJTAG version */
#define DBG_VERSHIFT	15
#define DBG_DEXCMASK	0x00007c00	/* latest exception code */
#define DBG_DEXCSHIFT	10
#define DBG_NoSST	0x00000200	/* no single-step */
#define DBG_SST		0x00000100	/* single-step enable */
#define DBG_DINT	0x00000020	/* debug interrupt exception */
#define DBG_DIB		0x00000010	/* debug instruction break */
#define DBG_DDBS	0x00000008	/* debug data break on store */
#define DBG_DDBL	0x00000004	/* debug data break on load */
#define DBG_DBP		0x00000002	/* debug breakpoint */
#define DBG_DSS		0x00000001	/* debug single-step */

/* ErrCtl Register (CP0 Register 26, Select 0) */
#define ERRCTL_WST	0x20000000	/* way select / tag array */
#define ERRCTL_SPR	0x10000000	/* scratchpad ram select */

/* MIPS32 CacheErr Register (CP0 Register 27, Select 0) - not implemented */
#undef C0_CACHEERR

/* CPU-specific CACHE instruction opcodes */
#define Index_Store_Data_I               0x0c        /* 3       0 */
#define Index_Store_Data_D               0x0d        /* 3       1 */

#ifdef __cplusplus
}
#endif
#endif /* _MIPSM14K_H_ */
