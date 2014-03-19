/* 
 * hosted_fstat.c
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
 * @Synopsis     int32_t fstat (int32_t file, struct stat *sbuf);
 *                
 *               Parameters:
 *                 $4 - File handle
 *                 $5 - Pointer to dst buffer (struct stat *)
 *                 
 *               Return:
 *                 $2 - 0 on success else -1
 *                 
 *               Arguments to syscall:
 *                 $25 - Operation code for fstat
 *                 $4 - File handle
 *                 $5 - Pointer to dst buffer (struct stat *)
 *                 
 *               Return from syscall:
 *                 $2 - 0 on success else -1
 *                 $3 - errno
 *                 
 * @Description  File statistics
*/

#include <stdio.h>
#include <stdint.h>
#include <errno.h>
#include "hosted_syscalls.h"
#include "hosted_stat.h"

int32_t fstat (int32_t file, struct stat *sbuf)
{
  register int32_t arg1 asm ("$4") = file;
  register struct stat *arg2 asm ("$5") = sbuf;
  register int32_t op asm ("$25") = __MIPS_UHI_FSTAT;
  register int32_t ret asm ("$2") = 0;
  register int32_t new_errno asm ("$3") = 0;

  __asm__ __volatile__(" # %0,%1 = fstat(%2, %3) op=%4\n"
                       SYSCALL (__MIPS_UHI_SYSCALL_NUM)
                       : "=r" (ret), "=r" (new_errno) 
                       : "r" (arg1), "r" (arg2), "r" (op));
                       
   if (ret != 0)
    errno = new_errno;
    
  return ret;
}

