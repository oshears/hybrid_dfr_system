//  Copyright (c) 2021 Intel Corporation                                  
//  SPDX-License-Identifier: MIT                                          

#include "HLS/hls.h"
#include <stdio.h>

#include <cmath>

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
  int N = 50;
  int LAST_NODE = N - 1;
  float gamma = 0.5;
  float eta = 0.4;

  static float reservoir[50];

  // mask definition
  float mask[50];
  for(int mask_idx = 0; mask_idx < N; mask_idx++) mask[mask_idx] = 1;

  // weight definition
  float W[50];
  for(int weight_idx = 0; weight_idx < N; weight_idx++) W[weight_idx] = 1;

  // initialize reservoir
  for(int node_idx = 0; node_idx < N; node_idx++) reservoir[node_idx] = 0;

  // scale sample
  float input = static_cast<float>(sample) / static_cast<float>(0xFFF);

  // mask sample
  float masked_sample[50];
  for (int i = 0; i < N; i++) masked_sample[i] = mask[i] * input;

  // process sample through reservoir

  float dfr_out = 0;
  for(int node_idx = 0; node_idx < N; node_idx++){
    float mg_in = gamma * masked_sample[node_idx] + eta * reservoir[LAST_NODE];
    float mg_out = mackey_glass(mg_in);
    
    for(int i = LAST_NODE; i > 0; i--) reservoir[i] = reservoir[i - 1];
    reservoir[0] = mg_out;

    dfr_out += W[node_idx] * mg_out;
  }

  // calculate output

  return dfr_out;
}

int main() {

  bool pass = true;

  constexpr int NUM_SAMPLES = 2;

  float result[NUM_SAMPLES];

  for(unsigned int i = 0; i < NUM_SAMPLES; i++){
    ihc_hls_enqueue(&result[i], &dfr,);
  }

    ihc_hls_component_run_all(dfr);

  for(unsigned int i = 0; i < NUM_SAMPLES; i++){
    printf("Output[%d] = %f\n",i,result[i]);
  }


    // if(result != (a * b + c)) pass = false;

  if (pass) {
    printf("PASSED\n");
  }
  else {
    printf("FAILED\n");
  }

  return 0;

}
