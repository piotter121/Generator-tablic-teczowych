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
	int i;	

	// prepare memory on device
	cudaMalloc((void **) &d_pass, n * sizeof(char *));
	cudaMalloc((void **) &d_hash, n * sizeof(char *));
	for (i = 0; i < n; i++) {
		cudaMalloc((void **) &d_pass[i], PASS_LENGTH * sizeof(char));
		cudaMalloc((void **) &d_hash[i], HASH_LEN * sizeof(char));
		cudaMemcpy(d_pass[i], pass[i], PASS_LENGTH * sizeof(char), cudaMemcpyHostToDevice);
		cudaMemcpy(d_hash[i], hash[i], HASH_LEN * sizeof(char), cudaMemcpyHostToDevice);	
	}
	
	// launch device function
	reduction<<<1,n>>>(d_pass, d_hash);

	// copy memory from device to host
	for (i = 0; i < n; i++) {
		cudaMemcpy(pass[i], d_pass[i], PASS_LENGTH * sizeof(char), cudaMemcpyDeviceToHost);
		cudaMemcpy(hash[i], d_hash[i], HASH_LEN * sizeof(char), cudaMemcpyDeviceToHost);
	}

	// free memory
	cudaFree(d_pass);
	cudaFree(d_hash);
}


