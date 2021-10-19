#include <stdio.h>
#include <stdlib.h>
#include <cmath>

#include "dfr.h"

//mackey glass function
float mackey_glass(float x){

    float C = 1.33;
    float b = 0.4;
    return (C * x) / (1 + b * x);

    // float C = 2;
    // float b = 2.1;
    // float p = 10;

    // float a = 0.8;
    // float c = 0.2;

    // return (C * x) / (a + c * pow(b * x, p) );

}

// generate mask of random values of -0.1 or 0.1
float* generate_mask(int size){
	
    float* mask = (float*) malloc(sizeof(float)*size);


    for(int i = 0; i < size; i++){
        mask[i] = (rand() & 0x1) ? 0.1 : -0.1;
    }

    return mask;
}

// generate random weight matrix in range [-1,1]
float* generate_weights(int size){

    float* weights = (float*) malloc(sizeof(float)*size);

    for(int i = 0; i < size; i++){
        weights[i] = (2 * ( static_cast<float>(rand()) / static_cast<float>(RAND_MAX) ) - 1 ) * 16;
    
        // printf("W[%d] = %f\n",i,weights[i]);
    }
    return weights;
}

// get sub-vector from specified indexes
float* get_vector_indexes(float* vector, int idx_0, int idx_1){

    float* new_vector = (float*) malloc(sizeof(float) * (idx_1 - idx_0));

    int j = 0;
    for(int i = idx_0; i < idx_1; i++) new_vector[j++] = vector[i];

    return new_vector;
}