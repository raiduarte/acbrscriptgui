#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking /home/mintlab/acbrscriptgui/bin/linux/acbrscriptgui_lnx
OFS=$IFS
IFS="
"
/usr/bin/ld -b elf64-x86-64 -m elf_x86_64  --dynamic-linker=/lib64/ld-linux-x86-64.so.2     -L. -o /home/mintlab/acbrscriptgui/bin/linux/acbrscriptgui_lnx -T /home/mintlab/acbrscriptgui/bin/linux/link.res -e _start
if [ $? != 0 ]; then DoExitLink /home/mintlab/acbrscriptgui/bin/linux/acbrscriptgui_lnx; fi
IFS=$OFS
