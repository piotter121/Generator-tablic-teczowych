#include "table_row.h"

pthread_mutex_t rand_mutex = PTHREAD_MUTEX_INITIALIZER;

void *initRow(void *r) {
	int i;
	int alphabet_len = strlen(ALPHABET);
	char *alphabet = (char *) malloc((alphabet_len + 1) * sizeof(*alphabet));
	table_row *row = (table_row *) r;

	strcpy(alphabet, ALPHABET);

	for (i = 0; i < PASS_LENGTH; i++) {
		pthread_mutex_lock(&rand_mutex);
		(*row).first_pass[i] = alphabet[rand() % alphabet_len];
		pthread_mutex_unlock(&rand_mutex);
	}
	
	for (i = 0; i < HASH_LEN; i++) 
		(*row).last_hash[i] = '0';
		
	(*row).rounds = ROUNDS;

	free(alphabet);

	return NULL;	
}

void initTable(table_row *rows, int nrows) {
	srand(SEED);
	operation_on_rows(rows, nrows, initRow);
}

void operation_on_rows(void *rows, int n, void *(*operation)(void *)) {
	int i;	
	table_row *r = (table_row *) rows;
	pthread_t *threads = (pthread_t *) malloc(n * sizeof(*threads));
	
	for (i = 0; i < n; i++) {
		if (pthread_create(&threads[i], NULL, operation, &r[i])) {
			fprintf(stderr, "Błąd w tworzeniu wątków!\n");
			exit(EXIT_FAILURE);
		}
	}

	for (i = 0; i < n; i++) {
		if (pthread_join(threads[i], NULL)) {
			fprintf(stderr, "Błąd podczas łączenia wątków!");
			exit(EXIT_FAILURE);
		}
	}
	free(threads);
}
