#pragma once


#include <kernel/mm.h>
#include <kernel/panic.h>
#include <lib/mem.h>
#include <lib/stdbitfield.h>
#include <lib/stdmacros.h>


typedef bitfield64 bf;

typedef struct vmalloc_node {
    struct vmalloc_node* next;
    struct vmalloc_node* prev;

    v_uintptr start;
    size_t size;
} vmalloc_node;


#define VMALLOC_NODE_SIZE sizeof(vmalloc_node)

#define CONTAINER_HEADER_SIZE sizeof(struct vmalloc_node_container*)
#define CONTAINER_AVAILABLE_BYTES (KPAGE_SIZE - __SIZEOF_POINTER__)

#define MAX_NODES_ESTIMATE (CONTAINER_AVAILABLE_BYTES / sizeof(vmalloc_node))


#define NODE_COUNT                                                                           \
    ((CONTAINER_AVAILABLE_BYTES - BITFIELD_COUNT_FOR(MAX_NODES_ESTIMATE, bf) * sizeof(bf)) / \
     sizeof(vmalloc_node))

#define BF_COUNT BITFIELD_COUNT_FOR(NODE_COUNT, bf)


typedef struct {
    // bitfield that represents if a node is reserved (1) or free for reservation (0).
    bf reserved[BF_COUNT];
    vmalloc_node nodes[NODE_COUNT];
} container_data;

typedef struct vmalloc_node_container {
    _Alignas(KPAGE_ALIGN) struct vmalloc_node_container* next;

    container_data data;
} vmalloc_node_container;


_Static_assert(sizeof(vmalloc_node_container) <= KPAGE_SIZE &&
               _Alignof(vmalloc_node_container) == KPAGE_ALIGN);

_Static_assert(BF_COUNT* BITFIELD_CAPACITY(bf) >= NODE_COUNT);


vmalloc_node* vmalloc_node_get_new(vmalloc_node_container* first);
void vmalloc_node_free(vmalloc_node_container* first, vmalloc_node* node);

static inline void vmalloc_container_init_null(vmalloc_node_container* c)
{
    ASSERT(c);

    // TODO: use memzero
    c->next = NULL;
    c->data = (container_data) {0};
}