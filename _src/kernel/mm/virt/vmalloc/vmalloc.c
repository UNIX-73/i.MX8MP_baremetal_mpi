#include "vmalloc.h"

#include <kernel/mm.h>
#include <kernel/panic.h>
#include <lib/mem.h>
#include <lib/stdbitfield.h>
#include <lib/stdint.h>
#include <lib/stdmacros.h>

#include "../../malloc/early_kalloc.h"
#include "../../mm_info.h"
#include "containers/containers.h"


static vmalloc_node_container* first_container;
static vmalloc_node* first_node;

void vmalloc_init()
{
    first_container = mm_kpa_to_kva_ptr(early_kalloc(KPAGE_SIZE, "vmalloc_nodes", true, false));

    vmalloc_container_init_null(first_container);

    first_node = vmalloc_node_get_new(first_container);
    *first_node = (vmalloc_node) {
        .next = NULL,
        .prev = NULL,
        .start = MM_KSECTIONS.heap.start,
        .size = MM_KSECTIONS.heap.size,
    };
}


v_uintptr vmalloc_update_memblocks(const memblock* mblcks, size_t n)
{
    v_uintptr heap_start = first_node->start;
    v_uintptr heap_end = heap_start + first_node->size;

    v_uintptr new_start = heap_start;

    for (size_t i = 0; i < n; i++) {
        const memblock* mb = &mblcks[i];

        v_uintptr mb_start = mm_kpa_to_kva(mb->addr);
        v_uintptr mb_end = mb_start + mb->blocks * KPAGE_SIZE;

        // check overlapping
        if (mb_end <= heap_start || mb_start >= heap_end)
            continue;

        if (mb_end > new_start)
            new_start = mb_end;
    }

    ASSERT(new_start <= heap_end);

    first_node->start = new_start;
    first_node->size = heap_end - new_start;

    return first_node->start;
}

v_uintptr vmalloc(size_t pages, mm_vloc loc)
{
    if (loc == MM_VMEM_LO)
        PANIC("NOT IMPLEMENTED YET");

    size_t size = pages * KPAGE_SIZE;

    vmalloc_node* cur = first_node;
    vmalloc_node* prev = NULL;

#ifdef DEBUG
    // check if the list is correctly ordered
    vmalloc_node* dbg_cur = first_node;
    v_uintptr dbg_start = 0x0;
    while (dbg_cur) {
        DEBUG_ASSERT(dbg_start < dbg_cur->start, "vmalloc: not ordered");
        dbg_start = dbg_cur->start;
        dbg_cur = dbg_cur->next;
    }
#endif

    while (cur) {
        if (size <= cur->size) {
            v_uintptr va = cur->start;

            if (size == cur->size) {
                vmalloc_node* to_remove = cur;

                if (prev)
                    prev->next = cur->next;
                else {
                    DEBUG_ASSERT(first_node == to_remove);
                    first_node = cur->next;
                }
                if (cur->next)
                    cur->next->prev = prev;

                vmalloc_node_free(first_container, to_remove);
            }
            else {
                cur->size -= size;
                cur->start += size;
            }

            return va;
        }

        prev = cur;
        cur = cur->next;
    }

    PANIC("vmalloc: no more available vmem");
}


v_uintptr vfree(v_uintptr va, size_t pages);