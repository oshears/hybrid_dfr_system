#include <stdio.h>
#include <stdlib.h>

#include "dfr.h"

// narma10 inputs
float* narma10_inputs(int size){

    float* inputs = (float*) malloc(sizeof(float)*size);

    for (int i = 0; i < size; i++){
        float u = 0.5 * (static_cast<float>(rand()) / static_cast<float>(RAND_MAX));
        inputs[i] = u;

        // printf("u[%d] = %f\n",i,u);
    }

    return inputs;
}

// narma10 outputs
float* narma10_outputs(float* inputs, int size){

    float* outputs = (float*) malloc(sizeof(float)*size);

    for (int i = 0; i < 10; i++){
        outputs[i] = 0;
    }

    // determine output from index 10 to size - 1
    for (int i = 9; i < size - 1; i++){

        // calculate sum of last 10 outputs
        float sum = 0;
        for (int j = 0; j < 10; j++){
            sum = sum + outputs[i - j];
        }

        outputs[i + 1] = 0.3 * outputs[i] + 0.05 * outputs[i] * sum + 1.5 * inputs[i] * inputs[i - 9] + 0.1;

        // printf("outputs[%d] = %f\n",i+1,outputs[i + 1]);
    }

    return outputs;
}



