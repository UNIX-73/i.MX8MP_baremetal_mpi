OUTPUT_FORMAT("elf64-littleaarch64")
ENTRY(_start)

SECTIONS {
    . = 0x40000000;

    .text : ALIGN(64) {
        __text_start = .;
        KEEP(*(.text.boot))
        *(.text*)
        . = ALIGN(64);
        __text_end = .;
    }
    
    .vectors ALIGN(2048) : {
        __vectors_start = .;
        KEEP(*(.vectors))
        . = ALIGN(64);
        __vectors_end = .;
    }

    .rodata : ALIGN(16) {
        *(.rodata*)
        *(.rodata.*)        

        . = ALIGN(8);
        __kernel_init_start = .;
        KEEP(*(.kernel_init))
        . = ALIGN(8);
        __kernel_init_end = .;

        . = ALIGN(16);
    }

    .data : ALIGN(16) {
        *(.data*)
        . = ALIGN(16);
    }

    .bss : ALIGN(64) {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(64);
        __bss_end = .;
    }

    .stacks (NOLOAD) : ALIGN(4096) {
        /* EL2 */
        . = ALIGN(16);
        __stack_el2_bottom = .;
        . += 0x500000;
        __stack_el2_top = .;

         /* EL1 */
        . = ALIGN(16);
        __stack_el1_bottom = .;
        . += 0x500000;
        __stack_el1_top = .;
         
         /* EL0 */
        . = ALIGN(16);
        __stack_el0_bottom = .;
        . += 0x500000;
        __stack_el0_top = .;
    }
    
}
