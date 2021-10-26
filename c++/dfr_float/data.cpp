#include <stdio.h>
#include <stdlib.h>


#include <iostream>
#include <fstream>

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

float* read_spectrum_inputs(int antenna_count, int snr){

    int num_samples = 6102;

    float* inputs = (float*)  malloc(sizeof(float)*num_samples);

    std::string spectrumFileName = "./spectrum_data/spectrum_-" + std::to_string(snr) + "_db_" + std::to_string(antenna_count) + "_ant.csv";
    
    printf("Reading from: ");
    printf(spectrumFileName.c_str());
    printf("\n");

    std::ifstream spectrumFile;
    spectrumFile.open(spectrumFileName.c_str());

    std::string line;
    int i = 0;
    if (spectrumFile.is_open()){
        while ( getline (spectrumFile,line) && i < num_samples){
            std::string input_str = line.substr(0,line.find(","));
            
            inputs[i++] = std::stof(input_str);
            // printf("inputs[%d] = %f\n",i - 1,inputs[i - 1]);            
        }
        spectrumFile.close();
    }


    return inputs;

}

float* read_spectrum_outputs(int antenna_count, int snr){

    int num_samples = 6102;

    float* outputs = (float*)  malloc(sizeof(float)*num_samples);

    std::string spectrumFileName = "./spectrum_data/spectrum_-" + std::to_string(snr) + "_db_" + std::to_string(antenna_count) + "_ant.csv";
    
    printf("Reading from: ");
    printf(spectrumFileName.c_str());
    printf("\n");

    std::ifstream spectrumFile;
    spectrumFile.open(spectrumFileName.c_str());

    std::string line;
    int i = 0;
    if (spectrumFile.is_open()){
        while ( getline (spectrumFile,line) && i < num_samples){
            std::string output_str = line.substr(line.find(",")+1);

            outputs[i++] = std::stof(output_str);
            // printf("outputs[%d] = %f\n",i - 1,outputs[i - 1]);            
        }
        spectrumFile.close();
    }


    return outputs;

}



