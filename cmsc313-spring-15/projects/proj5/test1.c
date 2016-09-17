// James Guan
// Test file in the case that too many books were set.

#include <stdio.h>
#include <stdlib.h>
#include "book_info_heap.h"

int main()
{
	init_heap();
	
	printf("Allocating 13 more things than the array can hold: \n");
	unsigned i;
	for ( i = 0; i < ARRAY_SIZE + 13; i++)
	{
		book_info* ptr = new_book_info();
		if (ptr != NULL)
		{
				ptr->year_published = ARRAY_SIZE;
				
		}
		else
            printf("Error at i = %u,\nno more free items in the array.\n", i);
	}
	
	
	
	dump_heap();
	
	return 0;
}