
#include "buf_desc.h"

#ifndef HEXDUMP_COLS
#define HEXDUMP_COLS 8
#endif

static buf_desc * beginning = NULL;
static buf_desc * ending = NULL;
static int available = 0;
static int unavailable = 0;
static int total = 0;

void init_buf_desc(){
	allocation(10);
	//dump_buf_desc();
	//printf("Finished init\n");
}

void allocation(int amount){
	//printf("Start Allocation\n");
	int i;
	for ( i = 0; i < amount && total < 20; i++)
	{
		buf_desc * temp = malloc(sizeof(buf_desc));
		temp->next = NULL;
		temp->next = beginning;
		beginning = temp;
		temp->buffer = NULL;
		temp->len = 0;
		available++;
		total = available + unavailable;
	}
	assert(total <= 20);
	total = available + unavailable;
	//dump_buf_desc();
	//printf("End Allocation\n");
}

buf_desc * new_buf_desc(){
	//printf("New Buf\n");
	buf_desc * temp = NULL;
	if (beginning == NULL){
		if (total < 20)
		{
			int k = 20 - total;
			if (k > 10)
			{
				k = 10;
			}
			if (k > 0)
			{
				allocation(k);
				temp = beginning;
				beginning = beginning->next;
				unavailable++;
				unavailable--;
				total = unavailable + available;
				temp->next = NULL;
			}
			
			
		}
		return temp;
	}
	else
	{
		temp = beginning;
		beginning = beginning->next;
		unavailable++;
		available--;
		total = unavailable + available;
		temp->next = NULL;
	}
	
	//dump_buf_desc();
	return temp;
	//printf("End new buf\n");
}

void del_buf_desc(buf_desc * buf){
	//printf("Begin del_buf\n");
	//printf("Beginning: %p\n", beginning);
	//printf("buf:	  %p\n", buf);
	//printf("bufPtr:	  %p\n", buf->next);
	buf_desc * iterator = buf;
	buf_desc * temp = NULL;
	while (iterator != NULL && total < 20)
	{
		
		iterator->buffer = NULL;
		iterator->len = 0;
		temp = iterator->next;
		iterator->next = beginning;
		beginning = iterator;
		iterator = temp;
		available++;
		unavailable--;
		total = unavailable + available;
		//printf("Original: %p\n", iterator);
		//printf("Next:	  %p\n", iterator->next);
		//printf("Beginning: %p\n", beginning);
		getchar();
	}
	
	//printf("Total: %i\n", total);
	//dump_buf_desc();
	//printf("End del_buf\n");
}

void clean_buf_desc(){
	//printf("Start clean_buf\n");
	if (unavailable <= 10 && total >= 20){
		buf_desc * iterator = beginning;
		int i;
		for ( i = 0; i < 10; i++){
			if (beginning != NULL){
				beginning = iterator->next;
				free(iterator);
				iterator = beginning;
				available--;
			}
		}
		total = available + unavailable;
	}
	//dump_buf_desc();
	//printf("End clean_buf\n");
}

void dump_buf_desc(){
	printf("Total allocated entries: %i\n", total);
	printf("Total available entries: %i\n", available);
	printf("Total unavailable entries: %i\n", unavailable);
	printf("Addresses of available buf_structs:\n");
	buf_desc * iterator = beginning;
	while (iterator){
		//printf("before");
		printf("	%p\n", iterator);
		iterator = iterator->next;
		//printf("Iterator after: %p\n", iterator);
	}
	//printf("FINISH\n");
}


void hexdump_buf_desc(buf_desc *buf){
	/*
	len = available;
	unsigned int i, j;

        for(i = 0; i < len + ((len % HEXDUMP_COLS) ? (HEXDUMP_COLS - len % HEXDUMP_COLS) : 0); i++)
        {
                // print offset
                if(i % HEXDUMP_COLS == 0)
                {
                        printf("0x%06x: ", i);
                }

                // print hex data
                if(i < len)
                {
                        printf("%02x ", 0xFF & ((char*)mem)[i]);
                }
                else // end of block, just aligning for ASCII dump
                {
                        printf("   ");
                }

                // print ASCII dump 
                if(i % HEXDUMP_COLS == (HEXDUMP_COLS - 1))
                {
                        for(j = i - (HEXDUMP_COLS - 1); j <= i; j++)
                        {
                                if(j >= len) // end of block, not really printing
                                {
                                        putchar(' ');
                                }
                                else if(isprint(((char*)mem)[j])) // printable char
                                {
                                        putchar(0xFF & ((char*)mem)[j]);
                                }
                                else // other char
                                {
                                        putchar('.');
                                }
                        }
                        putchar('\n');
                }
        }
		*/
}