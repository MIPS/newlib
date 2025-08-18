/* Copyright (c) 2017  SiFive Inc. All rights reserved.

   This copyrighted material is made available to anyone wishing to use,
   modify, copy, or redistribute it subject to the terms and conditions
   of the FreeBSD License.   This program is distributed in the hope that
   it will be useful, but WITHOUT ANY WARRANTY expressed or implied,
   including the implied warranties of MERCHANTABILITY or FITNESS FOR
   A PARTICULAR PURPOSE.  A copy of this license is available at
   http://www.opensource.org/licenses.
*/
#if 0
#include <string.h>
#include <stdint.h>

size_t strlen(const char *str)
{
  const char *start = str;

#if defined(PREFER_SIZE_OVER_SPEED) || defined(__OPTIMIZE_SIZE__)
  while (*str++)
    ;
  return str - start - 1;
#else
  if (__builtin_expect ((uintptr_t)str & (sizeof (long) - 1), 0)) do
    {
      char ch = *str;
      str++;
      if (!ch)
	return str - start - 1;
    } while ((uintptr_t)str & (sizeof (long) - 1));

  unsigned long *ls = (unsigned long *)str;
  while (!__libc_detect_null (*ls++))
    ;
  asm volatile ("" : "+r"(ls)); /* prevent "optimization" */

  str = (const char *)ls;
  size_t ret = str - start, sl = sizeof (long);

  char c0 = str[0 - sl], c1 = str[1 - sl], c2 = str[2 - sl], c3 = str[3 - sl];
  if (c0 == 0)            return ret + 0 - sl;
  if (c1 == 0)            return ret + 1 - sl;
  if (c2 == 0)            return ret + 2 - sl;
  if (sl == 4 || c3 == 0) return ret + 3 - sl;

  c0 = str[4 - sl], c1 = str[5 - sl], c2 = str[6 - sl], c3 = str[7 - sl];
  if (c0 == 0)            return ret + 4 - sl;
  if (c1 == 0)            return ret + 5 - sl;
  if (c2 == 0)            return ret + 6 - sl;

  return ret + 7 - sl;
#endif /* not PREFER_SIZE_OVER_SPEED */
}
#endif

#include <sys/asm.h>

/* int strlen(const char *s) */
.text
.globl strlen
.type  strlen, @function
strlen:
#if defined(PREFER_SIZE_OVER_SPEED) || defined(__OPTIMIZE_SIZE__)
	mv	a5, a0
1:
	lbu	a4, 0(a5)
	addi	a5, a5, 1
	bnez	a4, 1b
	sub	a0, a5, a0
	addi 	a0, a0, -1
	ret
.size   strlen, .-strlen
#elif defined(__riscv_zbb)
/*
 * Variant of strlen using the ZBB extension if available
 */

#if defined(__riscv_big_endian)
# define CZ	clz
# define SHIFT	sll
#else
# define CZ	ctz
# define SHIFT	srl
#endif
	/*
	 * Returns
	 *   a0 - string length
	 *
	 * Parameters
	 *   a0 - String to measure
	 *
	 * Clobbers
	 *   t0, t1, t2, t3
	 */

	/* Number of irrelevant bytes in the first word. */
	andi	t2, a0, SZREG-1

	/* Align pointer. */
	andi	t0, a0, -SZREG

	li	t3, SZREG
	sub	t3, t3, t2
	slli	t2, t2, 3

	/* Get the first word.  */
	REG_L	t1, 0(t0)

	/*
	 * Shift away the partial data we loaded to remove the irrelevant bytes
	 * preceding the string with the effect of adding NUL bytes at the
	 * end of the string's first word.
	 */
	SHIFT	t1, t1, t2

	/* Convert non-NUL into 0xff and NUL into 0x00. */
	orc.b	t1, t1

	/* Convert non-NUL into 0x00 and NUL into 0xff. */
	not	t1, t1

	/*
	 * Search for the first set bit (corresponding to a NUL byte in the
	 * original chunk).
	 */
	CZ	t1, t1

	/*
	 * The first chunk is special: compare against the number
	 * of valid bytes in this chunk.
	 */
	srli	a0, t1, 3
	bgtu	t3, a0, 2f

	/* Prepare for the word comparison loop. */
	addi	t2, t0, SZREG
	li	t3, -1

	/*
	 * Our critical loop is 4 instructions and processes data in
	 * 4 byte or 8 byte chunks.
	 */
	.p2align 3
1:
	REG_L	t1, SZREG(t0)
	addi	t0, t0, SZREG
	orc.b	t1, t1
	beq	t1, t3, 1b

	not	t1, t1
	CZ	t1, t1
	srli	t1, t1, 3

	/* Get number of processed bytes. */
	sub	t2, t0, t2

	/* Add number of characters in the first word.  */
	add	a0, a0, t2

	/* Add number of characters in the last word.  */
	add	a0, a0, t1
2:
	ret
#else
/* Compile from the original strlen.c */
	andi	a5,a0,7
	mv	a4,a0
	bne	a5,zero,.L5
.L2:
	ld	a3,.LC0
	li	a1,-1
.L6:
	ld	a2,0(a4)
	addi	a4,a4,8
	and	a5,a2,a3
	add	a5,a5,a3
	or	a5,a5,a2
	or	a5,a5,a3
	beq	a5,a1,.L6
	lbu	a3,-8(a4)
	sub	a5,a4,a0
	beq	a3,zero,.L19
	lbu	a3,-7(a4)
	beq	a3,zero,.L20
	lbu	a3,-6(a4)
	beq	a3,zero,.L21
	lbu	a3,-5(a4)
	beq	a3,zero,.L22
	lbu	a0,-2(a4)
	addi	a1,a5,-3
	lbu	a6,-3(a4)
	addi	a3,a5,-4
	lbu	a2,-4(a4)
	snez	a0,a0
	add	a0,a0,a5
	addi	a0,a0,-2
	.option push
	.option arch, +xmipscmov
	mips.ccmov	a0,a6,a0,a1
	mips.ccmov	a0,a2,a0,a3
	.option pop
	ret
.L3:
	beq	a3,zero,.L2
.L5:
	lbu	a5,0(a4)
	addi	a4,a4,1
	andi	a3,a4,7
	bne	a5,zero,.L3
	sub	a4,a4,a0
	addi	a0,a4,-1
	ret
.L20:
	addi	a0,a5,-7
	ret
.L19:
	addi	a0,a5,-8
	ret
.L22:
	addi	a0,a5,-5
	ret
.L21:
	addi	a0,a5,-6
	ret
	.size	strlen, .-strlen
	.section	.srodata.cst8,"aM",@progbits,8
	.align	3
.LC0:
	.dword	0x7f7f7f7f7f7f7f7f
#endif
