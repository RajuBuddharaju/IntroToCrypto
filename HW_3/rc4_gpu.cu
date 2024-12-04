#include <cuda_runtime.h>
#include <iostream>

#define TARGET_KEYSTREAM_SIZE 10
#define REPORT_INTERVAL 1000000

__device__ void rc4_key_schedule(unsigned char *key, int key_len, unsigned char *S) {
    int i, j = 0;
    for (i = 0; i < 256; i++) S[i] = i;
    for (i = 0; i < 256; i++) {
        j = (j + S[i] + key[i % key_len]) % 256;
        unsigned char temp = S[i];
        S[i] = S[j];
        S[j] = temp;
    }
}

__device__ void rc4_generate_keystream(unsigned char *S, int n, unsigned char *keystream) {
    int i = 0, j = 0;
    for (int t = 0; t < n; t++) {
        i = (i + 1) % 256;
        j = (j + S[i]) % 256;
        unsigned char temp = S[i];
        S[i] = S[j];
        S[j] = temp;
        keystream[t] = S[(S[i] + S[j]) % 256];
    }
}

__global__ void rc4_brute_force_kernel(unsigned char *target_keystream, unsigned char *key_found, int *found, int interval) {
    unsigned char key[5] = {80, 0, 0, 0, 0}; // Known first byte
    unsigned char S[256];
    unsigned char keystream[TARGET_KEYSTREAM_SIZE];

    // Calculate the key based on the thread ID
    int thread_id = blockIdx.x * blockDim.x + threadIdx.x;
    key[1] = (thread_id >> 16) & 0xFF;
    key[2] = (thread_id >> 8) & 0xFF;
    key[3] = thread_id & 0xFF;

    // Periodically print progress
    if (thread_id % interval == 0) {
        printf("Thread %d testing key: [%d, %d, %d, %d, %d]\n",
               thread_id, key[0], key[1], key[2], key[3], key[4]);
    }

    // Perform RC4 key scheduling and keystream generation
    rc4_key_schedule(key, 5, S);
    rc4_generate_keystream(S, TARGET_KEYSTREAM_SIZE, keystream);

    // Check if the keystream matches the target
    bool match = true;
    for (int i = 0; i < TARGET_KEYSTREAM_SIZE; i++) {
        if (keystream[i] != target_keystream[i]) {
            match = false;
            break;
        }
    }

    // If a match is found, store the key and set the found flag
    if (match && atomicExch(found, 1) == 0) {
        for (int i = 0; i < 5; i++) key_found[i] = key[i];
        printf("Thread %d found matching key: [%d, %d, %d, %d, %d]\n",
               thread_id, key[0], key[1], key[2], key[3], key[4]);
    }
}

int main() {
    unsigned char target_keystream[TARGET_KEYSTREAM_SIZE] = {130, 189, 254, 192, 238, 132, 216, 132, 82, 173};
    unsigned char *d_target_keystream, *d_key_found;
    int *d_found;
    unsigned char h_key_found[5] = {0};
    int h_found = 0;

    // Allocate memory on the GPU
    cudaMalloc((void **)&d_target_keystream, TARGET_KEYSTREAM_SIZE * sizeof(unsigned char));
    cudaMalloc((void **)&d_key_found, 5 * sizeof(unsigned char));
    cudaMalloc((void **)&d_found, sizeof(int));

    // Copy the target keystream to the GPU
    cudaMemcpy(d_target_keystream, target_keystream, TARGET_KEYSTREAM_SIZE * sizeof(unsigned char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_found, &h_found, sizeof(int), cudaMemcpyHostToDevice);

    // Launch the kernel
    int threads_per_block = 256;
    int num_blocks = (256 * 256 * 256 + threads_per_block - 1) / threads_per_block;
    std::cout << "Launching " << num_blocks << " blocks with " << threads_per_block << " threads per block." << std::endl;
    rc4_brute_force_kernel<<<num_blocks, threads_per_block>>>(d_target_keystream, d_key_found, d_found, REPORT_INTERVAL);

    // Copy the result back to the host
    cudaMemcpy(&h_found, d_found, sizeof(int), cudaMemcpyDeviceToHost);
    cudaMemcpy(h_key_found, d_key_found, 5 * sizeof(unsigned char), cudaMemcpyDeviceToHost);

    // Check if a key was found
    if (h_found) {
        std::cout << "Key found: ";
        for (int i = 0; i < 5; i++) std::cout << (int)h_key_found[i] << " ";
        std::cout << std::endl;
    } else {
        std::cout << "No matching key found." << std::endl;
    }

    // Free GPU memory
    cudaFree(d_target_keystream);
    cudaFree(d_key_found);
    cudaFree(d_found);

    return 0;
}
