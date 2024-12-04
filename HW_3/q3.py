import multiprocessing
from multiprocessing import Queue

def rc4_key_schedule(key):
    S = list(range(256))
    j = 0
    for i in range(256):
        j = (j + S[i] + key[i % len(key)]) % 256
        S[i], S[j] = S[j], S[i]
    return S

def rc4_generate_keystream(S, n):
    i = j = 0
    keystream = []
    for _ in range(n):
        i = (i + 1) % 256
        j = (j + S[i]) % 256
        S[i], S[j] = S[j], S[i]
        keystream.append(S[(S[i] + S[j]) % 256])
    return keystream

def brute_force_chunk(start, end, target_keystream, key_prefix, worker_id, result_queue, completion_queue):
    total_keys_tested = 0
    for k1 in range(start, end):
        for k2 in range(256):
            for k3 in range(256):
                for k4 in range(256):
                    key = key_prefix + [k1, k2, k3, k4]
                    total_keys_tested += 1
                    S = rc4_key_schedule(key)
                    keystream = rc4_generate_keystream(S, len(target_keystream))
                    
                    # Print progress
                    if total_keys_tested % 1_000_000 == 0:
                        print(f"Worker {worker_id}: Tested {total_keys_tested} keys. Current key: {key}")

                    # Check if the keystream matches
                    if keystream == target_keystream:
                        result_queue.put(key)  # Send result to the main process
                        print(f"Worker {worker_id}: Found matching key: {key}")
                        completion_queue.put(worker_id)  # Indicate this worker is done
                        return  # "Stop" this worker process

    # Indicate this worker has finished its chunk
    completion_queue.put(worker_id)
    result_queue.put(None)  # Indicate no result found in this chunk

# Parallelized brute force across multiple cores
def parallel_brute_force(target_keystream):
    key_prefix = [80]  # First byte is known
    num_cores = multiprocessing.cpu_count() - 3  # Reserve 3 cores for other tasks
    chunk_size = 256 // num_cores  # Divide key[1] space into chunks

    result_queue = Queue()
    completion_queue = Queue()
    processes = []

    # Spawn a process for each chunk
    for i in range(num_cores):
        start = i * chunk_size
        end = (i + 1) * chunk_size
        process = multiprocessing.Process(
            target=brute_force_chunk, 
            args=(start, end, target_keystream, key_prefix, i, result_queue, completion_queue)
        )
        processes.append(process)
        process.start()

    # Wait for results or completion
    found_key = None
    completed_workers = 0

    while completed_workers == 0:
        # Check the result queue
        if not result_queue.empty():
            result = result_queue.get()
            if result is not None:
                found_key = result
                break

        # Check the completion queue
        if not completion_queue.empty():
            worker_id = completion_queue.get()
            completed_workers += 1
            print(f"Worker {worker_id} has completed.") # Terminate all workers

    # Terminate all processes
    for process in processes:
        process.terminate()
        process.join()

    return found_key

# Run the parallel brute force
if __name__ == "__main__":
    target_keystream = [130, 189, 254, 192, 238, 132, 216, 132, 82, 173]
    print("Starting parallel brute force...")
    found_key = parallel_brute_force(target_keystream)

    if found_key:
        # Write the result to a file
        with open("found_key.txt", "w") as f:
            f.write(f"Found key: {found_key}\n")
        print(f"Found key: {found_key}")
    else:
        print("No key matched the target keystream.")
