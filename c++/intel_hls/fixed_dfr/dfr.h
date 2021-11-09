#include <stdio.h>
#include <stdlib.h>

#include "HLS/hls.h"
#include "HLS/math.h"
#include "HLS/hls_float.h"
#include "HLS/hls_float_math.h"

using namespace ihc;

//mackey glass function
FPhalf mackey_glass(FPhalf x);

// narma10 inputs
FPhalf* narma10_inputs(int size);

// narma10 outputs
FPhalf* narma10_outputs(FPhalf* inputs, int size);

// Frobenius norm
FPhalf norm(FPhalf x);
FPhalf norm(FPhalf* x, int size);

// calculate kian's nrmse
FPhalf get_nrmse(FPhalf* y_hat, FPhalf* y, int size);

// calculate mean squared error
FPhalf get_mse(FPhalf* y_hat, FPhalf* y, int size);

// get sub-vector from specified indexes
FPhalf* get_vector_indexes(FPhalf* vector, int idx_0, int idx_1);

// read data from file
FPhalf* read_FPhalf_vector_from_file(char const* fileName, int size);


