#include <arm/mmu/mmu.h>
#include <kernel/mm/mm.h>

#include "arm/mmu/mmu_page_descriptor.h"
#include "boot/panic.h"
#include "drivers/uart/uart.h"
#include "kernel/devices/drivers.h"
#include "lib/stdint.h"
#include "lib/stdmacros.h"


_Alignas(1024 * 4) mmu_page_descriptor table_lv0[512];

// 4GiB tables in total
_Alignas(1024 * 4) mmu_page_descriptor table_lv1[512];


void mmu_init()
{
    mmu_table_handle lvl0_handle;
    mmu_table_handle lvl1_handle;

    mmu_init_table(&lvl0_handle, table_lv0, MMU_GRANULARITY_4KB, MMU_TABLE_LEVEL0);

    mmu_init_table(&lvl1_handle, table_lv1, MMU_GRANULARITY_4KB, MMU_TABLE_LEVEL1);

    mmu_page_descriptor_cfg lvl0_cfg = {
        .valid = true,
        .type = MMU_TABLE_DESCRIPTOR_TABLE,
        .attr_index = 0,
        .non_secure = 0,
        .access_permissions = MMU_ACCESS_PERMISSION_EL0RW_EL1_RW,
        .shareability = MMU_SHAREABILITY_INNER_SHAREABLE,
        .access_flag = 1,
        .output_address = (uintptr)table_lv1,
        .privileged_execute_never = 0,
        .unprivileged_execute_never = 0,
        .software_defined = 0,
    };

    lvl0_cfg.output_address = (uintptr)lvl1_handle.table_addr;
    mmu_set_page_descriptor_cfg(lvl0_handle, 0, &lvl0_cfg);

    // setup lvl1
    mmu_page_descriptor_cfg lvl1_cfg = {
        .valid = true,
        .type = MMU_TABLE_DESCRIPTOR_BLOCK,
        .attr_index = 0,
        .non_secure = 0,
        .access_permissions = MMU_ACCESS_PERMISSION_EL0NA_EL1_RW,
        .shareability = MMU_SHAREABILITY_INNER_SHAREABLE,
        .access_flag = 1,
        .output_address = (uintptr)NULL,
        .privileged_execute_never = 0,
        .unprivileged_execute_never = 0,
        .software_defined = 0,
    };

    for (size_t i = 0; i < 2; i++)
    {
        lvl1_cfg.output_address = i * 0x40000000UL; // i * 1gib for va=pa
        lvl1_cfg.software_defined = i;
        lvl1_cfg.attr_index = (i == 0) ? 1 : 0;

        mmu_set_page_descriptor_cfg(lvl1_handle, i, &lvl1_cfg);
    }


    mmu_init(lvl0_handle);
}

void test_mmu()
{
    uintptr test = 0x40000000UL * 1.5;
    volatile uint64* testptr = (volatile uint64*)(void*)test;

    UART_puts_sync(&UART2_DRIVER, "TEST1 OK\n\r");

    uint64 v = *testptr;

    test = 0x40000000UL * 3;
    testptr = (volatile uint64*)(void*)test;

    uint64 j = *testptr;

    UART_puts_sync(&UART2_DRIVER, "TEST2 FAILED\n\r");


    if (v != j)
        return;
}