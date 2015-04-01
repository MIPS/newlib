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
 * m32tlb.h: MIPS32 TLB support functions


	.set	nomips16
*/
#if __mips != 32 && __mips != 64
#error use -mips32 or -mips64 option with this file
#endif

#include <mips/asm.h>
#include <mips/regdef.h>
#include <mips/m32c0.h>
#include <mips/notlb.h>

/*
 * Although this not an R4000 cpu, the TLB follows exactly the
 * R4000 architecture, so we use the same function names.
 * Note that pessimistic R4000 hazard timings are also used.
 *
 * XXX we could probably do with a switcher like cache.sx
 */

#if __mips64
#define rmfc0	dmfc0
#define rmtc0	dmtc0
#define sr	sd
#else
#define rmfc0	mfc0
#define rmtc0	mtc0
#define sr	sw
#endif

#if __mips_isa_rev >= 2
/* ssnop not needed with ehb explicit hazard barrier */
#define ssnop
#endif
