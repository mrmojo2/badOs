#include "kheap.h"
#include "heap.h"
#include "config.h"
#include "graphics.h"

heap_t kernel_heap;
heap_table_t kernel_heap_table;

void kheap_init(){
	int total_table_entries = KERNEL_HEAP_SIZE_BYTES / KERNEL_HEAP_BLOCK_SIZE;
	kernel_heap_table.entries = (unsigned char*)(KERNEL_HEAP_TABLE_ADDRESS);
	kernel_heap_table.total   = total_table_entries;

	void* end = (void*)(KERNEL_HEAP_ADDRESS + KERNEL_HEAP_SIZE_BYTES);
	int res = heap_create(&kernel_heap,(void*)(KERNEL_HEAP_ADDRESS),end,&kernel_heap_table);

	if(res < 0){
		print("Failed to create the kernel heap\n");
	}
}

void* kmalloc(size_t size){
	return heap_malloc(&kernel_heap,size);	
}

void kfree(void* ptr){
	heap_free(&kernel_heap,ptr);
}
