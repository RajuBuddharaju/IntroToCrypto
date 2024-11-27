def matrix_order(C):
    """
    Compute the order of a matrix modulo 2.

    Args:
        C (Matrix): The input matrix defined over a finite field (e.g., GF(2)).

    Returns:
        int: The order of the matrix modulo 2, i.e., the smallest positive integer k such that C^k = I,
             where I is the identity matrix. Returns -1 if no finite order is found.
    """
    
    # Create the identity matrix of the same size as C
    I = Matrix.identity(C.nrows())
    
    # Initialize variables
    order = 1  # Start with an assumed order of 1
    power = C  # Initialize the power of the matrix to the matrix itself
    
    # Compute the order by multiplying the matrix by itself until it equals the identity matrix
    while power != I:
        power = power * C
        order += 1

    # Return the computed order if the loop exits correctly (power equals I)
    if power == I:
        return order
    else:
        # Return -1 to indicate no finite order was found (this shouldn't happen if C is a valid matrix over GF(2))
        return -1

# Define the finite field GF(2)
F = GF(2)

# Define the first matrix C1 over GF(2)
# This is an 8x8 matrix defined with specific values
C1 = Matrix(F, 8, 8, [
    0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 1,
    0, 1, 0, 0, 0, 0, 0, 1,
    0, 0, 1, 0, 0, 0, 0, 0,
    0, 0, 0, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 1, 0, 0, 1,
    0, 0, 0, 0, 0, 1, 0, 0,
    0, 0, 0, 0, 0, 0, 1, 0,
])

# Compute and print the order of the first matrix C1
order1 = matrix_order(C1)
print("The order of the matrix C1:")
print(order1)

# Define the second matrix C2 over GF(2)
# This is a 6x6 matrix with different specific values
C2 = Matrix(F, 6, 6, [
    0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0,
    0, 1, 0, 0, 0, 0,
    0, 0, 1, 0, 0, 1,
    0, 0, 0, 1, 0, 0,
    0, 0, 0, 0, 1, 0,
])

# Compute and print the order of the second matrix C2
order2 = matrix_order(C2)
print("The order of the matrix C2:")
print(order2)

# Define a polynomial ring over GF(2) with the generator 'x'
R = PolynomialRing(F, 'x')
x = R.gen()  # Generator for the polynomial ring

# Define the first polynomial f1 in GF(2)[x]
f1 = x^8 + x^5 + x^2 + x + 1

# Factorize the polynomial f1 over GF(2)
factors1 = f1.factor()

# Print the factorization of f1
print(f"The factorization of {f1} over GF(2) is:")
print(factors1)

# Compute and print the order of matrices associated with each factor of f1

# First factor converted into a companion matrix F1 (2x2)
F1 = Matrix(F, 2, 2, [
    0, 1,
    1, 1,
])
order_F1 = matrix_order(F1)
print("The order of the first factor:")
print(order_F1)

# Second factor converted into a companion matrix F2 (6x6)
F2 = Matrix(F, 6, 6, [
    0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0,
    0, 1, 0, 0, 0, 0,
    0, 0, 1, 0, 0, 0,
    0, 0, 0, 1, 0, 0,
    0, 0, 0, 0, 1, 1,
])
order_F2 = matrix_order(F2)
print("The order of the second factor:")
print(order_F2)

# Define the second polynomial f2 in GF(2)[x]
f2 = x^6 + x^3 + 1

# Factorize the polynomial f2 over GF(2)
factors2 = f2.factor()

# Print the factorization of f2
print(f"The factorization of {f2} over GF(2) is:")
print(factors2)

# Since f2 is irreducible, its order must be determined as a whole
print("The polynomial is irreducible, so we cannot factorize further, and the order of the factors is the same.")
