#include <stdio.h>
#include <stdlib.h>

#include "HLS/hls.h"
#include "HLS/math.h"
#include "HLS/ac_fixed.h"
#include "HLS/ac_fixed_math.h"

using namespace ihc;

using FixedPoint = ac_fixed<20, 10, true, AC_RND, AC_SAT>;

//mackey glass function
FixedPoint mackey_glass(FixedPoint x);

// narma10 inputs
FixedPoint* narma10_inputs(int size);

// narma10 outputs
FixedPoint* narma10_outputs(FixedPoint* inputs, int size);

// Frobenius norm
FixedPoint norm(FixedPoint x);
FixedPoint norm(FixedPoint* x, int size);

// calculate kian's nrmse
FixedPoint get_nrmse(FixedPoint* y_hat, FixedPoint* y, int size);

// calculate mean squared error
FixedPoint get_mse(FixedPoint* y_hat, FixedPoint* y, int size);

// get sub-vector from specified indexes
FixedPoint* get_vector_indexes(FixedPoint* vector, int idx_0, int idx_1);

// read data from file
FixedPoint* read_FixedPoint_vector_from_file(char const* fileName, int size);


