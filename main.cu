#include <stdio.h>
#include <stdlib.h>
#include <rpc/des_crypt.h>
#include <pthread.h>
#include <time.h>
#include <crypt.h>

#include "table_row.h"

#define ROUNDS 5
#define SEED time(NULL) 
#define KEY "securit" 
#define ENCRYPT 0

pthread_mutex_t rand_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t encrypt_mutex = PTHREAD_MUTEX_INITIALIZER;

void *initRow(void *r) {
	int i;
	char *alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	table_row *row = (table_row *) r;
	for(i = 0; i < PASS_LENGTH; i++) {
		pthread_mutex_lock(&rand_mutex);
		(*row).first_pass[i] = alphabet[rand() % 62];
		pthread_mutex_unlock(&rand_mutex);
	}
	(*row).rounds = ROUNDS;
	return NULL;	
}

table_row *initTable(int nrows) {
	int i;
	table_row *rows;
	pthread_t *threads;
	int table_size = nrows * sizeof(table_row);
	rows = (table_row *) malloc(table_size);
	threads = (pthread_t *) malloc(nrows * sizeof(pthread_t));
	srand(SEED);

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

	free(threads);
	return rows;
}

void *encrypt_block(void *b) {
	char *block = (char *) b;
	pthread_mutex_lock(&encrypt_mutex);
	encrypt(block, ENCRYPT);
	pthread_mutex_unlock(&encrypt_mutex);

	return NULL;
}

void encrypt_blocks(char **blocks, int n) {
	int i;
	pthread_t *threads;

	threads = (pthread_t *) malloc(n * sizeof(pthread_t));
	for (i = 0; i < n; i++) {
		if (pthread_create(&threads[i], NULL, encrypt_block, (void *) &blocks[i])) {
			fprintf(stderr, "Blad w tworzeniu watkow!\n");
			exit(EXIT_FAILURE);
		}
	}
	for (i = 0; i < n; i++) {
		if (pthread_join(threads[i], NULL)) {
			fprintf(stderr, "Blad podczas zbierania watkow\n");
			exit(EXIT_FAILURE);
		}
	}
#ifdef DEBUG
	printf("Blocki po zaszyfrowaniu\n");
	for (i = 0; i < n; i++) {
		printf("%s\n", blocks[i]);
	}
#endif

	free(threads);
}

void reduct_blocks(char **blocks, int n) {
	
}

int main(int argc, char **argv) {
	int nrows = 0;
	table_row *rows;
	int i;
	char key[PASS_LENGTH] = KEY;
	char **blocks;

	if (argc != 2) {
		printf("Zla liczba argumentow\n");
		exit(EXIT_FAILURE);
	}
	nrows = atoi(argv[1]);
	rows = initTable(nrows);
	des_setparity(key);
	setkey(key);
	blocks = (char **) malloc(nrows * sizeof(char *));

	for (i = 0; i < nrows; i++) {
		blocks[i] = (char *) malloc(PASS_LENGTH * sizeof(char));
		strcpy(blocks[i], rows[i].first_pass);
	}

#ifdef DEBUG
	for (i = 0; i < nrows; i++) {
		printf("%s\n", blocks[i]);
	}

	for (i = 0; i < nrows; i++) {
		printf("%s\n", rows[i].first_pass);
	}
#endif

	for (i = 0; i < ROUNDS; i++) {
		encrypt_blocks(blocks, nrows);
		if (i != ROUNDS - 1) 
			reduct_blocks(blocks, nrows);
	}

	

	free(rows);
	pthread_exit(NULL);

	return 0;
}
