#include <stdio.h>
#include <stdlib.h>

#include "HLS/hls.h"
#include "HLS/math.h"
#include "HLS/ac_fixed.h"
#include "HLS/ac_fixed_math.h"

#include "dfr.h"

using namespace ihc;

// get sub-vector from specified indexes
FixedPoint* get_vector_indexes(FixedPoint* vector, int idx_0, int idx_1){

    FixedPoint* new_vector = (FixedPoint*) malloc(sizeof(FixedPoint) * (idx_1 - idx_0));

    int j = 0;
    for(int i = idx_0; i < idx_1; i++) new_vector[j++] = vector[i];

    return new_vector;
}