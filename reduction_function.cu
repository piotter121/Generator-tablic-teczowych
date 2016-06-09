#include "reduction_function.h"

__global__ void reduction(char **pass, char **hash) {
	int index = threadIdx.x;
	int i, j = 0;
	//printf("Działania w wątku nr %d\n", index);
	//printf("Otrzymane dane to pass[%d] = %s i hash[%d] = %s\n", index, pass[index], index, hash[index]);
	for (i = 0; i < PASS_LENGTH; i++) {
		pass[index][i] = (hash[index][j] % 10) + '0';
		j = (j + 5) % HASH_LEN; 
	}
	//printf("Po redukcji hasha pass[%d] = %s\n", index, pass[index]);
}

void reduct_rows(char **pass, char **hash, int n) {
	char **d_pass, **d_hash;
	char **d_pass2, **d_hash2;
	int i;	

	d_pass = (char **) malloc(n * sizeof(char *));
	d_hash = (char **) malloc(n * sizeof(char *));

	// printf("Przygotowywanie pamęci na karcie graficznej\n");
	// prepare memory on device
	// printf("Malloc dla d_pass2 \n");
	cudaMalloc((void **) &d_pass2, n * sizeof(char *));
	// printf("Malloc dla d_hash2 \n");
	cudaMalloc((void **) &d_hash2, n * sizeof(char *));
	
	cudaMemcpy(d_pass, d_pass2, n * sizeof(char *), cudaMemcpyDeviceToHost);
	cudaMemcpy(d_hash, d_hash2, n * sizeof(char *), cudaMemcpyDeviceToHost);
	
	for (i = 0; i < n; i++) {
		// printf("Malloc dla d_pass[%d]\n", i);
		cudaMalloc((void **) &d_pass[i], PASS_LENGTH * sizeof(char));
		// printf("Malloc dla d_hash[%d]\n", i);
		cudaMalloc((void **) &d_hash[i], HASH_LEN * sizeof(char));
		// printf("Kopiowanie pass[%d] = %s i hash[%d] = %s \n", i, pass[i], i, hash[i]);
		cudaMemcpy(d_pass[i], pass[i], PASS_LENGTH * sizeof(char), cudaMemcpyHostToDevice);
		cudaMemcpy(d_hash[i], hash[i], HASH_LEN * sizeof(char), cudaMemcpyHostToDevice);	
	}
	
	// launch device function
	// printf("Uruchamianie funkcji redukcji na karcie graficznej z %d wątkami\n", n);
	reduction<<<1,n>>>(d_pass, d_hash);

	// copy memory from device to host
	for (i = 0; i < n; i++) {
		// printf("Kopiowanie danych z karty graficznej do pamięci RAM\n");
		cudaMemcpy(pass[i], d_pass[i], PASS_LENGTH * sizeof(char), cudaMemcpyDeviceToHost);
		cudaMemcpy(hash[i], d_hash[i], HASH_LEN * sizeof(char), cudaMemcpyDeviceToHost);
		// printf("Odebrane wartości z karty to pass[%d] = %s i hash[%d] = %s\n", i, pass[i], i, hash[i]);
	}

	// free memory
	for (i = 0; i < n; i++) {
		cudaFree(d_pass[i]);
		cudaFree(d_hash[i]);
	}
	cudaFree(d_pass2);
	cudaFree(d_hash2);
	free(d_pass);
	free(d_hash);
}


