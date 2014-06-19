/*
 * uhi_getargs.S - Get command line arguments for main()
*/

/*
 * Copyright (c) 2014, Imagination Technologies Ltd.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation and/or
 * other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors may
 * be used to endorse or promote products derived from this software without
 * specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include "regs.S"
#include "uhi_syscalls.h"

#ifdef __mips64
#define ptrsize 4
#else
#define ptrsize 2
#endif

  .text
  .align  2
  .globl  getargs
  .set  nomips16
  .set  nomicromips
  .ent  getargs
  .type getargs, @function
getargs:
  .set  noreorder
  .set  nomacro

  move  t6, zero              /* argc */
  move  t4, zero              /* argv */

  lui  $25, __MIPS_UHI_ARGC

  .global argc
  .type argc, @function
argc:
  ASM_SYSCALL (1)
  nop

  /* return if no arguments (0) or error (-1) */
  blez  v0, .Lreturn
  nop

  move  t6, v0                  /* argc: number of arguments */
  sll t7, t6, ptrsize
  subu  sp, sp, t7              /* make room for argv */
  move  t4, sp                  /* argv */

  move  t5, zero

.Lloop:

  lui  $25, __MIPS_UHI_ARGLEN
  move  a0, t5                  /* argument number */

  .global arglen
  .type arglen, @function
arglen:
  ASM_SYSCALL (1)               /* get lenght of the arg N */
  nop

  blez  v0, .Lreturn            /* return on error */
  nop

  subu  sp, sp, v0
  sll t7, t5, ptrsize
  addu  t7, t7, t4
#ifdef __mips64
  sd  sp, 0(t7)                 /* argv[i] */
#else
  sw  sp, 0(t7)                 /* argv[i] */
#endif

  lui  $25, __MIPS_UHI_ARGN
  move  a0, t5                  /* argument number */
  move  a1, sp                  /* argument buffer */

  .global argn
  .type argn, @function
argn:
  ASM_SYSCALL (1)
  nop

  blez  v0, .Lreturn            /* return on error */
  nop

  addu  t5, t5, 1
  slt v0, t5, t6
  bne v0, zero, .Lloop
  nop

.Lreturn:
  move  a0, t6
  move  a1, t4
  move  a2, zero

  li  t1, 8
  andi  t0, sp, 7
  subu  t1, t1, t0
  addu  sp, sp, t1

  j $31
  nop

  .set  macro
  .set  reorder
  .end  getargs
  .size getargs, .-getargs

/* EOF uhi_getargs.S */
