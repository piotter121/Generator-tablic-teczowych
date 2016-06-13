#ifndef _TABLE_ROW_H
#define _TABLE_ROW_H

#include <pthread.h>
#include <stdlib.h>
#include <string.h>
#include "md5.h"

#define PASS_LENGTH 4
#define ALPHABET "1234567890"
#define ROUNDS 5
#define SEED time(NULL) 
#define ROWS_PER_PART 32500

typedef struct row {
	char *first_pass;
	char *last_hash;
	int rounds;
} table_row;

void *initRow(void *);

void initTable(table_row *, int);

void operation_on_rows(void *, int, void *(*)(void *));

#endif
