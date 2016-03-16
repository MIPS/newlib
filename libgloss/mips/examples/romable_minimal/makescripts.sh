#!/bin/bash

if [ "x$MIPS_ELF_ROOT" = "x" ]; then
  echo "Error: MIPS_ELF_ROOT is not set"
  exit 1
fi
if [ "x$MIPS_TOOLCHAIN" = "x" ]; then
  echo "Error: MIPS_TOOLCHAIN is not set (i.e. mips-img-elf)"
  exit 1
fi
COMPILER=${MIPS_ELF_ROOT}/bin/${MIPS_TOOLCHAIN}-gcc

uhi32=`${COMPILER} --print-file-name=uhi32.ld`
uhi64_64=`${COMPILER} --print-file-name=uhi64_64.ld`
uhi64_n32=`${COMPILER} --print-file-name=uhi64_n32.ld`

cp $uhi32 minimal32.ld
cp $uhi64_64 minimal64_64.ld
cp $uhi64_n32 minimal64_n32.ld

for i in minimal32.ld minimal64_64.ld minimal64_n32.ld; do
  sed -i -e "s|\(EXTERN *(__getargs).*\)|/* \1 */|" $i
  sed -i -e "s|\(EXTERN *(__exception_handle_verbose).*\)|"\
"/* \1 */\n"\
"/* Use the quiet exception handler for reduced code size */\n"\
"EXTERN (__exception_handle_quiet)|" $i
  sed -i -e "s|\(EXTERN *(__register_excpt_boot).*\)|"\
"/* \1 */|" $i
  sed -i -e "s|PROVIDE *(__use_excpt_boot = 1)|"\
"PROVIDE (__use_excpt_boot = 0)|" $i
done
