#include <stdio.h>
#include <stdlib.h>
#include <rpc/des_crypt.h>

#include "table_row.h"

#define SEED 42

void initRow(table_row *row) {
	int i;
	for(i = 0; i < PASS_LENGTH; i++) {
		(*row).first_pass[i] = 97 + rand() % 26;
	}
	(*row).rounds = 0;	
}

int main(int argc, char **argv) {
	int rounds = 5, *rounds_d;
	int nrows = 0, *nrows_d;
	table_row *rows, *rows_d;
	int table_size, i;

	if (argc != 2) {
		printf("Zla liczba argumentow\n");
		exit(EXIT_FAILURE);
	}
	srand(SEED);
	nrows = atoi(argv[1]);
	table_size = nrows * sizeof(table_row);
	rows = (table_row *) malloc(table_size);

	//cudaMalloc((void **) &nrows_d, sizeof(int));
	//cudaMemcpy(nrows_d, &nrows, sizeof(int), cudaMemcpyHostToDevice);
	//cudaMalloc((void **) &rounds_d, sizeof(int));
	//cudaMemcpy(rounds_d, &rounds, sizeof(int), cudaMemcpyHostToDevice);
	//cudaMalloc((void **) &rows_d, table_size);

	for (i = 0; i < nrows; i ++) {
		initRow(&rows[i]);
	}
	//cudaDeviceSynchronize();

	//cudaMemcpy(rows, rows_d, table_size, cudaMemcpyDeviceToHost);
	for (i = 0; i < nrows; i++) printf("%s\n", rows[i].first_pass);

	//cudaFree(nrows_d);
	//cudaFree(rounds_d);
	//cudaFree(rows_d);	

	return 0;
}
