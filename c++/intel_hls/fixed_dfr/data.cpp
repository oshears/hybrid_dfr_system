#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <fstream>

#include "HLS/hls.h"
#include "HLS/math.h"
#include "HLS/ac_fixed.h"
#include "HLS/ac_fixed_math.h"

#include "dfr.h"

// narma10 inputs
FixedPoint* narma10_inputs(int size){

    FixedPoint* inputs = (FixedPoint*) malloc(sizeof(FixedPoint)*size);

    for (int i = 0; i < size; i++){
        FixedPoint u = 0.5 * FixedPoint(static_cast<float>(rand()) / static_cast<float>(RAND_MAX));
        inputs[i] = u;

        // printf("u[%d] = %f\n",i,u);
    }

    return inputs;
}

// narma10 outputs
FixedPoint* narma10_outputs(FixedPoint* inputs, int size){

    FixedPoint* outputs = (FixedPoint*) malloc(sizeof(FixedPoint)*size);

    for (int i = 0; i < 10; i++){
        outputs[i] = 0;
    }

    // determine output from index 10 to size - 1
    for (int i = 9; i < size - 1; i++){

        // calculate sum of last 10 outputs
        FixedPoint sum = 0;
        for (int j = 0; j < 10; j++){
            sum = sum + outputs[i - j];
        }

        outputs[i + 1] = 0.3 * outputs[i] + 0.05 * outputs[i] * sum + 1.5 * inputs[i] * inputs[i - 9] + 0.1;

        // printf("outputs[%d] = %f\n",i+1,outputs[i + 1]);
    }

    return outputs;
}

FixedPoint* read_FixedPoint_vector_from_file(char const* fileName, int size){
    FixedPoint* outputs = (FixedPoint*)  malloc(sizeof(FixedPoint)*size);

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