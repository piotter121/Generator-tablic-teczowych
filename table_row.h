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

typedef struct row {
	char *first_pass;
	char *last_hash;
	int rounds;
} table_row;

void *initRow(void *);

table_row *initTable(int);

void operation_on_vector(void *, int, void *(*)(void *));

#endif
