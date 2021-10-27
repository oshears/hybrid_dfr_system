#include <stdio.h>
#include <stdlib.h>
#include <cmath>

#include "dfr.h"

//mackey glass function
int mackey_glass(int x){

    int C = 1.33;
    int b = 0.4;

    float x_scaled = x / __INT16_MAX__;
    float result = (C * x) / (1 + b * x);
    int int_result = result * __INT16_MAX__;

    return int_result;
}

// generate random floating point number
float get_random_float(){
    return ( static_cast<float>(rand()) / static_cast<float>(RAND_MAX) );
}

// generate mask of random values of -0.1 or 0.1
float* generate_mask(int size){
	
    float* mask = (float*) malloc(sizeof(float)*size);


    for(int i = 0; i < size; i++){
        mask[i] = (rand() & 0x1) ? 0.1 : -0.1;
    }

    return mask;
}

// generate mask of random values from low to high with a given size
float* generate_mask_range(float low, float high, int size){
	
    float* mask = (float*) malloc(sizeof(float)*size);


    for(int i = 0; i < size; i++){
        mask[i] = (get_random_float() * (high - low)) + low;

        // printf("M[%d] = %f\n",i,mask[i]);
    }

    return mask;
}

// generate random weight matrix in range [-1,1]
float* generate_weights(int size){

    float* weights = (float*) malloc(sizeof(float)*size);

    for(int i = 0; i < size; i++){
        weights[i] = (2 * get_random_float() - 1 );
    
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

// generate mask of random values of -0.1 or 0.1
int16_t* generate_mask_int(int size){
	
    int16_t* mask = (int16_t*) malloc(sizeof(int16_t)*size);


    for(int i = 0; i < size; i++){
        mask[i] = (rand() & 0x1) ? 10 : -10;
    }

    return mask;
}

// generate random weight matrix in range [-1,1]
int16_t* generate_weights_int(int size){

    int16_t* weights = (int16_t*) malloc(sizeof(int16_t)*size);

    for(int i = 0; i < size; i++){
        weights[i] = (2 * get_random_float() - 1 ) * __INT16_MAX__;
    
        // printf("W[%d] = %f\n",i,weights[i]);
    }
    return weights;
}

// get sub-vector from specified indexes
int16_t* get_vector_indexes(int16_t* vector, int idx_0, int idx_1){

    int16_t* new_vector = (int16_t*) malloc(sizeof(int) * (idx_1 - idx_0));

    int j = 0;
    for(int i = idx_0; i < idx_1; i++) new_vector[j++] = vector[i];

    return new_vector;
}

// float vector to int vector
int16_t* float_to_int_vector(float* vector, int size){
    int16_t* new_vector = (int16_t*) malloc(sizeof(int16_t));

    for(int i = 0; i < size; i++) new_vector[i] = vector[i] * __INT16_MAX__;

    return new_vector;
}