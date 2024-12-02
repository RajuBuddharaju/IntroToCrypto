import multiprocessing

def rc4_key_schedule(key):
    """
    RC4 key scheduling algorithm.
    """
    S = list(range(256))
    j = 0
    for i in range(256):
        j = (j + S[i] + key[i % len(key)]) % 256
        S[i], S[j] = S[j], S[i]
    return S

def rc4_generate_keystream(S, n):
    """
    Generate RC4 keystream of n bytes.
    """
    i = j = 0
    keystream = []
    for _ in range(n):
        i = (i + 1) % 256
        j = (j + S[i]) % 256
        S[i], S[j] = S[j], S[i]
        keystream.append(S[(S[i] + S[j]) % 256])
    return keystream

def brute_force_chunk(start, end, target_keystream, key_prefix, worker_id):
    """
    Brute force RC4 for a chunk of keys with intermediate outputs.
    """
    total_keys_tested = 0
    for k1 in range(start, end):
        for k2 in range(256):
            for k3 in range(256):
                for k4 in range(256):
                    key = key_prefix + [k1, k2, k3, k4]
                    total_keys_tested += 1
                    S = rc4_key_schedule(key)
                    keystream = rc4_generate_keystream(S, len(target_keystream))
                    
                    # Print intermediate process every 100,000 keys
                    if total_keys_tested % 100000 == 0:
                        print(f"Worker {worker_id}: Keys tested: {total_keys_tested} (Last key: {key}, Keystream: {keystream[:10]})")
                    
                    if keystream == target_keystream:
                        print(f"Worker {worker_id}: Found matching key: {key}")
                        return key
    print(f"Worker {worker_id}: Finished testing keys. No match found.")
    return None

def parallel_brute_force(target_keystream):
    """
    Parallelized brute force across multiple cores with intermediate outputs.
    """
    key_prefix = [80]  # First byte is known
    num_cores = multiprocessing.cpu_count() - 3  # Reserve 3 cores for other tasks
    chunk_size = 256 // num_cores  # Divide key[1] space into chunks

    processes = []
    results = multiprocessing.Queue()

    # Spawn a process for each chunk
    for i in range(num_cores):
        start = i * chunk_size
        end = (i + 1) * chunk_size
        process = multiprocessing.Process(
            target=lambda q, s, e, w_id: q.put(brute_force_chunk(s, e, target_keystream, key_prefix, w_id)),
            args=(results, start, end, i)
        )
        processes.append(process)
        process.start()

    # Collect results
    for process in processes:
        process.join()

    # Check results
    while not results.empty():
        result = results.get()
        if result:
            return result

    return None


# Run the parallel brute force
if __name__ == "__main__":
    target_keystream = [130, 189, 254, 192, 238, 132, 216, 132, 82, 173]
    print("Starting parallel brute force...")
    key = parallel_brute_force(target_keystream)
    if key:
        print("Found key:", key)
    else:
        print("No key matched the target keystream.")
