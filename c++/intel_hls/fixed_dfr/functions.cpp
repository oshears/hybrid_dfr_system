#include <stdio.h>
#include <stdlib.h>

#include "HLS/hls.h"
#include "HLS/math.h"
#include "HLS/hls_float.h"
#include "HLS/hls_float_math.h"

#include "dfr.h"

using namespace ihc;

// get sub-vector from specified indexes
FPhalf* get_vector_indexes(FPhalf* vector, int idx_0, int idx_1){

    FPhalf* new_vector = (FPhalf*) malloc(sizeof(FPhalf) * (idx_1 - idx_0));

    int j = 0;
    for(int i = idx_0; i < idx_1; i++) new_vector[j++] = vector[i];

    return new_vector;
}