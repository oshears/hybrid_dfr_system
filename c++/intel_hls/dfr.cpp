//  Copyright (c) 2021 Intel Corporation                                  
//  SPDX-License-Identifier: MIT                                          

#include "HLS/hls.h"
#include "HLS/math.h"
#include <stdio.h>

// #include <cmath>

#include "dfr.h"

using namespace ihc;

float mackey_glass(float x){

    float C = 2;
    float b = 2.1;
    float p = 10;
    float a = 0.8;
    float c = 0.2;

    return (C * x) / (a + c * pow(b * x, p) );

}

component float dfr(float sample) {

  // dfr parameters
  constexpr int N = 50;
  constexpr int LAST_NODE = N - 1;
  constexpr float gamma = 0.5;
  constexpr float eta = 0.4;

  static float reservoir[N] = {};

  // process sample through reservoir

  // track output
  float dfr_out = 0;
  
  // loop through each masked input subsample
  for(int node_idx = 0; node_idx < N; node_idx++){
    
    // calculate next node value based on current subsample
    float masked_sample_i = MASK[node_idx] * sample;
    float mg_in = gamma * masked_sample_i + eta * reservoir[LAST_NODE];
    float mg_out = mackey_glass(mg_in);

    // update reservoir  
    for(int i = LAST_NODE; i > 0; i--) reservoir[i] = reservoir[i - 1];
    reservoir[0] = mg_out;

    // calculate output
    dfr_out += W[LAST_NODE - node_idx] * mg_out;
  }

  return dfr_out;
}

int main() {

  // define sample counts
  constexpr int NUM_INIT_SAMPLES = 10;
  constexpr int NUM_TEST_SAMPLES = 1;
  constexpr int NUM_TOTAL_SAMPLES = NUM_INIT_SAMPLES + NUM_TEST_SAMPLES;

  // generate narma10 inputs and outputs
  printf("Creating input and output data vectors...\n");
  float* u = narma10_inputs(NUM_TOTAL_SAMPLES);
  float* y = narma10_outputs(u,NUM_TOTAL_SAMPLES);
  // char const* narma10_input_file = "./data/float_input_data.txt";
  // float* u = read_float_vector_from_file(narma10_input_file,NUM_TOTAL_SAMPLES);
  // char const* narma10_output_file = "./data/float_output_data.txt";
  // float* y = read_float_vector_from_file(narma10_output_file,NUM_TOTAL_SAMPLES);


  // get test data vectors
  printf("Parsing test input and output vectors...\n");
  float* u_test = get_vector_indexes(u,NUM_INIT_SAMPLES,NUM_TOTAL_SAMPLES);
  float* y_test = get_vector_indexes(y,NUM_INIT_SAMPLES,NUM_TOTAL_SAMPLES);

  // store test data outputs
  float y_hat_test[NUM_TEST_SAMPLES];

  // reservoir initialization
  printf("Initializing Reservoir...\n");
  for(unsigned int i = 0; i < NUM_INIT_SAMPLES; i++) ihc_hls_enqueue_noret(&dfr,u[i]);
  ihc_hls_component_run_all(dfr);

  // reservoir test
  printf("Testing DFR...\n");
  // for(unsigned int i = 0; i < NUM_TEST_SAMPLES; i++) ihc_hls_enqueue(&y_hat_test[i], &dfr,u_test[i]);
  for(unsigned int i = 0; i < NUM_TEST_SAMPLES; i++) ihc_hls_enqueue(&y_hat_test[i], &dfr,0.1598408181413325);
  ihc_hls_component_run_all(dfr);

  // calculate the NRMSE of the predicted output
  float nrmse = get_nrmse(y_hat_test,y_test,NUM_TEST_SAMPLES);
  printf("Test NRMSE\t= %f\n",nrmse);

  // calculate the MSE of the predicted output
  float mse = get_mse(y_hat_test,y,NUM_TEST_SAMPLES);
  printf("Test MSE\t= %f\n",mse);

  return 0;

}
