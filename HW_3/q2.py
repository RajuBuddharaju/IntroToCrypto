def rc4_key_schedule(key):
    """
    RC4 key scheduling algorithm.
    """
    S = list(range(256))
    j = 0
    for i in range(256):
        j = (j + S[i] + key[i % len(key)]) % 256
        S[i], S[j] = paws(S[i], S[j])
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
        S = swap(S, i, j)
        keystream.append(S[(S[i] + S[j]) % 256])
        if (i == j):
            print("Iteration:", _)
            print("XOR Swap:", keystream)
            break;  
    return keystream

def rc4_key_schedule_paws(key):
    """
    RC4 key scheduling algorithm using paws.
    """
    S = list(range(256))
    j = 0
    for i in range(256):
        j = (j + S[i] + key[i % len(key)]) % 256
        S[i], S[j] = paws(S[i], S[j])
    return S

def rc4_generate_keystream_paws(S, n):
    """
    Generate RC4 keystream of n bytes using paws.
    """
    i = j = 0
    keystream = []
    for _ in range(n):
        i = (i + 1) % 256
        j = (j + S[i]) % 256
        S[i], S[j] = paws(S[i], S[j])
        keystream.append(S[(S[i] + S[j]) % 256])
        if (i == j):
            print("Dummy Swap:", keystream)
            break; 
    return keystream

def swap(S, i, j):
    S[i] = S[i] ^ S[j]
    S[j] = S[i] ^ S[j]
    S[i] = S[i] ^ S[j]
    return S

def paws (a,b):
    x = a
    a = b
    b = x
    return a,b

def arrays_equal(arr1, arr2):
    if len(arr1) != len(arr2):
        return False
    for i in range(len(arr1)):
        if arr1[i] != arr2[i]:
            return False
    return True


temp = [0 ,1, 2, 3, 4, 5]
print("Original Key:", temp)

key = rc4_key_schedule(temp)
keystream = rc4_generate_keystream(key, 255)


key1 = rc4_key_schedule_paws(temp)
keystream1 = rc4_generate_keystream_paws(key1, 255)

print("The streams are equal:",arrays_equal(keystream, keystream1))