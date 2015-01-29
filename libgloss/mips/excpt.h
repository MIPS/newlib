/*****************************************************************************
;
;               file : $File$
;  date last revised : $Date$
;
;          copyright : 2013 - 2014 by Imagination Technologies.
;                      All rights reserved.
;                      No part of this software, either material or conceptual
;                      may be copied or distributed, transmitted, transcribed,
;                      stored in a retrieval system or translated into any
;                      human or computer language in any form by any means,
;                      electronic, mechanical, manual or otherwise, or
;                      disclosed to third parties without the express written
;                      permission of:
;                        Imagination Technologies, Home Park Estate,
;                        Kings Langley, Hertfordshire, WD4 8LZ, U.K.
;
;        description : MIPS common kernel specialisation
;
;*****************************************************************************/

#ifndef _EXCPT_H
#define _EXCPT_H

#if (defined (__mips64) && (_MIPS_SIM == _ABI64 || _MIPS_SIM == _ABIO64 || \
     _MIPS_SIM == _ABIN32 || defined (__mips_eabi)))
#define STRIDE	8
#else
#define STRIDE	4
#endif
#if (defined (__mips64) && (defined (_MIPS_SIM) && _MIPS_SIM == _ABI64) \
     || defined (__mips_eabi))
#define PTR_SIZE 8
#else
#define PTR_SIZE 4
#endif

#ifndef __ASSEMBLER__
#include <stdint.h>
#if STRIDE==4
typedef uint32_t regtype;
#else
typedef uint64_t regtype;
#endif
#endif

#define CTX_AT		((STRIDE)*0)
#define CTX_V0		((STRIDE)*1)
#define CTX_V1		((STRIDE)*2)
#define CTX_A0		((STRIDE)*3)
#define CTX_A1		((STRIDE)*4)
#define CTX_A2		((STRIDE)*5)
#define CTX_A3		((STRIDE)*6)
#define CTX_T0		((STRIDE)*7)
#define CTX_T1		((STRIDE)*8)
#define CTX_T2		((STRIDE)*9)
#define CTX_T3		((STRIDE)*10)
#define CTX_T4		((STRIDE)*11)
#define CTX_T5		((STRIDE)*12)
#define CTX_T6		((STRIDE)*13)
#define CTX_T7		((STRIDE)*14)
#define CTX_S0		((STRIDE)*15)
#define CTX_S1		((STRIDE)*16)
#define CTX_S2		((STRIDE)*17)
#define CTX_S3		((STRIDE)*18)
#define CTX_S4		((STRIDE)*19)
#define CTX_S5		((STRIDE)*20)
#define CTX_S6		((STRIDE)*21)
#define CTX_S7		((STRIDE)*22)
#define CTX_T8		((STRIDE)*23)
#define CTX_T9		((STRIDE)*24)
#define CTX_K0		((STRIDE)*25)
#define CTX_K1		((STRIDE)*26)
#define CTX_GP		((STRIDE)*27)
#define CTX_SP		((STRIDE)*28)
#define CTX_FP		((STRIDE)*29)
#define CTX_RA		((STRIDE)*30)
#define CTX_EPC		((STRIDE)*31)
#define CTX_BADVADDR	((STRIDE)*32)
#define CTX_HI0		((STRIDE)*33)
#define CTX_LO0		((STRIDE)*34)
#define CTX_LINK	((STRIDE)*35)
#define CTX_STATUS	(((STRIDE)*35)+PTR_SIZE)
#define CTX_CAUSE	(((STRIDE)*35)+PTR_SIZE+4)
#define CTX_BADINSTR	(((STRIDE)*35)+PTR_SIZE+8)
#define CTX_BADPINSTR	(((STRIDE)*35)+PTR_SIZE+12)
#define CTX_SIZE	(((STRIDE)*35)+PTR_SIZE+16)

#ifndef __ASSEMBLER__

struct gpctx
{
  regtype at;
  regtype v[2];
  regtype a[4];
  regtype t[8];
  regtype s[8];
  regtype t2[2];
  regtype k[2];
  regtype gp;
  regtype sp;
  regtype fp;
  regtype ra;
  regtype epc;
  regtype badvaddr;
  regtype hi;
  regtype lo;
  /* This field is for future extension */
  void *link;
  /* Status represents the status at the point of exception but
     with EXL cleared */
  uint32_t status;
  /* These fields should be considered read-only */
  uint32_t cause;
  uint32_t badinstr;
  uint32_t badpinstr;
};

/*
 * Give the C library a chance to process an exception. Returns non-zero if
 * handled.
 */
extern int _mips_handle_exception(struct gpctx *ctx, int exception);

#endif
#endif
