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
	
	//printf("Inicjacja wątków\n");
	threads = (pthread_t *) malloc(n * sizeof(pthread_t));
	for (i = 0; i < n; i++) {
		//printf("Tworzenie i uruchamianie wątku nr %d\n", i);
		//printf("Przekazana wartość do hashowania to pass[%d] = %s\n", i, pass[i]);
		if (pthread_create(&threads[i], NULL, hash, pass[i])) {
			fprintf(stderr, "Błąd w tworzeniu wątków!");
			exit(EXIT_FAILURE);
		}
	}

	//printf("Łączenie wątków\n");
	for (i = 0; i < n; i++) {
		//printf("Łączenie wątku nr %d\n", i);
		if (pthread_join(threads[i], (void **) &hashes[i])) {
			fprintf(stderr, "Błąd podczas łączenia wątków!");
			exit(EXIT_FAILURE);
		}
		//printf("Odebrana wartość to hashes[%d] = %s\n", i, hashes[i]);
	}

	free(threads);	
}

int main(int argc, char **argv) {
	int nrows = 0;
	int i, j;
	table_row *rows;
	char **tmp_hash, **tmp_pass;

	if (argc != 2) {
		fprintf(stderr, "Zla liczba argumentow\n");
		exit(EXIT_FAILURE);
	}
	nrows = atoi(argv[1]);
	//printf("Wczytana liczba wierszy to %d\n", nrows);
	
	//printf("Inicjacja rows\n");
	rows = initTable(nrows);
	
	//printf("Inicjacja tmp_pass\n");
	tmp_pass = (char **) malloc(nrows * sizeof(char *));
	//printf("Inicjacja tmp_hash\n");
	tmp_hash = (char **) malloc(nrows * sizeof(char *));
	for (i = 0; i < nrows; i++) {
		//printf("Inicjacja tmp_pass[%d]\n", i);
		tmp_pass[i] = (char *) malloc(PASS_LENGTH * sizeof(char));
		for (j = 0; j < PASS_LENGTH; j++) 
			tmp_pass[i][j] = rows[i].first_pass[j];
		//printf("tmp_pass[%d] = %s", i, tmp_pass[i]);
		
		//printf("Inicjacja tmp_hash[%d]\n", i);
		tmp_hash[i] = (char *) malloc(HASH_LEN * sizeof(char));		
	}	

	//printf("Początek głównej pętli\n");
	for (i = 0; i < ROUNDS; i++) {
		//printf("Obliczanie hasha każdego wiersza\n");
		hash_rows(tmp_pass, tmp_hash, nrows);
		//for (j = 0; j < nrows; j++) {
			//printf("tmp_hash[%d] = %s\n", j, tmp_hash[j]);
		//}
		if (i != ROUNDS - 1) {
			//printf("Redukcja każdego hasha\n");
			reduct_rows(tmp_pass, tmp_hash, nrows);
			//for (j = 0; j < nrows; j++) {
				//printf("tmp_pass[%d] = %s\n", j, tmp_pass[j]);
			//}
		}
		//printf("Koniec rundy nr %d\n\n", i);
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

	return 0;
}
