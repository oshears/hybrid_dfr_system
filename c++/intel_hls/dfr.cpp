//  Copyright (c) 2021 Intel Corporation                                  
//  SPDX-License-Identifier: MIT                                          

#include "HLS/hls.h"
#include <stdio.h>

#include <cmath>

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

  static float reservoir[N];

  // mask definition
  float mask[N];
  for(int mask_idx = 0; mask_idx < N; mask_idx++) mask[mask_idx] = 1;

  // weight definition
  float W[N];
  for(int weight_idx = 0; weight_idx < N; weight_idx++) W[weight_idx] = 1;

  // initialize reservoir
  for(int node_idx = 0; node_idx < N; node_idx++) reservoir[node_idx] = 0;

  // process sample through reservoir

  // track output
  float dfr_out = 0;
  
  // loop through each masked input subsample
  for(int node_idx = 0; node_idx < N; node_idx++){
    
    // calculate next node value based on current subsample
    float masked_sample_i = mask[node_idx] * sample;
    float mg_in = gamma * masked_sample_i + eta * reservoir[LAST_NODE];
    float mg_out = mackey_glass(mg_in);


    // update reservoir  
    for(int i = LAST_NODE; i > 0; i--) reservoir[i] = reservoir[i - 1];
    reservoir[0] = mg_out;

    // calculate output
    dfr_out += W[node_idx] * mg_out;
  }


  return dfr_out;
}

int main() {

  // define sample counts
  constexpr int NUM_INIT_SAMPLES = 1;
  constexpr int NUM_TEST_SAMPLES = 1;
  constexpr int NUM_TOTAL_SAMPLES = NUM_INIT_SAMPLES + NUM_TEST_SAMPLES;

  // generate narma10 inputs and outputs
  float* u = narma10_inputs(NUM_TOTAL_SAMPLES);
  float* y = narma10_outputs(u,NUM_TOTAL_SAMPLES);

  // get test data vectors
  float* u_test = get_vector_indexes(u,NUM_INIT_SAMPLES,NUM_TOTAL_SAMPLES);
  float* y_test = get_vector_indexes(y,NUM_INIT_SAMPLES,NUM_TOTAL_SAMPLES);

  // store test data outputs
  float y_hat_test[NUM_TEST_SAMPLES];

  // reservoir initialization
  for(unsigned int i = 0; i < NUM_INIT_SAMPLES; i++) ihc_hls_enqueue_noret(&dfr,u[i]);
  ihc_hls_component_run_all(dfr);

  // reservoir test
  for(unsigned int i = 0; i < NUM_TEST_SAMPLES; i++) ihc_hls_enqueue(&y_hat_test[i], &dfr,u_test[i]);
  ihc_hls_component_run_all(dfr);

  // calculate the NRMSE of the predicted output
  float nrmse = get_nrmse(y_hat_test,y_test,NUM_TEST_SAMPLES);
  printf("Test NRMSE\t= %f\n",nrmse);

  // calculate the MSE of the predicted output
  float mse = get_mse(y_hat_test,y,NUM_TEST_SAMPLES);
  printf("Test MSE\t= %f\n",mse);

  return 0;

}
