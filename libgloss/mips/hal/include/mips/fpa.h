/*
 * Copyright (c) 2014, Imagination Technologies LLC and Imagination
 * Technologies Limited. 
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
 * fpa.h: include appropriate FPA definitions for this target
 */


#ifdef __cplusplus
extern "C" {
#endif

#if __mips == 32 || __mips == 64
#include <mips/m32c1.h>
#endif

#ifdef __cplusplus
}
#endif
