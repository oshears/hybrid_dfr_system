#include <stdio.h>
#include <stdlib.h>

//mackey glass function
float mackey_glass(float x);

// narma10 inputs
float* narma10_inputs(int size);

// narma10 outputs
float* narma10_outputs(float* inputs, int size);

// Frobenius norm
float norm(float* x, int size);

// calculate kian's nrmse
float get_nrmse(float* y_hat, float* y, int size);

// calculate mean squared error
float get_mse(float* y_hat, float* y, int size);

// get sub-vector from specified indexes
float* get_vector_indexes(float* vector, int idx_0, int idx_1);