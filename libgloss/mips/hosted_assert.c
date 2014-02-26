/*
 * hosted_assert.c
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

/*
 * @Synopsis     void __assert_func (const char *filename, int32_t line_num,
 *                 const char *func, const char *expr);
 *
 *               Parameters:
 *                 $4 - Name of the file
 *                 $5 - Line number
 *                 $6 - Name of the function
 *                 %7 - Expression
 *
 *               Return:
 *                 None
 *
 *               Arguments to syscall:
 *                 $25 - Operation code for __assert_func
 *                 $4 - Name of the file
 *                 $5 - Line number
 *                 $6 - Name of the function
 *                 %7 - Expression
 *
 *               Return from syscall:
 *                 None
 *
 * @Description  Assert
*/

#include <stdint.h>
#include "hosted_syscalls.h"

void __assert_func (const char *filename, int32_t line_num, const char *func, const char *expr)
{
  register const char *arg1 asm ("$4") = filename;
  register int32_t arg2 asm ("$5") = line_num;
  register const char *arg3 asm ("$6") = func;
  register const char *arg4 asm ("$7") = expr;
  register int32_t op asm ("$25") = __MIPS_UHI_ASSERT;

  __asm__ __volatile__(" # __assert_func(%0, %1, %2, %3) op=%4\n"
                       SYSCALL (__MIPS_UHI_SYSCALL_NUM)
                       : /* no output */
                       : "r" (arg1), "r" (arg2), "r" (arg3), "r" (arg4), "r" (op));

  return;
}
