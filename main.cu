#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "table_row.h"
#include "md5.h"
#include "reduction_function.h"

#define SEED time(NULL) 

int main(int argc, char **argv) {
	long nrows = 0, i;
	table_row *rows;
	char *tmp_hash, *tmp_pass;

	if (argc != 2) {
		printf("Zla liczba argumentow\n");
		exit(EXIT_FAILURE);
	}
	nrows = atol(argv[1]);
	rows = initTable(nrows);
	

#ifdef DEBUG
	printf("Początkowe hasła: \n");
	for (i = 0; i < nrows; i++) {
		printf("%s\n", rows[i].first_pass);
	}
#endif

	for (i = 0; i < ROUNDS; i++) {
		hash(tmp_pass, tmp_hash, nrows);
		if (i != ROUNDS - 1) 
			reduct(tmp_pass, tmp_hash, nrows);
	}

#ifdef DEBUG 
	printf("Końcowe hasła: \n");
	for (i = 0; i < nrows; i++) {
		printf("%s\n", rows[i].last_pass);
	}
#endif DEBUG	

	free(rows);
	free(tmp_hash);
	free(tmp_pass);
	pthread_exit(NULL);

	return 0;
}
