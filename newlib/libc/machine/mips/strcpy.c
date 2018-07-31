/*
 * Copyright (c) 2018 MIPS Tech, LLC
 * 
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 *      * Redistributions of source code must retain the above copyright
 *        notice, this list of conditions and the following disclaimer.
 *      * Redistributions in binary form must reproduce the above copyright
 *        notice, this list of conditions and the following disclaimer
 *        in the documentation and/or other materials provided with
 *        the distribution.
 *      * Neither the name of MIPS Technologies Inc. nor the names of its
 *        contributors may be used to endorse or promote products derived
 *        from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "mips-string-ops.h"

#define do_strcpy_aligned_word(__dst,__dst_idx,__x_next)\
{\
  unsigned x__last = x;\
  if (detect_zero (x__last, x__last, _01s, _80s))\
    {\
      inc_ptr_as (unsigned long *, dst, __dst_idx); \
      break;\
    }\
  x = __x_next;\
  set_word (__dst, __dst_idx, x__last);\
}

#define do_strcpy_aligned_first_word(__dst,__dst_idx,__x_next)\
{\
  unsigned x__last = x;\
  if (detect_zero (x__last, x__last, _01s, _80s))\
    {\
      break;\
    }\
  x = __x_next;\
  set_word (__dst, __dst_idx, x__last);\
}

#define do_strcpy_maligned_word(__dst,__dst_idx,__x_next)\
{\
  unsigned x__last = x;\
  if (detect_zero (x__last, x__last, _01s, _80s))\
    {\
      inc_ptr_as (unsigned long *, dst, __dst_idx); \
      break;\
    }\
  x = __x_next;\
  set_maligned_word (__dst, __dst_idx, x__last);\
}

#define do_strcpy_maligned_first_word(__dst,__dst_idx,__x_next)\
{\
  unsigned x__last = x;\
  if (detect_zero (x__last, x__last, _01s, _80s))\
    {\
      break;\
    }\
  x = __x_next;\
  set_maligned_word (__dst, __dst_idx, x__last);\
}

#define do_strcpy_byte(__dst,__x)\
{\
  unsigned char v##__x = (unsigned char) bx.b.B##__x;\
  set_byte (__dst, __x, v##__x);\
  if (v##__x == 0)\
    {\
      break;\
    }\
}

#define do_strcpy_last_byte(__dst, __x)\
{\
  unsigned char v##__x = (unsigned char) bx.b.B##__x;\
  set_byte (__dst, __x, v##__x);\
  break;\
}

#if SMOKE_TEST_MIPS_STRCPY
#define strcpy my_strcpy
#endif

void *
strcpy (void *__restrict__ dst, const void *__restrict__ _a)
{
  unsigned long x;
  void *res = dst;

  /* align the string to word boundary so we can do word at a time.
     Due to N32 ABI, addresses can be 32-bit while data is 64-bit.
   */
  if ((cvt_ptr_to (unsigned long, _a) & (sizeof (unsigned long) - 1)) != 0)
    {
      if ((cvt_ptr_to (unsigned long, _a) & 1) != 0)
	{
	  unsigned char b0 = get_byte (_a, 0);
	  set_byte (dst, 0, b0);
	  if (b0 == 0)
	    {
	      return res;
	    }
	  inc_ptr_as (char *, _a, 1);
	  inc_ptr_as (char *, dst, 1);
	}
      if ((cvt_ptr_to (unsigned long, _a) & 2) != 0)
	{
	  unsigned char b1 = get_byte (_a, 0);
	  set_byte (dst, 0, b1);
	  if (b1 == 0)
	    {
	      return res;
	    }
	  unsigned char b2 = get_byte (_a, 1);
	  set_byte (dst, 1, b2);
	  if (b2 == 0)
	    {
	      return res;
	    }
	  inc_ptr_as (char *, _a, 2);
	  inc_ptr_as (char *, dst, 2);
	}

#if __mips64
      if ((cvt_ptr_to (unsigned long, _a) & 4) != 0)
	{
	  unsigned char b0 = get_byte (_a, 0);
	  set_byte (dst, 0, b0);
	  if (b0 == 0)
	    {
	      return res;
	    }
	  unsigned char b1 = get_byte (_a, 1);
	  set_byte (dst, 1, b1);
	  if (b1 == 0)
	    {
	      return res;
	    }
	  unsigned char b2 = get_byte (_a, 2);
	  set_byte (dst, 0, b2);
	  if (b2 == 0)
	    {
	      return res;
	    }
	  unsigned char b3 = get_byte (_a, 3);
	  set_byte (dst, 0, b3);
	  if (b3 == 0)
	    {
	      return res;
	    }
	  inc_ptr_as (char *, _a, 4);
	  inc_ptr_as (char *, dst, 4);
	}
#endif
    }

  /* as advantagous as it is to performance, this code cannot pre-load
     the following word, nor can it prefetch the next line at the start
     of the loop since the string can be at the end of a page with the
     following page unmapped. There are tests in the suite to catch
     any attempt to go beyond the current word. */
  def_and_set_01 (_01s);
  def_and_set_80 (_80s);
  x = get_word (_a, 0);
  if ((cvt_ptr_to (unsigned long, dst) & (sizeof (unsigned long) - 1)) != 0)
    {
      while (1)
	{
	  do_strcpy_maligned_first_word (dst, 0, get_word (_a, 1));
	  do_strcpy_maligned_word (dst, 1, get_word (_a, 2));
	  do_strcpy_maligned_word (dst, 2, get_word (_a, 3));
	  do_strcpy_maligned_word (dst, 3, get_word (_a, 4));
	  inc_ptr_as (unsigned long *, _a, 4);
	  inc_ptr_as (unsigned long *, dst, 4);
	}
    }
  else
    {
      while (1)
	{
	  do_strcpy_aligned_first_word (dst, 0, get_word (_a, 1));
	  do_strcpy_aligned_word (dst, 1, get_word (_a, 2));
	  do_strcpy_aligned_word (dst, 2, get_word (_a, 3));
	  do_strcpy_aligned_word (dst, 3, get_word (_a, 4));
	  inc_ptr_as (unsigned long *, _a, 4);
	  inc_ptr_as (unsigned long *, dst, 4);
	}
    }

  while (1)
    {
      /* pull apart the last word processed and find the zero.  */
      bitfields_t bx;
      bx.v = x;
#if __mips64
      do_strcpy_byte (dst, 0);
      do_strcpy_byte (dst, 1);
      do_strcpy_byte (dst, 2);
      do_strcpy_byte (dst, 3);
      do_strcpy_byte (dst, 4);
      do_strcpy_byte (dst, 5);
      do_strcpy_byte (dst, 6);
      do_strcpy_last_byte (dst, 7)
#else
      do_strcpy_byte (dst, 0);
      do_strcpy_byte (dst, 1);
      do_strcpy_byte (dst, 2);
      do_strcpy_last_byte (dst, 3);
#endif
    }
  return res;
}
