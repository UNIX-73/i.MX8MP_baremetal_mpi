#pragma once


#include "../../malloc/early_kalloc.h"
#include "lib/mem.h"


typedef enum {
    MM_VMEM_LO = 0,
    MM_VMEM_HI = 1,
} mm_vloc;

void vmalloc_init();
v_uintptr vmalloc_update_memblocks(const memblock*, size_t);
v_uintptr vmalloc(size_t, mm_vloc);
