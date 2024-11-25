
def matrix_order_mod2(C):
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

# Function to compute the companion matrix of a polynomial
def companion_matrix(poly):
    """
    Construct the companion matrix for a given monic polynomial over GF(2).
    
    Args:
        poly (Polynomial): The polynomial in GF(2)[x].
    
    Returns:
        Matrix: The companion matrix.
    """
    coeffs = poly.coefficients(sparse=False)  # Get coefficients [a_0, ..., a_n]
    degree = poly.degree()
    
    # Create an (n x n) companion matrix
    rows = []
    for i in range(degree):
        row = [0] * degree
        if i < degree - 1:
            row[i + 1] = 1  # 1 on the superdiagonal
        else:
            row = [F(c) for c in coeffs[:-1]]  # Last row is the coefficients
        rows.append(row)
    
    return Matrix(F, rows)

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
order1 = matrix_order_mod2(C1)

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

order2 = matrix_order_mod2(C2)

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

print("The orders of the companion matrices are:")
# Convert each factor into a companion matrix
for factor, multiplicity in factors1:
    if multiplicity == 1:  # Only process factors appearing once
        C = companion_matrix(factor)
        print(C)
        print(matrix_order_mod2(C))

# Define a polynomial 2
f2 = x^6 + x^3 + 1

# Factorize the polynomial 2
factors2 = f2.factor()

# Print the result for polynomial 2
print(f"The factorization of {f2} over GF(2) is:")
print(factors2)

print("The orders of the companion matrices are:")
# Convert each factor into a companion matrix
for factor, multiplicity in factors2:
    if multiplicity == 1:  # Only process factors appearing once
        C = companion_matrix(factor)
        print(matrix_order_mod2(C))






