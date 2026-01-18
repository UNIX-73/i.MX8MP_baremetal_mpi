#include <lib/align.h>
#include <lib/math.h>
#include <lib/stdint.h>

#include "../init/early_kalloc.h"
#include "../mm_info.h"
#include "boot/panic.h"
#include "kernel/mm/mm_types.h"


typedef struct
{
    uint32 head;
} free_list;

#define FREE_LIST_NULL_VALUE UINT32_MAX

typedef struct
{
    int8 order; // sign bit [7] == free, 6..0 order
    uint32 next;
    uint32 prev;
    // TODO: add the real data
} buddy;


static p_uintptr pg_allocator_arena_;

static size_t max_order_;


static free_list* p_free_lists_;
static buddy* p_buddies_;


static inline bool is_free(int8 order)
{
    return order < 0;
}


static inline uint8 get_order(int8 order)
{
    return order & ~(1 << 7);
}


void mm_page_allocator_init()
{
    size_t num_pages = mm_info_page_count();
    max_order_ = u64log2_floor(num_pages);


    size_t free_lists_bytes = sizeof(free_list) * max_order_;

    size_t buddies_start_offset = ALIGN_UP(free_lists_bytes, _Alignof(buddy));

    size_t buddies_bytes = sizeof(buddy) * num_pages;

    size_t pg_allocator_bytes = buddies_start_offset + buddies_bytes;

    pg_allocator_arena_ = early_kalloc(pg_allocator_bytes, "page_allocator", true);
    ASSERT(pg_allocator_arena_);


    p_free_lists_ = (free_list*)pg_allocator_arena_;
    p_buddies_ = (buddy*)(pg_allocator_arena_ + buddies_start_offset);

    // TODO: check if needed to initialize with n of pages because not pow2
    for (size_t i = 0; i < max_order_; i++)
        p_free_lists_[i] = (free_list) {FREE_LIST_NULL_VALUE};
    p_free_lists_[max_order_] = (free_list) {0}; // start with only the first order being valid

    
}


static void alloc_(size_t order)
{
}

static void free(size_t idx)
{
}