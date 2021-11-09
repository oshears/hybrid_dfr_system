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
DFR_FP* narma10_inputs(int size){

    DFR_FP* inputs = (DFR_FP*) malloc(sizeof(DFR_FP)*size);

    for (int i = 0; i < size; i++){
        DFR_FP u = 0.5 * DFR_FP(static_cast<float>(rand()) / static_cast<float>(RAND_MAX));
        inputs[i] = u;

        // printf("u[%d] = %f\n",i,u);
    }

    return inputs;
}

// narma10 outputs
DFR_FP* narma10_outputs(DFR_FP* inputs, int size){

    DFR_FP* outputs = (DFR_FP*) malloc(sizeof(DFR_FP)*size);

    for (int i = 0; i < 10; i++){
        outputs[i] = 0;
    }

    // determine output from index 10 to size - 1
    for (int i = 9; i < size - 1; i++){

        // calculate sum of last 10 outputs
        DFR_FP sum = 0;
        for (int j = 0; j < 10; j++){
            sum = sum + outputs[i - j];
        }

        outputs[i + 1] = 0.3 * outputs[i] + 0.05 * outputs[i] * sum + 1.5 * inputs[i] * inputs[i - 9] + 0.1;

        // printf("outputs[%d] = %f\n",i+1,outputs[i + 1]);
    }

    return outputs;
}

DFR_FP* read_DFR_FP_vector_from_file(char const* fileName, int size){
    DFR_FP* outputs = (DFR_FP*)  malloc(sizeof(DFR_FP)*size);

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