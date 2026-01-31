#include "reloc.h"

#include <lib/stdbool.h>

#include "../mm_info.h"
#include "../phys/page_allocator.h"
#include "arm/mmu/mmu.h"
#include "boot/panic.h"
#include "drivers/uart/uart.h"
#include "kernel/devices/drivers.h"
#include "lib/mem.h"
#include "lib/stdint.h"
#include "lib/stdmacros.h"

extern _Noreturn void _jmp_to_with_offset(void* to, size_t offset);

// allocator freer for the early identity mapping tables
static void test_free(void* addr)
{
    page_free((mm_page) {.phys = (p_uintptr)addr});
}


static void* test_alloc(size_t bytes, size_t)
{
    return (void*)page_malloc(page_allocator_bytes_to_order(bytes),
                              (mm_page_data) {
                                  .device_mem = false,
                                  .tag = "reloc_test",
                                  .permanent = false,
                                  .virt = 0,
                              })
        .phys;
}


void test_entry()
{
    uart_puts(&UART2_DRIVER, "arrived to the top");
}


void mm_reloc_kernel(p_uintptr kernel_base, mmu_handle* h)
{
    ASSERT(mmu_is_active());
    // The current state of the mmu is on identity mapping mode


    mmu_reconfig_allocators(h, test_alloc, test_free);

    mmu_pg_cfg device_cfg = mmu_pg_cfg_new(1, MMU_AP_EL0_NONE_EL1_RW, 0, false, 1, 0, 0, 0);
    mmu_pg_cfg mem_cfg = mmu_pg_cfg_new(0, MMU_AP_EL0_NONE_EL1_RW, 0, false, 1, 0, 0, 0);

    // device memory
    mmu_map(h, kernel_base, 0, MEM_GiB, device_cfg, NULL);

    // kernel memory
    mmu_map(h, kernel_base + MEM_GiB, MEM_GiB, 4 * MEM_GiB, mem_cfg, NULL);


    _jmp_to_with_offset(test_entry, kernel_base);
}
