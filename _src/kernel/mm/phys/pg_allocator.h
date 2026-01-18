#pragma once
#include <lib/stdint.h>

typedef struct
{
    uint8 order;
    bool free;
} mm_pg_buddy;


void mm_page_allocator_init();