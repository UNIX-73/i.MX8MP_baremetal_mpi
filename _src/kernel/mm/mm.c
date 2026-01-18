#include "kernel/mm/mm.h"

#include <boot/panic.h>
#include <frdm_imx8mp.h>

#include "./init/early_kalloc.h"
#include "./phys/pg_allocator.h"
#include "mm_info.h"

void mm_early_init()
{
    mm_info_init();

    // init early kalloc. Used by the next initialization stages
    early_kalloc_init();

    mm_page_allocator_init();
}

void mm_init()
{
}
