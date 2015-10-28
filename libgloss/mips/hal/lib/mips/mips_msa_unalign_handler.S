/*
 * Copyright 2015, Imagination Technologies Limited and/or its
 *                 affiliated group companies.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its
 * contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
*/

#include <mips/asm.h>
#include <mips/regdef.h>
#include <mips/m32c0.h>
#include <mips/hal.h>
#include <mips/endian.h>

#if __mips_isa_rev < 6 || !defined(__mips_micromips)
.module hardfloat
.module doublefloat
#undef fp
.module fp=64
.module msa

#
# FUNCTION:	_msa_unaligned_handler
#
# DESCRIPTION:	Emulate a MSA ld.df or st.df that has caused an	Address error
#		exception. Values are loaded to or stored from the saved MSA
#		context. This handler will tolerate any level of unaligned
#		access.
#
#		Failure modes: The badinstr pointer does not point to
#		an MSA ld/st. The context relating to MSA could not
#		be found.
#
# ARGUMENTS:	LINKCTX	a0
#
# RETURNS:	0 on success, 1 on failure.
#

LEAF(_msa_unaligned_handler)
	lw	a3, CTX_LINK(a0)
	li	t2, LINKCTX_TYPE_FMSA
	beqz	a3, .error

3:
	PTR_L	t1, 0(a3)
	beq	t2, t1, 2f

	beqz	t2, .error
	PTR_ADDU	a3, t1, SZREG
	b	3b

2:
	# Compute a pointer into the msa context structure
	PTR_L	t0, CTX_BADINSTR(a0)
	# Extract the msa reg to a2.
	ext	a2, t0, 6, 5
	# Compute the register's address in the link context structure.
	# Skipping struct linkctx and (f/msa)csr.
	PTR_ADDU	a3, a3, MSACTX_0
	# Scale the GPR number to sizeof(_msareg)
	sll	a2, a2, 4
	PTR_ADDU	a2, a3, a2
	# a2 now points to our msa ctx register.

	# Compute the effective address
	# Extract offset
	ext	a1, t0, 15, 10	# offset
	ext	t8, t0, 0, 2	# data format.
	sll	a1, a1, t8

	# Extract GPR contents
	ext	a3, t0, 11, 5	# base GPR
	beq	$0, a3, 1f

	addiu	a3, a3, -1
	sll	a3, a3, LOG2_SZPTR
	addu	a3, a0, a3
	PTR_L	v1, 0(a3)
	add	a1, a1, v1
1:
	# a1 will contain an aligned (4 byte) pointer to memory
	# v0 will contain the no. of bits will we will need to shift left.
	# v1 will contain the no. of bits will we will need to shift right.
	andi	v0, a1, 0x3
	xor	a1, v0, a1
	sll	v0, v0, 3
	li	v1, 32
	subu	v1, v1, v0

	# Determine store/load and minor opcode
	ext	t1, t0, 25, 6
	ext	t3, t0, 2, 4
	li	t2, 0x9
	beq	t3, t2, .msast

.msald:
	# emulate an MSA LD.df wd,s10(rs)
	# sanity check of minor opcode
	li	t2, 0x8
	bne	t3, t2, .error

	# Load an aligned 160 bit window covering the
	# original access.
	lw	t0, 0(a1)
	lw	t1, 4(a1)
	lw	t2, 8(a1)
	lw	t3, 12(a1)

	# If the source was at least 4 byte aligned and caused an address
	# exception we don't need to perform any shifts and can skip the
	# last load.
	beqz	v0, 4f
	lw	a3, 16(a1)
	# Shift the contents the window into t0-t3.
#if BYTE_ORDER == BIG_ENDIAN
	sllv	t0, t0, v0
	srlv	t9, t1, v1
	or	t0, t0, t9

	sllv	t1, t1, v0
	srlv	t9, t2, v1
	or	t1, t1, t9

	sllv	t2, t2, v0
	srlv	t9, t3, v1
	or	t2, t2, t9

	sllv	t3, t3, v0
	srlv	t9, a3, v1
	or	t3, t3, t9
#elif BYTE_ORDER == LITTLE_ENDIAN
	srlv	t0, t0, v0
	sllv	t9, t1, v1
	or	t0, t0, t9

	srlv	t1, t1, v0
	sllv	t9, t2, v1
	or	t1, t1, t9

	srlv	t2, t2, v0
	sllv	t9, t3, v1
	or	t2, t2, t9

	srlv	t3, t3, v0
	sllv	t9, a3, v1
	or	t3, t3, t9
#else
#error BYTE_ORDER undefined
#endif
4:
#if BYTE_ORDER == BIG_ENDIAN
	# Handle endian issues arising from element layout.
	#
	# _msactx_load uses ld.d which can swap the elements, but we have to
	# emulate ld.[bhwd], so swap the contents of registers around so that
	# the ld.d gives the results as expected.
	#
	# We'll need a chain of swaps to accomplish this.
	#
	# ld.b		Do all the byte swapping
	beqz	t8, 5f
	# ld.h		Only swap halfwords
	li	t9, 1
	beq	t8, t9,  6f
	# ld.w		Words, swapping is done through stores
	li	t9, 2
	beq	t8, t9, 7f
	# ld.d		Double words, just write out and return.
	sw	t0, 0(a2)
	sw	t1, 4(a2)
	sw	t2, 8(a2)
	sw	t3, 12(a2)
	b	8f
5:
	wsbh	t2, t2
	wsbh	t3, t3
	wsbh	t0, t0
	wsbh	t1, t1
6:
	rotr	t2, t2, 16
	rotr	t3, t3, 16
	rotr	t0, t0, 16
	rotr	t1, t1, 16
7:
	sw	t1, 0(a2)
	sw	t0, 4(a2)
	sw	t3, 8(a2)
	sw	t2, 12(a2)
#elif BYTE_ORDER == LITTLE_ENDIAN
	sw	t0, 0(a2)
	sw	t1, 4(a2)
	sw	t2, 8(a2)
	sw	t3, 12(a2)
#else
#error BYTE_ORDER undefined
#endif
8:
	li	v0, 0
	jr	ra

.msast:
#if BYTE_ORDER == BIG_ENDIAN
	lw	t1, 0(a2)
	lw	t0, 4(a2)
	lw	t3, 8(a2)
	lw	t2, 12(a2)
	# ld.b		Do all the byte swapping
	beqz	t8, 5f
	# ld.h		Only swap halfwords
	li	t9, 1
	beq	t8, t9,  6f
	# ld.w		Words, swapping is already done.
	li	t9, 2
	beq	t8, t9, 7f
	# ld.d		Double words, swap registers.
	move	t9, t1
	move	t1, t0
	move	t0, t9

	move	t9, t3
	move	t3, t2
	move	t2, t9

	b	7f
5:
	wsbh	t0, t0
	wsbh	t1, t1
	wsbh	t2, t2
	wsbh	t3, t3
6:
	rotr	t2, t2, 16
	rotr	t3, t3, 16
	rotr	t0, t0, 16
	rotr	t1, t1, 16
#elif BYTE_ORDER == LITTLE_ENDIAN
	lw	t0, 0(a2)
	lw	t1, 4(a2)
	lw	t2, 8(a2)
	lw	t3, 12(a2)
#else
#error BYTE_ORDER undefined
#endif
7:
	# As with the load if the destination is >=4 byte aligned
	# shifting is unnecessary.
	beqz	v0, 5f

	lw	a3, 0(a1)
#if BYTE_ORDER == BIG_ENDIAN
	# First partial word
	# Get the top part of t0, that will become the bottom part of (a1)
	srlv	t9, t0, v0
	# Top half of (a1)
	srlv	a3, a3, v1
	sllv	a3, a3, v1
	move	t8, t0
	or	t0, a3, t9

	# Second
	srlv	t9, t1, v0
	sllv	t8, t8, v1
	move	a3, t1
	or	t1, t8, t9

	# Third
	srlv	t9, t2, v0
	sllv	a3, a3, v1
	move	t8, t2
	or	t2, a3, t9

	# Fourth
	srlv	t9, t3, v0
	sllv	t8, t8, v1
	move	a3, t3
	or	t3, t8, t9

	# Fifth, partial word
	lw	t8, 16(a1)
	sllv	t9, a3, v1
	sllv	t8, t8, v0
	srlv	t8, t8, v0
	or	t8, t8, t9
	sw	t8, 16(a1)
#elif BYTE_ORDER == LITTLE_ENDIAN
	# First partial word
	# Get the top part of t0, that will become the bottom part of (a1)
	sllv	t9, t0, v0
	# Top half of (a1)
	sllv	a3, a3, v1
	srlv	a3, a3, v1
	move	t8, t0
	or	t0, a3, t9

	# Second
	sllv	t9, t1, v0
	srlv	t8, t8, v1
	move	a3, t1
	or	t1, t8, t9

	# Third
	sllv	t9, t2, v0
	srlv	a3, a3, v1
	move	t8, t2
	or	t2, a3, t9

	# Fourth
	sllv	t9, t3, v0
	srlv	t8, t8, v1
	move	a3, t3
	or	t3, t8, t9

	# Fifth, partial word
	lw	t8, 16(a1)
	srlv	t9, a3, v1
	srlv	t8, t8, v0
	sllv	t8, t8, v0
	or	t8, t8, t9
	sw	t8, 16(a1)
#else
#error BYTE_ORDER undefined
#endif
5:
	sw	t0, 0(a1)
	sw	t1, 4(a1)
	sw	t2, 8(a1)
	sw	t3, 12(a1)

	li	v0, 0
	jr	ra

.error:
	li	v0, 1
	jr	ra
END(_msa_unaligned_handler)
#endif // __mips_isa_rev < 6 || !defined(__micromips__)
