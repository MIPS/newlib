/*
 * crt0.S -- startup file for MIPS.
 *
 * Copyright (c) 1995, 1996, 1997, 2001 Cygnus Support
 *
 * The authors hereby grant permission to use, copy, modify, distribute,
 * and license this software and its documentation for any purpose, provided
 * that existing copyright notices are retained in all copies and that this
 * notice is included verbatim in any distributions. No written agreement,
 * license, or royalty fee is required for any of the authorized uses.
 * Modifications to this software may be copyrighted by their authors
 * and need not follow the licensing terms described here, provided that
 * the new terms are clearly indicated on the first page of each file where
 * they apply.
*/

	.gnu_attribute 4,0

#ifdef __mips16
  .set nomips16	   /* This file contains 32 bit assembly code. */
#endif

#include "regs.S"
#include "abiflags.S"

#define STARTUP_STACK_SIZE  0x0100	  /* Temporary stack size to run C code */
#define __YAMON_EXIT		0x20

/*
 * This is for referencing addresses that are not in the .sdata or
 * .sbss section under embedded-pic, or before we've set up gp.
*/
#ifdef __mips_embedded_pic
#ifdef __mips64
#define LA(t,x) la t,x-PICBASE ; daddu t,s0,t
#else
#define LA(t,x) la t,x-PICBASE ; addu t,s0,t
#endif
#else /* __mips_embedded_pic */
#define LA(t,x) la t,x
#endif /* __mips_embedded_pic */

#if __mips<3
#define STATUS_MASK (SR_CU1|SR_PE)
#else
#ifdef __mips64	 /* Post-mips2 has no SR_PE bit. */
#define STATUS_MASK (SR_CU1|SR_FR|SR_KX|SR_SX|SR_UX)	/* Turn on 64-bit addressing and additional float regs. */
#else
#if __mips_fpr==32
#define STATUS_MASK (SR_CU1)
#else
#define STATUS_MASK (SR_CU1|SR_FR)  /* Turn on additional float regs.  */
#endif
#endif
#endif

  .comm   __memsize, 12
  .comm   __lstack, STARTUP_STACK_SIZE

  .data
__temp_space:	   /* Temporary space to save arguments */
#ifdef __mips64
  .space 24
#else
  .space 12
#endif

  .text
  .align  2

/*
 * Without the following nop, GDB thinks _start is a data variable.
 * This is probably a bug in GDB in handling a symbol that is at the
 * start of the .text section.
*/
  nop

  .globl  hardware_hazard_hook
  .globl  _start
  .ent  _start
_start:


#ifdef __mips_embedded_pic
#define PICBASE start_PICBASE
  PICBASE = .+8
  bal PICBASE
  move  s0,$31
#endif

  /* Save argument registers */
  LA (t0, __temp_space)
#ifdef __mips64
  sd  a0, 0(t0)
  sd  a1, 8(t0)
  sd  a2, 16(t0)
#else
  sw  a0, 0(t0)
  sw  a1, 4(t0)
  sw  a2, 8(t0)
#endif

	/* Clear Cause register */
	.set	push
	.set	mips32
	mtc0	zero,C0_CAUSE
	.set	pop
	nop

	/*
	 * Read MIPS_abiflags structure and set
	 * status/config registers accordingly
	*/
	.weak	__MIPS_abiflags_start
	.weak	__MIPS_abiflags_end
	LA	(t0,__MIPS_abiflags_start)
	LA	(t1,__MIPS_abiflags_end)
	addiu	t1,t1,-24
	move	v0,zero			/* Mask for C0_SR */
	bne	t0,t1,1f

	/* Check isa_level */
	lbu	t1,ABIFlags_isa_level(t0)
	sltu	v1,t1,3			/* Is MIPS < 3? */
	li	v1,SR_PE
	beq	v1,zero,4f
	or	v0,v0,v1		/* Enable soft reset */
4:
	xori	t1,t1,64		/* Is MIPS64? */
	li	v1,(SR_KX|SR_SX|SR_UX)
	bne	t1,zero,5f
	or	v0,v0,v1		/* Enable extended addressing */
5:
	/* Check fp_abi */
	lbu	t1,ABIFlags_fp_abi(t0)
	xori	t1,t1,Val_GNU_MIPS_ABI_FP_SOFT
	li	v1,SR_CU1
	beq	t1,zero,2f		/* Skip MSA and cpr1_size checks */
	or	v0,v0,v1		/* Enable co-processor 1 */

	/* Check cpr1_size */
	lbu	t1,ABIFlags_cpr1_size(t0)
	xori	t1,t1,AFL_REG_64
	li	v1,SR_FR
	bne	t1,zero,3f
	or	v0,v0,v1		/* Enable 64bit FPU registers */
3:
	/* Check ases */
	lw	t1,ABIFlags_ases(t0)
	andi	t1,t1,AFL_ASE_MSA
	li	v1,SR_FR
	beq	t1,zero,2f
	or	v0,v0,v1		/* Enable FPU registers */
	li	v1,SR_MSA
	.set	push
	.set	mips32
	mtc0	v1,C0_CONFIG,5		/* Enable MSA */
	.set	pop
	nop
	j	2f

1:
	/*
	 * MIPS_abiflags structure is not available
	 * Set status/config registers based on
	 * flags defined by compiler.
	*/
#ifdef __mips_soft_float
	li	v0,(STATUS_MASK-(STATUS_MASK & SR_CU1))
#else
	li	v0,STATUS_MASK
#endif

2:
	/* Set C0_SR */
	.set	push
	.set	mips32
	mtc0	v0,C0_SR
	.set	pop
	nop

	/* Avoid hazard from C0_SR changes */
	LA	(t0, hardware_hazard_hook)
	beq	t0,zero,1f
	jalr	t0
1:

/*
 * Fix high bits, if any, of the PC so that
 * exception handling doesn't get confused.
*/
  LA  (v0, 3f)
  jr  v0
3:
  LA  (gp, _gp)   /* set the global data pointer */
  .end _start

/* Zero out the bss section. */
  .globl  get_mem_info
  .globl  __stack
  .globl  __global
  .ent  zerobss
zerobss:
  LA  (v0, _fbss)
  LA  (v1, _end)
3:
  sw  zero,0(v0)
  sltu $1,v0,v1
  addiu v0,v0,4           # executed in delay slot
  bnez  $1,3b

  /* setup the stack pointer */
  LA  (t0, __stack)       # is __stack set ?
  bne t0,zero,4f

  LA  (t0, __lstack)      # make a small stack so we
  addiu sp,t0,STARTUP_STACK_SIZE  # can run some C code
  la  a0,__memsize        # get the usable memory size
  jal get_mem_info

  /*
   * NOTE: a0[0] contains the amount of memory available, and
   * not the last memory address.
  */
  LA  (a0, __memsize)
  lw  t0,0(a0)      # amount of memory available
  la  t1,K0BASE     # cached kernel memory
  addu  t0,t0,t1    # get the end of memory address

  /*
   * Allocate 32 bytes for the register parameters.  Allocate 16
   * bytes for a null argv and envp.  Round the result up to 64
   * bytes to preserve alignment.
  */
4:
  subu  t0,t0,64
  move  sp,t0       # set stack pointer
  .end  zerobss

/*
 * Initialize target specific stuff. Only execute these
 * functions it they exist.
*/
  .globl  hardware_init_hook .text
  .globl  software_init_hook .text
  .type _fini,@function
  .type _init,@function
  .globl  atexit .text
  .globl  exit .text
  .ent  init
init:
  LA  (t9, hardware_init_hook)    # init the hardware if needed
  beq t9,zero,6f
  jalr t9
6:
  LA  (t9, software_init_hook)    # init the hardware if needed
  beq t9,zero,7f
  jalr t9
7:
  LA  (a0, _fini)
  jal atexit

#ifdef GCRT0
  .globl  _ftext
  .globl  _extext
  LA  (a0, _ftext)
  LA  (a1, _etext)
  jal monstartup
#endif

  jal _init       # run global constructors

  /* restore argument registers */
  LA  (t0, __temp_space)
#ifdef __mips64
  ld  a0,0(t0)
  ld  a1,8(t0)
  ld  a2,16(t0)
#else
  lw  a0,0(t0)
  lw  a1,4(t0)
  lw  a2,8(t0)
#endif

  /* if a0 >= 0 then we have arguments ready in a0 to a2 registers */
  bgez  a0,.Lmain

#ifdef __HAVE_ARGN
  jal getargs       # get arguments
#else

  /* no arguments */
  move  a0,zero   # set argc to 0
  addiu a1,sp,32  # argv = sp + 32
  addiu a2,sp,40  # envp = sp + 40
#ifdef __mips64
  sd  zero,0(a1)  # argv[argc] = 0
  sd  zero,0(a2)  # envp[0] = 0
#else
  sw  zero,0(a1)
  sw  zero,0(a2)
#endif
#endif /* __HAVE_ARGN */

.Lmain:
  jal main        # call the program start function

  /* Fall through to the "exit" routine */
  move  a0,v0     # pass through the exit code
  jal exit        # call libc exit to run the G++ destructors
  .end  init

/* Assume the PICBASE set up above is no longer valid below here.  */
#ifdef __mips_embedded_pic
#undef PICBASE
#endif

/*
 * _exit -- Exit from the application. Normally we cause a user trap
 *  to return to the ROM monitor for another run. NOTE: This is
 *  the only other routine we provide in the crt0.o object, since
 *  it may be tied to the "_start" routine. It also allows
 *  executables that contain a complete world to be linked with
 *  just the crt0.o object.
*/
  .globl  hardware_exit_hook .text
  .globl  _exit
  .ent _exit
_exit:
7:

  # save exit code
  LA  (t0, __temp_space)
#ifdef __mips64
  sd  a0,0(t0)
#else
  sw  a0,0(t0)
#endif

#ifdef __mips_embedded_pic
  /*
   * Need to reinit PICBASE, since we might be called via exit()
   * rather than via a return path which would restore old s0.
  */
#define PICBASE exit_PICBASE
  PICBASE = .+8
  bal PICBASE
  move  s0,$31
#endif
#ifdef GCRT0
  LA  (t0, _mcleanup)
  jalr t0
#endif
  LA  (t0, hardware_exit_hook)
  beq t0,zero,1f
  jalr t0
1:

  # restore return value from main
  LA  (t0, __temp_space)
#ifdef __mips64
  ld  a0,0(t0)
#else
  lw  a0,0(t0)
#endif

  .global __exit .text
  jal __exit

  # break instruction can cope with 0xfffff, but GAS limits the range:
  break 1023
  b 7b  # but loop back just in-case

  .end _exit

/* Assume the PICBASE set up above is no longer valid below here.  */
#ifdef __mips_embedded_pic
#undef PICBASE
#endif

/* EOF crt0.S */
