#pragma once

#include <lib/mem.h>
#include <lib/stdint.h>

#include "arm/mmu/mmu.h"

typedef struct {
    _Alignas(16) p_uintptr addr;
    _Alignas(16) size_t blocks;
    _Alignas(16) const char* tag;
    _Alignas(16) bool permanent;
    _Alignas(16) bool device_memory;
} memblock;


void early_kalloc_init();


/// Allocates a kernel region and saves the memory blocks it allocated for later initialization of
/// other allocators
p_uintptr early_kalloc(size_t bytes, const char* tag, bool permanent, bool device_memory);


#ifdef DEBUG
/// Function that should only be called in DEBUG mode. It can only free the last allocated memblocks.
void early_kfree(p_uintptr addr);
#else
#    include "kernel/panic.h"
#    define early_kfree(...)                                                                       \
        PANIC("early_kfree should be protected under DEBUG ifdefs and not be used in release "     \
              "versions. The main intent of this free fn is to allocate a test, test it and then " \
              "allocate the real data")
#endif


/// Returns the pointer to the memblocks so later stage allocators like the page allocators can
/// update their structs and be coherent with the kernel memory blocks. The first time called it
/// reallocates all the structure to the end of the last allocated block and autoassigns itself as a
/// non permanent block. It is the other allocators job to free the early_kalloc block.
void early_kalloc_get_memblocks(memblock** mblcks, size_t* mblck_structr_count);


#ifdef TEST
#    include "kernel/devices/drivers.h"
#    include "kernel/io/term.h"
#    include "lib/string.h"

inline void early_kalloc_debug()
{
    memblock* memblcks;
    size_t memblck_count;
    early_kalloc_get_memblocks(&memblcks, &memblck_count);

    for (size_t i = 0; i < memblck_count; i++) {
        char buf[200];

        term_prints("memblock[");
        stdint_to_ascii((STDINT_UNION) {.uint64 = i}, STDINT_UINT64, buf, sizeof(buf),
                        STDINT_BASE_REPR_DEC);
        term_prints(buf);
        term_prints("]\n\r");

        term_prints("  addr      = ");
        stdint_to_ascii((STDINT_UNION) {.uint64 = memblcks[i].addr}, STDINT_UINT64, buf,
                        sizeof(buf), STDINT_BASE_REPR_HEX);
        term_prints(buf);
        term_prints("\n\r");

        term_prints("  blocks    = ");
        stdint_to_ascii((STDINT_UNION) {.uint64 = memblcks[i].blocks}, STDINT_UINT64, buf,
                        sizeof(buf), STDINT_BASE_REPR_DEC);
        term_prints(buf);
        term_prints("\n\r");

        term_prints("  size      = ");
        stdint_to_ascii((STDINT_UNION) {.uint64 = memblcks[i].blocks * MMU_GRANULARITY_4KB},
                        STDINT_UINT64, buf, sizeof(buf), STDINT_BASE_REPR_DEC);
        term_prints(buf);
        term_prints(" bytes\n\r");

        term_prints("  permanent = ");
        term_prints(memblcks[i].permanent ? "true\n\r" : "false\n\r");

        term_prints("  tag       = ");
        term_prints(memblcks[i].tag ? memblcks[i].tag : "(null)");
        term_prints("\n\r\n\r");
    }
}
#else
static inline void early_kalloc_test()
{
}
#endif