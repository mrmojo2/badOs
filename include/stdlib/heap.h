#ifndef HEAP_H
#define HEAP_H

#include "config.h"
#include <stddef.h>
#include <stdint.h>

#define HEAP_BLOCK_TABLE_ENTRY_TAKEN 0x01
#define HEAP_BLOCK_TABLE_ENTRY_FREE 0x00

#define HEAP_BLOCK_HAS_NEXT  0x80
#define HEAP_BLOCK_IS_FIRST   0x40

typedef struct{
	unsigned char* entries;
	size_t total;
} heap_table_t;

typedef struct{
	heap_table_t* table;
	void* start_addr;
} heap_t;

int heap_create(heap_t* heap ,void* ptr, void* end, heap_table_t* table);
void* heap_malloc(heap_t* heap, size_t size);
void heap_free(heap_t* heap, void* ptr);

#endif
