#include <stdio.h>
#include <stdlib.h>
#include <rpc/des_crypt.h>
#include <pthread.h>

#include "table_row.h"

#define SEED 42

void *initRow(void *r) {
	int i;
	char *alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	table_row *row = (table_row *) r;
	for(i = 0; i < PASS_LENGTH; i++) {
		(*row).first_pass[i] = alphabet[rand() % 62];
	}
	(*row).rounds = 0;
	return NULL;	
}

int main(int argc, char **argv) {
	int rounds = 5, *rounds_d;
	int nrows = 0, *nrows_d;
	table_row *rows, *rows_d;
	int table_size, i;
	pthread_t *threads;

	if (argc != 2) {
		printf("Zla liczba argumentow\n");
		exit(EXIT_FAILURE);
	}
	srand(SEED);
	nrows = atoi(argv[1]);
	table_size = nrows * sizeof(table_row);
	rows = (table_row *) malloc(table_size);
	threads = (pthread_t *) malloc(nrows * sizeof(pthread_t));

	for (i = 0; i < nrows; i++) {
		if (pthread_create(&threads[i], NULL, initRow, (void *) &rows[i])) {
			fprintf(stderr, "Blad w tworzeniu watkow!\n");
			exit(EXIT_FAILURE);
		}
	}
	for (i = 0; i < nrows; i++) {
		if (pthread_join(threads[i], NULL)) {
			fprintf(stderr, "Blad podczas zbierania watkow\n");
			exit(EXIT_FAILURE);
		}
	}

	for (i = 0; i < nrows; i++) printf("%s\n", rows[i].first_pass);

	free(rows);
	free(threads);
	pthread_exit(NULL);

	return 0;
}
