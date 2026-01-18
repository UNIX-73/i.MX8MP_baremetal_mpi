#pragma once

#include <kernel/mm/mm_types.h>
#include <lib/stdint.h>

typedef struct
{
    p_uintptr addr;
    size_t blocks;
    const char* tag;
    bool permanent;
} memblock;


void early_kalloc_init();


/// Allocates a kernel region and saves the memory blocks it allocated for later initialization of
/// other allocators
p_uintptr early_kalloc(size_t bytes, const char* tag, bool permanent);

/// Returns the pointer to the memblocks so later stage allocators like the page allocators can
/// update their structs and be coherent with the kernel memory blocks. The first time called it
/// reallocates all the structure to the end of the last allocated block and autoassigns itself as a
/// non permanent block. It is the other allocators job to free the early_kalloc block.
void early_kalloc_get_memblocks(memblock** memblocks, size_t* memblock_count);


#ifdef TEST
#    include <drivers/uart/uart.h>

#    include "arm/mmu/mmu_page_descriptor.h"
#    include "kernel/devices/drivers.h"
#    include "lib/string.h"
#    include "lib/unit/mem.h"

inline void early_kalloc_test()
{
    early_kalloc_init();

    __attribute__((unused)) p_uintptr test = early_kalloc(20, "test1", true);
    __attribute__((unused)) p_uintptr test2 = early_kalloc(MEM_GiB, "test2", true);

    for (size_t a = 0; a < 3; a++)
    {
        memblock* memblcks;
        size_t memblck_count;
        early_kalloc_get_memblocks(&memblcks, &memblck_count);

        for (size_t i = 0; i < memblck_count; i++)
        {
            char buf[200];

            UART_puts(&UART2_DRIVER, "memblock[");
            stdint_to_ascii((STDINT_UNION) {.uint64 = i}, STDINT_UINT64, buf, sizeof(buf),
                            STDINT_BASE_REPR_DEC);
            UART_puts(&UART2_DRIVER, buf);
            UART_puts(&UART2_DRIVER, "]\n\r");

            UART_puts(&UART2_DRIVER, "  addr      = 0x");
            stdint_to_ascii((STDINT_UNION) {.uint64 = memblcks[i].addr}, STDINT_UINT64, buf,
                            sizeof(buf), STDINT_BASE_REPR_HEX);
            UART_puts(&UART2_DRIVER, buf);
            UART_puts(&UART2_DRIVER, "\n\r");

            UART_puts(&UART2_DRIVER, "  blocks    = ");
            stdint_to_ascii((STDINT_UNION) {.uint64 = memblcks[i].blocks}, STDINT_UINT64, buf,
                            sizeof(buf), STDINT_BASE_REPR_DEC);
            UART_puts(&UART2_DRIVER, buf);
            UART_puts(&UART2_DRIVER, "\n\r");

            UART_puts(&UART2_DRIVER, "  size      = ");
            stdint_to_ascii((STDINT_UNION) {.uint64 = memblcks[i].blocks * MMU_GRANULARITY_4KB},
                            STDINT_UINT64, buf, sizeof(buf), STDINT_BASE_REPR_DEC);
            UART_puts(&UART2_DRIVER, buf);
            UART_puts(&UART2_DRIVER, " bytes\n\r");

            UART_puts(&UART2_DRIVER, "  permanent = ");
            UART_puts(&UART2_DRIVER, memblcks[i].permanent ? "true\n\r" : "false\n\r");

            UART_puts(&UART2_DRIVER, "  tag       = ");
            UART_puts(&UART2_DRIVER, memblcks[i].tag ? memblcks[i].tag : "(null)");
            UART_puts(&UART2_DRIVER, "\n\r\n\r");
        }
    }
}
#else
static inline void early_kalloc_test()
{
}
#endif