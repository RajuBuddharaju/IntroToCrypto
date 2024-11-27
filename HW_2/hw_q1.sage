
def matrix_order(C):
    """
    Compute the order of a matrix modulo 2.

    Args:
        C (Matrix): The input matrix defined over any field.

    Returns:
        int: The order of the matrix modulo 2
    """
    
    # Identity matrix of the same size as C
    I = Matrix.identity(C.nrows())
    
    # Initialize variables
    order = 1
    power = C
    
    # Compute the order
    while power != I:
        power = power * C
        order += 1

    # Return the result
    if power == I:
        return order
    else:
        return -1  # Indicates no finite order found within the iteration limit

# Define the finite field GF(2)
F = GF(2)

# Define a matrix C1
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

# Call the function to compute the order modulo 2
order1 = matrix_order(C1)

# Print the result
print("The order of the matrix C1:")
print(order1)

# Define a matrix C2
C2 = Matrix(F, 6, 6, [
    0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0,
    0, 1, 0, 0, 0, 0,
    0, 0, 1, 0, 0, 1,
    0, 0, 0, 1, 0, 0,
    0, 0, 0, 0, 1, 0,
])

order2 = matrix_order(C2)

# Print the result for C2
print("The order of the matrix C2:")
print(order2)

# Define the polynomial ring over GF(2)
R = PolynomialRing(F, 'x')
x = R.gen()  # Generator of the polynomial ring

# Define a polynomial 1
f1 = x^8 + x^5 + x^2 + x + 1

# Factorize the polynomial 1
factors1 = f1.factor()

# Print the result for polynomial 1
print(f"The factorization of {f1} over GF(2) is:")
print(factors1)

print("The orders of the state matrices are:")
# Convert each factor into a companion matrix
F1 = Matrix(F, 2, 2, [
    0, 1,
    1, 1,
])
order_F1 = matrix_order(F1)
print("The order of the first factor")
print(order_F1)

F2 = Matrix(F, 6, 6, [
    0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0,
    0, 1, 0, 0, 0, 0,
    0, 0, 1, 0, 0, 0,
    0, 0, 0, 1, 0, 1,
    0, 0, 0, 0, 1, 1,
])
order_F2 = matrix_order(F2)
print("The order of the second factor")
print(order_F2)

# Define a polynomial 2
f2 = x^6 + x^3 + 1

# Factorize the polynomial 2
factors2 = f2.factor()

# Print the result for polynomial 2
print(f"The factorization of {f2} over GF(2) is:")
print(factors2) 

print("The polynomial is irreducible, so we cannot factorize so the order of the factors are the same.")






