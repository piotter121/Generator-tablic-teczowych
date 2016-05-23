#ifndef _TABLE_ROW_H
#define _TABLE_ROW_H
#define PASS_LENGTH 8

typedef struct row {
	char first_pass[PASS_LENGTH];
	char last_pass[PASS_LENGTH];
	int rounds;
} table_row;

#endif
