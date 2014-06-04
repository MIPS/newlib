/*
 * hosted_syscall.h
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

#define __MIPS_UHI_EXIT        1
#define __MIPS_UHI_OPEN        2
#define __MIPS_UHI_CLOSE       3
#define __MIPS_UHI_READ        4
#define __MIPS_UHI_WRITE       5
#define __MIPS_UHI_LSEEK       6
#define __MIPS_UHI_UNLINK      7
#define __MIPS_UHI_FSTAT       8
#define __MIPS_UHI_ARGC        9
#define __MIPS_UHI_ARGLEN      10
#define __MIPS_UHI_ARGN        11
#define __MIPS_UHI_HEAPINFO    12
#define __MIPS_UHI_LOG         13
#define __MIPS_UHI_ASSERT      14
#define __MIPS_UHI_EXCEPTION   15
#define __MIPS_UHI_FINDFIRST   16
#define __MIPS_UHI_FINDNEXT    17
#define __MIPS_UHI_FINDCLOSE   18
#define __MIPS_UHI_PREAD       19
#define __MIPS_UHI_PWRITE      20
#define __MIPS_UHI_YIELD       21
#define __MIPS_UHI_LINK        22

#define xstr(s) str(s)
#define str(s) #s
#define __MIPS_UHI_SYSCALL_NUM 1

#ifdef __MIPS_SYSCALL__
	#define SYSCALL(NUM) "\tsyscall " xstr (NUM)
	#define ASM_SYSCALL(NUM) syscall NUM
#else
	#define SYSCALL(NUM) "\tsdbbp " xstr (NUM)
	#define ASM_SYSCALL(NUM) sdbbp NUM
#endif
