#include "table_row.h"

void operation_on_rows(table_row *rows, int n, (void *)(*op)(void *) {
	int i;	
	pthread_t* threads = (pthread_t *) malloc(n * sizeof(*threads));
	
	for (i = 0; i < n; i++) 
		if (pthread_create(&threads[i], NULL, op, (void *) &rows[i])) {
			fprintf(stderr, "Błąd w tworzeniu wątków!");
			exit(EXIT_FAILURE);
		}

	for (i = 0; i < n; i++) 
		if (pthread_join(threads[i], NULL)) {
			fprintf(stderr, "Błąd podczas łączenia wątków!");
			exit(EXIT_FAILURE);
		}
}
