#include <stdio.h>
#include <stdlib.h>
#include <cmath>

#include "dfr.h"

// get sub-vector from specified indexes
float* get_vector_indexes(float* vector, int idx_0, int idx_1){

    float* new_vector = (float*) malloc(sizeof(float) * (idx_1 - idx_0));

    int j = 0;
    for(int i = idx_0; i < idx_1; i++) new_vector[j++] = vector[i];

    return new_vector;
}