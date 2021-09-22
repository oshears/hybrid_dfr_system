/*
 * Copyright 2021 Xilinx, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>

#include "dfr_core.h"

using namespace std;

void dfr_core_sw(float *inputs, int *weights, long *outputs, unsigned int num_virtual_nodes, unsigned int num_samples, unsigned int init_len, unsigned int train_len, unsigned int test_len, unsigned int gamma, unsigned int eta, unsigned int max_input);

int main()
{
  int i;

  float inputs[(INIT_LEN + TEST_LEN) * TP] = {};
  int weights[VIRTUAL_NODES] = {};
  long outputs[TEST_LEN] = {};
  long expected_outputs[TEST_LEN] = {};

  ifstream inFile;

  // Read Inputs from File
  printf("Reading data from files...\n");
  inFile.open("../../../../../../python/data/spectrum/dfr_sw_int_spectrum_inputs.txt");
  if(!inFile.is_open()){
    printf("Could not open \"../../../../../../python/data/spectrum/dfr_sw_int_spectrum_inputs.txt\"\n");
    return 1;
  }
  for(i = 0; i < (2 * INIT_LEN + TEST_LEN + TRAIN_LEN) * TP; i++){
    inFile >> inputs[i];
  }
  inFile.close();

  // Read Weights from File
  inFile.open("../../../../../../python/data/spectrum/dfr_sw_int_spectrum_weights.txt");
  if(!inFile.is_open()){
    printf("Could not open \"../../../../../../python/data/spectrum/dfr_sw_int_spectrum_weights.txt\"\n");
    return 1;
  }
  for(i = 0; i < VIRTUAL_NODES; i++){
    inFile >> weights[i];
  }
  inFile.close();

  //Call the hardware function
  printf("Running HLS Code...\n");
  int gamma = 0;
  int eta = 4;
  int max_input = 200;

  dfr_core(inputs,weights,outputs,VIRTUAL_NODES,SAMPLES,INIT_LEN,TRAIN_LEN,TEST_LEN,gamma,eta,max_input);
  dfr_core_sw(inputs,weights,expected_outputs,VIRTUAL_NODES,SAMPLES,INIT_LEN,TRAIN_LEN,TEST_LEN,gamma,eta,max_input);

  // Read Expected Outputs from File
  printf("Comparing results to expected outputs...\n");
  inFile.open("../../../../../../python/data/spectrum/dfr_sw_int_spectrum_dfr_outputs.txt");
  if(!inFile.is_open()){
    printf("Could not open \"../../../../../../python/data/spectrum/dfr_sw_int_spectrum_dfr_outputs.txt\"\n");
    return 1;
  }
  for(i = 0; i < TEST_LEN; i++){
    // inFile >> expected_outputs[i];
    if (expected_outputs[i] != outputs[i]){
      printf("i = %d Expected = %ld Actual = %ld\n",i,expected_outputs[i],outputs[i]);
     printf("ERROR HW and SW results mismatch\n");
     return 1;
    }
  }
  inFile.close();


  printf("Success HW and SW results match\n");
  return 0;
}


void dfr_core_sw(float* inputs, int* weights, long* outputs, unsigned int num_virtual_nodes, unsigned int num_samples, unsigned int init_len, unsigned int train_len, unsigned int test_len, unsigned int gamma, unsigned int eta, unsigned int max_input)
{

  int*  const reservoir = new int[MAX_VIRTUAL_NODES]();
  int** const reservoir_history = new int*[test_len]();
  for (int i = 0; i < MAX_TEST_LEN; i++)
      reservoir_history[i] = new int[MAX_VIRTUAL_NODES]();



    int* input_mask = generate_lfsr_input_mask(num_virtual_nodes,max_input);
    
    // reservoir initialization
    bool reservoir_filled = false;
    RESERVOIR_INIT_INPUT_LOOP:
    for (int input_idx = 0; input_idx < init_len; input_idx++){
        RESERVOIR_INIT_NODE_LOOP:
        for (int node_idx = 0; node_idx < num_virtual_nodes; node_idx++){
            // apply input mask to current sample
            int masked_input = inputs[input_idx] * input_mask[node_idx];

            // calculate the next reservoir value and store in the first reservoir node
            int reservoir_feedback = reservoir_filled ? reservoir[num_virtual_nodes - 1] : 0;
            int mg_input = (masked_input >> gamma) + (reservoir_feedback >> eta);
            int mg_output = mackey_glass(mg_input);

            // for each node, copy the current data to the next node
            RESERVOIR_INIT_UPDATE_LOOP:
            for (int node_idx = num_virtual_nodes - 1; node_idx >= 1; node_idx--)
                reservoir[node_idx] = reservoir[node_idx - 1];

            // store mg output in the first reservoir node
            reservoir[0] = mg_output;

            if(node_idx == num_virtual_nodes - 1) reservoir_filled = true;
        }
    }


    // for each input sample
    long output_sum = 0;
    RESERVOIR_TEST_INPUT_LOOP:
    for (int input_idx = init_len; input_idx < test_len; input_idx++){
        RESERVOIR_TEST_NODE_LOOP:
        for (int node_idx = 0; node_idx < num_virtual_nodes; node_idx++){
            int output_idx = input_idx - init_len;
            // apply input mask to current sample
            int masked_input = inputs[input_idx] * input_mask[node_idx];
            
            // calculate the next reservoir value and store in the first reservoir node
            int mg_input = (masked_input >> gamma) + (reservoir[num_virtual_nodes - 1] >> eta);
            int mg_output = mackey_glass(mg_input);

            // for each node, copy the current data to the next node
            RESERVOIR_TEST_UPDATE_LOOP:
            for (int node_idx = num_virtual_nodes - 1; node_idx >= 1; node_idx--)
                reservoir[node_idx] = reservoir[node_idx - 1];

            // store mg output in the first reservoir node
            reservoir[0] = mg_output;

            // record output in reservoir history array for matrix multiplication
            output_sum = output_sum + ((long) weights[node_idx]) * ((long) mg_output);

            if (node_idx == num_virtual_nodes - 1){
                outputs[output_idx] = output_sum;
                output_sum = 0;
            } 
        }
    }

}
