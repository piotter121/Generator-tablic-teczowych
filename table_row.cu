#include "table_row.h"

pthread_mutex_t rand_mutex = PTHREAD_MUTEX_INITIALIZER;

void *initRow(void *r) {
	int i;
	int alphabet_len = strlen(ALPHABET);
	char *alphabet = (char *) malloc((alphabet_len + 1) * sizeof(*alphabet));
	table_row *row = (table_row *) r;

	strcpy(alphabet, ALPHABET);
	(*row).first_pass = (char *) malloc(PASS_LENGTH * sizeof(char));

	for(i = 0; i < PASS_LENGTH; i++) {
		pthread_mutex_lock(&rand_mutex);
		(*row).first_pass[i] = alphabet[rand() % alphabet_len];
		pthread_mutex_unlock(&rand_mutex);
	}

	(*row).last_hash = (char *) malloc(HASH_LEN * sizeof(char));
	(*row).rounds = ROUNDS;

	return NULL;	
}

table_row *initTable(int nrows) {
	table_row *rows;
	int table_size = nrows * sizeof(table_row);

	rows = (table_row *) malloc(table_size);
	srand(SEED);
	operation_on_vector(rows, nrows, initRow);

	return rows;
}

void operation_on_vector(void *rows, int n, void *(*op)(void *)) {
	int i;	
	table_row *r = (table_row *) rows;
	pthread_t *threads = (pthread_t *) malloc(n * sizeof(*threads));
	
	for (i = 0; i < n; i++) {
		if (pthread_create(&threads[i], NULL, op, &r[i])) {
			fprintf(stderr, "Błąd w tworzeniu wątków!");
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
