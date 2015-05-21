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
 * m64_xpatlb.h: MIPS XPA TLB support functions
*/
#ifndef _M64TLB_H_
#define _M64TLB_H_

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
#ifndef __ASSEMBLER__

typedef unsigned long long tlbhi64_t;
typedef unsigned long long tlblo64_t;
// Returns the size of the TLB.
int m64_tlb_size (void);

// Probes the TLB for an entry matching hi, and if present invalidates it.
void m64_tlbinval (tlbhi64_t hi);

// Invalidate the whole TLB.
void m64_tlbinvalall (void);

// Reads the TLB entry with specified by index, and returns the EntryHi, 
// EntryLo0, EntryLo1 and PageMask parts in *phi, *plo0, *plo1 and *pmsk 
// respectively.
void m64_tlbri2 (tlbhi64_t *phi, tlblo64_t *plo0, tlblo64_t *plo1, 
	unsigned long long *pmsk, int index);

// Writes hi, lo0, lo1 and msk into the TLB entry specified by index.
void m64_tlbwi2 (tlbhi64_t hi, tlblo64_t lo0, tlblo64_t lo1, 
	unsigned long long msk, int index);

// Writes hi, lo0, lo1 and msk into the TLB entry specified by the 
// Random register.
void m64_tlbwr2 (tlbhi64_t hi, tlblo64_t lo0, tlblo64_t lo1, 
	unsigned long long msk);

// Probes the TLB for an entry matching hi and returns its index, or -1 if 
// not found. If found, then the EntryLo0, EntryLo1 and PageMask parts of the 
// entry are also returned in *plo0, *plo1 and *pmsk respectively
int m64_tlbprobe2 (tlbhi64_t hi, tlblo64_t *plo0, tlblo64_t *plo1, 
	unsigned long long *pmsk);

// Probes the TLB for an entry matching hi and if present rewrites that entry, 
// otherwise updates a random entry. A safe way to update the TLB.
int m64_tlbrwr2 (tlbhi64_t hi, tlblo64_t lo0, tlblo64_t lo1, 
	unsigned long long  msk);

// Init the TLB.
void m64_init_tlb();
#endif /* __ASSEMBLER__ */

#endif /* _M64TLB_H_ */
