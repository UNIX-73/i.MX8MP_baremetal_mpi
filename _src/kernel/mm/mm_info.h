#pragma once

#include <arm/mmu/mmu.h>
#include <lib/stdint.h>


#define KERNEL_BASE 0xFFFF'8000'0000'0000ULL

void mm_info_init();


size_t mm_info_max_ddr_size(void);
size_t mm_info_ddr_size(void);

uintptr mm_info_ddr_start(void);
uintptr mm_info_ddr_end(void);

uintptr mm_info_kernel_start(void);
size_t mm_info_kernel_size(void);

size_t mm_info_page_count(void);

size_t mm_info_mm_addr_space(void);

extern const size_t MM_PAGE_BYTES;