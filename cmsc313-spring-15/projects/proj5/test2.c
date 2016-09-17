// James Guan
// Test file in the case that too many books were set.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "book_info_heap.h"

int main()
{
	time_t t;
	init_heap();
	book_info *info1, *info2, *info3, *info4, *info5, *info6, *info7, *info8, *info9, *info10,
	*info11, *info12, *info13, *info14, *info15, *info16, *info17, *info18, *info19, *info20;
	book_info * stuff[] = {info1, info2, info3, info4, info5, info6, info7, info8, info9, info10,
	info11, info12, info13, info14, info15, info16, info17, info18, info19, info20};
	
	srand((unsigned) time(&t));
	printf("Deleting 5 things randomly: ");
	
	dump_heap();
	unsigned i;
	for ( i = 0; i < ARRAY_SIZE; i++)
	{
		book_info* ptr = new_book_info();
		
		if (ptr != NULL)
		{
				strncpy(ptr->title, "crap", 4);
				ptr->year_published = 2000 + ARRAY_SIZE + i;
				stuff[i] = ptr;
		}
		else
            printf("Error at i = %u,\nno more free items in the array.\n", i);
	}
	
	dump_heap();
	for ( i = 0; i < 5; i++)
	{
		del_book_info(stuff[rand() % 20]);
	}
	
	dump_heap();
	printf("\n\n\nNow deleting 20 things randomly: ");
	for ( i = 0; i < 20; i++)
	{
		del_book_info(stuff[rand() % 20]);
	}
	dump_heap();
	
	
	return 0;
}