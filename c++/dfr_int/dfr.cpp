#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <fstream>

#include "dfr.h"


int16_t* read_mask_file(int size){
    int16_t* mask = (int16_t*)  malloc(sizeof(float)*size);

    std::ifstream maskFile;
    maskFile.open("./dfr_config/int_mask_data.txt");

    std::string line;
    int i = 0;
    if (maskFile.is_open()){
        while ( getline (maskFile,line) && i < size){
            mask[i++] = std::stoi(line);
            printf("mask[%d] = %d\n",i - 1,mask[i - 1]);            
        }
        maskFile.close();
    }


    return mask;
}

int16_t* read_weight_file(int size){
    int16_t* W = (int16_t*)  malloc(sizeof(float)*size);

    std::ifstream weightFile;
    weightFile.open("./dfr_config/int_weight_data.txt");

    std::string line;
    int i = 0;
    if (weightFile.is_open()){
        while ( getline (weightFile,line) && i < size){
            W[i++] = std::stoi(line);
            printf("W[%d] = %d\n",i - 1,W[i - 1]);            
        }
        weightFile.close();
    }


    return W;
}


int16_t read_input_file(){
    
}

int16_t read_output_file(){
    
}

int main(){

    printf("========== DFR Stochastic Gradient Descent ==========\n");

    // dfr configuration
    int N = 50;
    int LAST_NODE = N - 1;
    int init_samples = 200;
    int test_samples = 1000;
    int total_samples = init_samples + test_samples;
    int gamma = 1;
    int eta = 1;

    // read mask
    int16_t* M = read_mask_file(N);
    int16_t* W = read_weight_file(N);

    // generate input & output data
    float* u = narma10_inputs(total_samples);
    float* y = narma10_outputs(u,total_samples);

    int16_t* u_int = float_to_int_vector(u,total_samples);
    int16_t* y_int = float_to_int_vector(y,total_samples);

    // initialize an empty reservoir
    int16_t X[N];
    for (int i = 0; i < N; i++) X[i] = 0;

    // reservoir initialization
    // loop for init_samples
    for(int k = 0; k < init_samples; k++){

        // process each masked input sample (each theta in tau == each node in N)
        for(int node_idx = 0; node_idx < N; node_idx++){
            
            // calculate current masked input
            int16_t J = M[node_idx] * u_int[k];

            // perform nonlinear transformation on the input data and reservoir feedback
            float mg_out  = mackey_glass(gamma * J + eta * X[LAST_NODE]);
            
            // update node states by shifting each value to the next virtual node
            for(int i = LAST_NODE; i > 0; i--) X[i] = X[i - 1];

            // store the current output in the first virtual node
            X[0] = mg_out;

        }
    }

    // loop from the end of the initialization samples to the end of the test data
    for(int k = test_data_start_idx; k < test_data_end_idx; k++){

        // reset output result
        float dfr_out = 0;

        // process each masked input sample (each theta in tau == each node in N)
        for(int node_idx = 0; node_idx < N; node_idx++){

            if(output_idx < 1){
                // printf("W[%d] = %f\n",node_idx,W[node_idx]);
            }

            // calculated masked input
            float J = M[node_idx] * u[k];

            // perform nonlinear transformation on the input data and reservoir feedback
            float mg_out = mackey_glass(gamma * J + eta * X[LAST_NODE]);
            
            // update node states by shifting each value to the next virtual node
            for(int i = LAST_NODE; i > 0; i--) X[i] = X[i - 1];

            // store the current output in the first virtual node
            X[0] = mg_out;

            // update dfr output calculation (matrix-vector multiplication)
            dfr_out += W[node_idx] * mg_out;

        }

        // store dfr output after the sample has been fully processed
        y_hat_test[output_idx++] = dfr_out;

    }



}