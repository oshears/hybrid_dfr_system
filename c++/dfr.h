#include <stdio.h>
#include <stdlib.h>

//mackey glass function
float mackey_glass(float x);

// narma10 inputs
float* narma10_inputs(int size);

// narma10 outputs
float* narma10_outputs(float* inputs, int size);

// generate mask of random values of -0.1 or 0.1
float* generate_mask(int size);

// generate random weight matrix in range [-1,1]
float* generate_weights(int size);

// Frobenius norm
float norm(float* x, int size);

// calculate kian's nrmse
float get_nrmse(float* y_hat, float* y, int size);