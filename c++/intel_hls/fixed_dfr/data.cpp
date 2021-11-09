#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <fstream>

#include "HLS/hls.h"
#include "HLS/math.h"
#include "HLS/hls_float.h"
#include "HLS/hls_float_math.h"

#include "dfr.h"

// narma10 inputs
FPhalf* narma10_inputs(int size){

    FPhalf* inputs = (FPhalf*) malloc(sizeof(FPhalf)*size);

    for (int i = 0; i < size; i++){
        FPhalf u = 0.5 * FPhalf(static_cast<float>(rand()) / static_cast<float>(RAND_MAX));
        inputs[i] = u;

        // printf("u[%d] = %f\n",i,u);
    }

    return inputs;
}

// narma10 outputs
FPhalf* narma10_outputs(FPhalf* inputs, int size){

    FPhalf* outputs = (FPhalf*) malloc(sizeof(FPhalf)*size);

    for (int i = 0; i < 10; i++){
        outputs[i] = 0;
    }

    // determine output from index 10 to size - 1
    for (int i = 9; i < size - 1; i++){

        // calculate sum of last 10 outputs
        FPhalf sum = 0;
        for (int j = 0; j < 10; j++){
            sum = sum + outputs[i - j];
        }

        outputs[i + 1] = 0.3 * outputs[i] + 0.05 * outputs[i] * sum + 1.5 * inputs[i] * inputs[i - 9] + 0.1;

        // printf("outputs[%d] = %f\n",i+1,outputs[i + 1]);
    }

    return outputs;
}

FPhalf* read_FPhalf_vector_from_file(char const* fileName, int size){
    FPhalf* outputs = (FPhalf*)  malloc(sizeof(FPhalf)*size);

    std::ifstream inFile;
    inFile.open(fileName);

    std::string line;
    int i = 0;
    if (inFile.is_open()){
        while ( getline (inFile,line) && i < size){
            outputs[i++] = std::stof(line);
            // printf("W[%d] = %d\n",i - 1,W[i - 1]);            
        }
        inFile.close();
    }


    return outputs;
}