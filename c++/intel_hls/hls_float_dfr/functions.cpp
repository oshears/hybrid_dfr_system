#include <stdio.h>
#include <stdlib.h>

#include "HLS/hls.h"
#include "HLS/math.h"
#include "HLS/hls_float.h"
#include "HLS/hls_float_math.h"

#include "dfr.h"

using namespace ihc;

// get sub-vector from specified indexes
DFR_FP* get_vector_indexes(DFR_FP* vector, int idx_0, int idx_1){

    DFR_FP* new_vector = (DFR_FP*) malloc(sizeof(DFR_FP) * (idx_1 - idx_0));

    int j = 0;
    for(int i = idx_0; i < idx_1; i++) new_vector[j++] = vector[i];

    return new_vector;
}