/*	File: book_info_heap.c 
 *	Last updated: 04/2/2015
 *	Author: James Guan
 *	Class:  CMSC 313
 *	Teacher: Wiles
 *	
 *	Description: This has all the function definitions for the
 * 				book_info array where it handles initialization,
 *				deletion, returning an empty book_info, and printing.
 */
#include "book_info_heap.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static book_info book_infos[ARRAY_SIZE]; // This is the array of books

static unsigned first_free_index; // This points to the first free index

// This will initialize the heap with clean empty data
void init_heap()
{
	unsigned i; // I want to put this in the for loop but I can't... damn you old C compiler.
	for (i = 0; i < ARRAY_SIZE; i++)
	{
		book_infos[i].year_published = i + 1; // Sets the year published 
	}
	first_free_index = 0; // Initializes the index to be at the first free item (currently at index 0)
}// end init_heap

// This will return a pointer to an empty book_info
book_info* new_book_info()
{
	book_info *bookptr = NULL;
	if (first_free_index != ARRAY_SIZE)
	{
		bookptr = &book_infos[first_free_index]; // Set bookptr to the first empty book_info struct in the array
		first_free_index = bookptr->year_published; // Get the index of the next free item
	}// end if
	return bookptr; // return the pointer that is at an empty book_info struct
}// end new_book_info

// This will clear the items in the struct chosen to be deleted,
// have the thing point to the previous first free book_info,
// and reset the first_free_index to point to this newly cleared book_info
void del_book_info(book_info * ptr)
{
	
	if (ptr >= book_infos && ptr <= &book_infos[ARRAY_SIZE - 1] && ptr->title[0] != '\0')
	{
		ptr->year_published = first_free_index; // set the year_published to the previous date available
		strcpy(ptr->title, "\0"); // clear the title
		strcpy(ptr->author, "\0"); // clear the author
		first_free_index = ptr - book_infos; // Make the index of the new free item this one
		ptr = NULL;
	}// end if
}// end del_book_info

// Prints the items in the array
void dump_heap()
{
	printf("\n*** BEGIN HEAP DUMP ***\n");
	printf("head = %u\n", first_free_index);
	
	unsigned i;
	for (i = 0; i < ARRAY_SIZE; i++)
	{
		printf("%3u: %d  %s  %s\n", i, book_infos[i].year_published, book_infos[i].title, book_infos[i].author);// Print the formatted thing
	}// end for

	printf("*** END HEAP DUMP ***\n");
}// end dump_heap