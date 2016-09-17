#ifndef BUF_DESC_H
#define BUF_DESC_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>

typedef struct buf_desc{
	void * buffer;
	unsigned int len;
	struct buf_desc * next;
} buf_desc;

void init_buf_desc(void);

void allocation(int amount);

buf_desc * new_buf_desc();

void del_buf_desc();

void clean_buf_desc();

void dump_buf_desc();

void hexdump_buf_desc(buf_desc *buf);

#endif