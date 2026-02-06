set architecture aarch64
target remote localhost:2331
set print pretty on 
monitor halt

load
set $pc = 0x40200000
add-symbol-file /home/unab/files/master/tfm/imx8mp/project/bin/kernel.elf 0x40200000

break kernel_entry

layout split