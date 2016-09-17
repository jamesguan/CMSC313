/*	File: book_info_heap.c 
 *	Last updated: 04/2/2015
 *	Author: James Guan
 *	Class:  CMSC 313
 *	Teacher: Wiles
 *	
 *	Description: This has all the function definitions for the
 * 				book_info array where it handles initialization,
 *				deletion, returning an empty book_info, and printing.
 * Build with: gcc -o main5 -m32 -g main5.c book_info_heap.c
 */
#ifndef BOOK_INFO_HEAP_H
#define BOOK_INFO_HEAP_H

#define ARRAY_SIZE 20

// This will initialize the heap with clean empty data
typedef struct {

	char title [50];
	char author[40];
	unsigned year_published;
	
} book_info;


// This will return a pointer to an empty book_info
void init_heap();

// This will return a pointer to an empty book_info
book_info* new_book_info();

// This will clear the items in the struct chosen to be deleted,
// have the thing point to the previous first free book_info,
// and reset the first_free_index to point to this newly cleared book_info
void del_book_info();

// Prints the items in the array
void dump_heap();

#endif