#include "reduction_function.h"

__global__ void reduction(char **pass, char **hash) {
	int index = threadIdx.x;
	int i, j = 0;
	for (i = 0; i < PASS_LENGTH; i++) {
		pass[index][i] = (hash[index][j] % 10) + '0';
		j = (j + 5) % HASH_LEN; 
	}
}

void reduct_rows(char **pass, char **hash, int n) {
	char **d_pass, **d_hash;
	char **d_pass2, **d_hash2;
	int i;	

	d_pass = (char **) malloc(n * sizeof(char *));
	d_hash = (char **) malloc(n * sizeof(char *));

	cudaMalloc((void **) &d_pass2, n * sizeof(char *));
	cudaMalloc((void **) &d_hash2, n * sizeof(char *));
	
	cudaMemcpy(d_pass, d_pass2, n * sizeof(char *), cudaMemcpyDeviceToHost);
	cudaMemcpy(d_hash, d_hash2, n * sizeof(char *), cudaMemcpyDeviceToHost);
	
	for (i = 0; i < n; i++) {
		cudaMalloc((void **) &d_pass[i], PASS_LENGTH * sizeof(char));
		cudaMalloc((void **) &d_hash[i], HASH_LEN * sizeof(char));
		cudaMemcpy(d_pass[i], pass[i], PASS_LENGTH * sizeof(char), cudaMemcpyHostToDevice);
		cudaMemcpy(d_hash[i], hash[i], HASH_LEN * sizeof(char), cudaMemcpyHostToDevice);	
	}
	
	reduction<<<1,n>>>(d_pass, d_hash);

	for (i = 0; i < n; i++) {
		cudaMemcpy(pass[i], d_pass[i], PASS_LENGTH * sizeof(char), cudaMemcpyDeviceToHost);
		cudaMemcpy(hash[i], d_hash[i], HASH_LEN * sizeof(char), cudaMemcpyDeviceToHost);
	}

	for (i = 0; i < n; i++) {
		cudaFree(d_pass[i]);
		cudaFree(d_hash[i]);
	}
	cudaFree(d_pass2);
	cudaFree(d_hash2);
	free(d_pass);
	free(d_hash);
}


