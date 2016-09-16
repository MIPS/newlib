/*
 * Copyright (c) 2012-2016
 *      MIPS Technologies, Inc., California.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the MIPS Technologies, Inc., nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE MIPS TECHNOLOGIES, INC. ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE MIPS TECHNOLOGIES, INC. BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include "machine/asm.h"
#include "machine/regdef.h"
		
LEAF(mystrcpy)

	.set	nomips16
	.set	noreorder

/* Find if both strings are aligned */		
	or	t0, a0, a1
	andi	t0, t0, 0x3
	beqc	t0, zero, aligned

unaligned:
/* Align the destination (a0) */
	andi	t8, a0, 7
	auipc	t9, %pcrel_hi(jtable)
	addiu	t9, t9, %pcrel_lo(jtable)
	lsa	t9, t8, t9, 1
	jrc	t9
jtable:
	bc	lb0
	bc	lb3
	bc	lb2
	bc	lb1
lb3:
	lb	a3, 2(a1)
	sb	a3, 2(a0)
lb2:
	lb	a3, 1(a1)
	sb	a3, 1(a0)
lb1:
	lb	a3, 0(a1)
	lb	a3, 0(a0)

	li	t9, 4
	subu	t8, t9, t8
	addu	a0, a0, t8
	addu	a1, a1, t8

lb0:
/* Destination is now aligned. Check if source is also aligned */
	andi	t0, a1, 3
	
aligned:		
/* Both strings are 4 byte aligned at this point.  */
	lui	t8, 0x01010
	ori	t8, t8, 0x101
	lui	t9, 0x7f7f7
	ori	t9, t9, 0xf7f
	bnec	t0, zero, unalignedSrc
		
wordloop:
	lw	v1, 0(a1)
	subu	t0, v1, t8
	nor	t1, v1, t9
	and	t0, t0, t1
	bnec	t0, zero, finishcopy
	addiu	a1, a1, 4
	sw	v1, 0(a0)
	addiu	a0, a0, 4
	bc	wordloop

unalignedSrc:
	ualw	v1, 0(a1)
	subu	t0, v1, t8
	nor	t1, v1, t9
	and	t0, t0, t1
	bnec	t0, zero, finishcopy
	addiu	a1, a1, 4
	sw	v1, 0(a0)
	addiu	a0, a0, 4
	bc	unalignedSrc	

finishcopy:
# if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
	andi	t8, v1, 0xff
	beqc	t8, zero, bexit
	sb	t8, 0(a0)
	srl	v1, v1, 8
	andi	t8, v1, 0xff
	beqc	t8, zero, bexit
	sb	t8, 1(a0)
	srl	v1, v1, 8
	andi	t8, v1, 0xff
	beqc	t8, zero, bexit
	sb	t8, 2(a0)
	srl	v1, v1, 8
	sb	v1, 3(a0)
# else
	srl	t8, v1, 24
	beqc	t8, zero, bexit
	sb	t8, 0(a0)
	srl	t8, v1, 16
	andi	t8, t8, 0xff
	beqc	t8, zero, bexit
	sb	t8, 1(a0)
	srl	t8, v1, 8
	andi	t8, t8, 0xff
	beqc	t8, zero, bexit
	sb	t8, 2(a0)
	sb	v1, 3(a0)
# endif
		
bexit:		
	jrc	ra
	
	.set	at
	.set	reorder
END(mystrcpy)
