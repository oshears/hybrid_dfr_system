#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "dfr.h"

//mackey glass function
float mackey_glass(float x){

    float C = 1.33;
    float b = 0.4;

    return (C * x) / (1 + b * x);
}

// generate mask of random values of -0.1 or 0.1
float* generate_mask(int size){
	
    float* mask = (float*) malloc(sizeof(float)*size);


    for(int i = 0; i < size; i++){
        int random = rand();
        mask[i] = (random & 1 == 0) ? 0.1 : -0.1;
    }

    return mask;
}

// generate random weight matrix in range [-1,1]
float* generate_weights(int size){

    float* weights = (float*) malloc(sizeof(float)*size);

    for(int i = 0; i < size; i++){
        weights[i] = 2 * ( static_cast<float>(rand()) / static_cast<float>(RAND_MAX) ) - 1;
    }
    return weights;
}