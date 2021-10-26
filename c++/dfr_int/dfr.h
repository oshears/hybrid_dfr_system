#include <stdio.h>
#include <stdlib.h>

//mackey glass function
float mackey_glass(float x);

// narma10 inputs
float* narma10_inputs(int size);

// narma10 outputs
float* narma10_outputs(float* inputs, int size);

// generate random floating point number
float get_random_float();

// generate mask of random values of -0.1 or 0.1
float* generate_mask(int size);

// generate mask of random values from low to high with a given size
float* generate_mask_range(float low, float high, int size);

// generate random weight matrix in range [-1,1]
float* generate_weights(int size);

// get sub-vector from specified indexes
float* get_vector_indexes(float* vector, int idx_0, int idx_1);

// Frobenius norm
float norm(float* x, int size);

// calculate kian's nrmse
float get_nrmse(float* y_hat, float* y, int size);

// calculate mean squared error
float get_mse(float* y_hat, float* y, int size);

// test area
void dfr_batch_gd_test();
void dfr_batch_sgd_test();