#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "table_row.h"
#include "md5.h"
#include "reduction_function.h"

void *hash(void *block) {
	return md5((char *) block, PASS_LENGTH);
}

void hash_rows(char **pass, char **hashes, int n) {
	int i;	
	pthread_t *threads;
	
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
}

int main(int argc, char **argv) {
	int nrows = 0;
	int i, j, k, parts, n;
	table_row *rows;
	char **tmp_hash, **tmp_pass;
	FILE *out = NULL;

	if (argc < 2) {
		fprintf(stderr, "Zla liczba argumentow\n");
		exit(EXIT_FAILURE);
	}
	out = (argc == 3) ? fopen(argv[2], "a") : stdout;
	if (out == NULL && argc == 3) {
		fprintf(stderr, "Nie można otworzyć pliku o podanej nazwie %s\n", argv[2]);
		exit(EXIT_FAILURE);
	}
	nrows = atoi(argv[1]);
	parts = nrows % ROWS_PER_PART ? (nrows / ROWS_PER_PART) + 1 : nrows / ROWS_PER_PART;
	
	rows = (table_row *) malloc(ROWS_PER_PART * sizeof(*rows));
	for (i = 0; i < ROWS_PER_PART; i++) {
		rows[i].first_pass = (char *) malloc(PASS_LENGTH * sizeof(char));
		rows[i].last_hash = (char *) malloc(HASH_LEN * sizeof(char));
	}
	initTable(rows, ROWS_PER_PART);
	tmp_pass = (char **) malloc(ROWS_PER_PART * sizeof(char *));
	tmp_hash = (char **) malloc(ROWS_PER_PART * sizeof(char *));
	for (i = 0; i < ROWS_PER_PART; i++) {
		tmp_pass[i] = (char *) malloc(PASS_LENGTH * sizeof(char));
		for (j = 0; j < PASS_LENGTH; j++) 
			tmp_pass[i][j] = rows[i].first_pass[j];
		tmp_hash[i] = (char *) malloc(HASH_LEN * sizeof(char));		
	}
	
	for (k = 0; k < parts; k++) {
		if (nrows % ROWS_PER_PART && k == parts - 1)
			n = nrows % ROWS_PER_PART;
		else 
			n = ROWS_PER_PART;
		
		initTable(rows, n);
		
		for (i = 0; i < ROUNDS; i++) {
			for (j = 0; j < parts; j++)
				hash_rows(tmp_pass, tmp_hash, n);

			if (i != ROUNDS - 1) 
				reduct_rows(tmp_pass, tmp_hash, n);
		}
		for (i = 0; i < n; i++) 
			for (j = 0; j < HASH_LEN; j++) 
				rows[i].last_hash[j] = tmp_hash[i][j];
				
		for (i = 0; i < n; i++)
			fprintf(out, "%s %s %d\n", rows[i].first_pass, rows[i].last_hash, rows[i].rounds);	
	}
	
	if (argc == 3 && out != NULL) 
		fclose(out);
	for (i = 0; i < ROWS_PER_PART; i++) {
		free(tmp_pass[i]);
		free(tmp_hash[i]);
		free(rows[i].first_pass);
		free(rows[i].last_hash);
	}
	free(rows);
	free(tmp_hash);
	free(tmp_pass);	

	return 0;
}
