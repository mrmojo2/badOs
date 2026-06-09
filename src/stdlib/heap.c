#include "heap.h"
#include "config.h"
#include "status.h"
#include "memory.h"

static int heap_validate_alignment(void* ptr){
	return ((unsigned int)ptr % KERNEL_HEAP_BLOCK_SIZE) == 0;
}


//validate that end addr provided by caller is correct for the table that is provided
//TODO: maybe the caller doesnt have to create the heap_table_t structure and it is created for them
static int heap_validate_table(void* ptr, void* end, heap_table_t* table){
	int res = 0;
	
	size_t table_size = (size_t)(end-ptr);
	size_t total_blocks = table_size / KERNEL_HEAP_BLOCK_SIZE;
	if(table->total != total_blocks){
		res = -EINVARG;
		goto out;
	}

out: 
	return res;
}

static uint32_t heap_align_size_to_block(uint32_t bytes){
	if((bytes % KERNEL_HEAP_BLOCK_SIZE) == 0){
		return bytes;
	}

	bytes = bytes - (bytes % KERNEL_HEAP_BLOCK_SIZE);	//returns bytes in multiple of KERNEL_HEAP_BLOCK_SIZE
	bytes += KERNEL_HEAP_BLOCK_SIZE;
	return bytes;
}


int heap_create(heap_t* heap ,void* ptr, void* end, heap_table_t* table){
	int res = 0;
	
	//validate the alignment of the heap
	if(!heap_validate_alignment(ptr) || !heap_validate_alignment(end)){
		res = -EINVARG;
		goto out;
	}

	memset(heap,0,sizeof(heap_t));
	heap->start_addr = ptr;
	heap->table = table;

	res = heap_validate_table(ptr,end,table);
	if(res<0){
		goto out;
	}

	//mark all the blocks as free in the block table entry
	size_t table_size = sizeof(unsigned char ) * table->total;
	memset(table->entries, HEAP_BLOCK_TABLE_ENTRY_FREE,table_size);
out:
	return res;	
}


int heap_get_start_block(heap_t* heap,uint32_t total_blocks){
	heap_table_t* table = heap->table;

	int current_block = 0;
	int start_block = -1;

	for(size_t i=0; i< table->total; i++){
		unsigned char entry_type = (table->entries[i] & 0x0f);
		if(entry_type != HEAP_BLOCK_TABLE_ENTRY_FREE){
			current_block = 0;
			start_block = -1;
			continue;
		}

		//for the first free block
		if(start_block == -1)	start_block = i;

		current_block++;

		if(current_block == total_blocks) break;

	}

	if(start_block == -1){
	
		return -ENOMEM;
	}

	return start_block;

}


static void heap_mark_blocks_taken(heap_t* heap, int start_block, int total_blocks){
	heap_table_t* table = heap->table;


	//mark first block as starting block
	table->entries[start_block] = HEAP_BLOCK_IS_FIRST | HEAP_BLOCK_TABLE_ENTRY_TAKEN;

	//mark the middle blocks and the first block with HEAP_BLOCK_HAS_NEXT if more than one blocks
	for(int i=0; i< total_blocks - 1; i++){
		unsigned char entry = (HEAP_BLOCK_TABLE_ENTRY_TAKEN | HEAP_BLOCK_HAS_NEXT);
		table->entries[start_block + i] |= entry;


	}

	//mark the last block
	table->entries[start_block + total_blocks - 1] |= HEAP_BLOCK_TABLE_ENTRY_TAKEN;
}



void* heap_malloc(heap_t* heap, size_t size){
	
	size_t aligned_size = heap_align_size_to_block(size);
	uint32_t total_blocks = aligned_size / KERNEL_HEAP_BLOCK_SIZE;

	
	void* address = 0;

	//if there are enough total blocks free continously this fn return the index of the start of the series
	int start_block = heap_get_start_block(heap,total_blocks);
	if(start_block < 0){
		goto out;
	}


	//convert the index start_block to address
	address = heap->start_addr + (start_block * KERNEL_HEAP_BLOCK_SIZE);


	//mark those blocks as taken
	heap_mark_blocks_taken(heap, start_block, total_blocks);

out:
	return address;
}

void heap_free(heap_t* heap, void* ptr){
	
	//convert address(ptr) to blockno
	int start_index =(int)(ptr - heap->start_addr)/KERNEL_HEAP_BLOCK_SIZE;
	
	for(int i = start_index; i < (int)heap->table->total; i++){				//assuming the total heap size is small its okay to cast size_t to int still a litle bit sketchy
		heap->table->entries[i] = HEAP_BLOCK_TABLE_ENTRY_FREE;
		
		unsigned char has_next_block = (heap->table->entries[i] & HEAP_BLOCK_HAS_NEXT);
		if(!has_next_block){
			break;
		}

	}
}
