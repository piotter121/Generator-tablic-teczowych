#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "table_row.h"
#include "md5.h"
#include "reduction_function.h"

void *hash(void *block) {
	return md5((char *) block, PASS_LENGTH);
}

char **hash_rows(char **pass, int n) {
	int i;	
	char **hashes;
	pthread_t *threads;
	
	hashes = (char **) malloc(n * sizeof(char *));
	threads = (pthread_t *) malloc(n * sizeof(pthread_t));
	for (i = 0; i < n; i++) {
		if (pthread_create(&threads[i], NULL, hash, pass[i])) {
			fprintf(stderr, "Błąd w tworzeniu wątków!");
			exit(EXIT_FAILURE);
		}
	}

	for (i = 0; i < n; i++) {
		if (pthread_join(threads[i], (void **) &hashes[i])) {
			fprintf(stderr, "Błąd podczas łączenia wątków!");
			exit(EXIT_FAILURE);
		}
	}

	free(threads);	
	return hashes;
}

int main(int argc, char **argv) {
	int nrows = 0;
	int i, j;
	table_row *rows;
	char **tmp_hash = NULL, **tmp_pass;

	if (argc != 2) {
		printf("Zla liczba argumentow\n");
		exit(EXIT_FAILURE);
	}
	nrows = atoi(argv[1]);
	rows = initTable(nrows);
	tmp_pass = (char **) malloc(nrows * sizeof(char *));
	for (i = 0; i < nrows; i++) {
		tmp_pass[i] = (char *) malloc(PASS_LENGTH * sizeof(char));
		for (j = 0; j < PASS_LENGTH; j++) 
			tmp_pass[i][j] = rows[i].first_pass[j];
	}	

#ifdef DEBUG
	printf("Początkowe hasła: \n");
	for (i = 0; i < nrows; i++) {
		printf("%s\n", rows[i].first_pass);
	}
#endif

	for (i = 0; i < ROUNDS; i++) {
		if (tmp_hash != NULL) 
			free(tmp_hash);
		tmp_hash = hash_rows(tmp_pass, nrows);
		if (i != ROUNDS - 1) 
			reduct_rows(tmp_pass, tmp_hash, nrows);
	}

	for (i = 0; i < nrows; i++) {
		for (j = 0; j < HASH_LEN; j++)
			rows[i].last_hash[j] = tmp_hash[i][j];
	}

	for (i = 0; i < nrows; i++) {
		printf("%s %s %d\n", rows[i].first_pass, rows[i].last_hash, rows[i].rounds);
	}

	free(rows);
	free(tmp_hash);
	free(tmp_pass);
	pthread_exit(NULL);

	return 0;
}
