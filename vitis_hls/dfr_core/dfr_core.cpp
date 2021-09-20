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

/*
 * This file contains an example for creating an AXI4-master interface in Vivado HLS
 */

/*
Pragma Documentation
https://www.xilinx.com/html_docs/xilinx2021_1/vitis_doc/hls_pragmas.html
*/

#include "dfr_core.h"

#ifndef __SYNTHESIS__
#include <stdio.h>
#endif

void dfr_inference(volatile float *inputs, volatile int *weights, volatile long *outputs, int virtual_nodes, int num_samples, int init_len, int train_len, int test_len, int gamma, int eta, int max_input)
{
// #pragma HLS INTERFACE s_axilite port=return
#pragma HLS INTERFACE s_axilite port=num_virtual_nodes
#pragma HLS INTERFACE s_axilite port=num_samples
#pragma HLS INTERFACE s_axilite port=init_len
#pragma HLS INTERFACE s_axilite port=train_len
#pragma HLS INTERFACE s_axilite port=test_len
#pragma HLS INTERFACE s_axilite port=gamma
#pragma HLS INTERFACE s_axilite port=eta
#pragma HLS INTERFACE s_axilite port=max_input
#pragma HLS INTERFACE m_axi port=inputs  depth=5102   max_widen_bitwidth=32
#pragma HLS INTERFACE m_axi port=weights depth=100    max_widen_bitwidth=32
#pragma HLS INTERFACE m_axi port=outputs depth=5082   max_widen_bitwidth=64


    int i = 0;

    int buff[SAMPLES] = {};
    int* reservoir = new int[virtual_nodes];
    int** reservoir_history = new int*[test_len];
    for (int i = 0; i < test_len; i++)
        reservoir_history[i] = new int[virtual_nodes];

    int sample_idx = 0;

    int reservoir_history_idx = 0;

    // create mask (might be better to hard code this)
    int lfsr_start_state = 0xACE1;
    int* input_mask = new int[virtual_nodes];
    int lfsr = lfsr_start_state;
    int bit = 0;
    for(int i = 0; i < virtual_nodes; i++){
        bit = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5));
        lfsr = (lfsr >> 1) | (bit << 15) & 0xFFFF;
        input_mask[i] = lfsr / max_input;
    } 
    

    // reservoir initialization
    int input_idx = 1;
    for (int k = 0; k < INIT_LEN * TP; k++)
    {

        int node_idx = 0;

        int masked_input = inputs[input_idx] * input_mask[k % virtual_nodes];

        // calculate the next reservoir value and store in the first reservoir node
        int mg_input = (1 / gamma) * masked_input + (1 / eta) * reservoir[virtual_nodes - 1];
        int mg_output = ( MAX_INPUT * mackey_glass(mg_input) ) / MAX_MG_OUTPUT;

        // for each node, copy the current data to the next node
        for (node_idx = virtual_nodes - 1; node_idx >= 1; node_idx--)
        {
            reservoir[node_idx] = reservoir[node_idx - 1];
        }

        reservoir[0] = mg_output;

        // determine if the next input sample should be processed
        if(k % virtual_nodes == 0) input_idx++;
    }

    // for each input sample
    for (int k = 0; k < test_len * TP; k++)
    {

        

        int node_idx = 0;

        int t = INIT_LEN * TP + k;

        int masked_input = inputs[input_idx] * input_mask[k % virtual_nodes];
        

        // calculate the next reservoir value and store in the first reservoir node
        int mg_input = GAMMA * masked_input + ETA * reservoir[virtual_nodes - 1];
        int mg_output = ( MAX_INPUT * mackey_glass(mg_input) ) / MAX_MG_OUTPUT;

        // for each node, copy the current data to the next node
        for (node_idx = virtual_nodes - 1; node_idx >= 1; node_idx--)
        {
            reservoir[node_idx] = reservoir[node_idx - 1];
        }

        reservoir[0] = mg_output;

        // after every 100 samples, store the complete reservoir state for the matrix multiplication
        if ((k + 1) % virtual_nodes == 0)
        {
            int reservoir_node_idx = 0;

            // store all 100 reservoir nodes in reservoir history array
            for (reservoir_node_idx = 0; reservoir_node_idx < virtual_nodes; reservoir_node_idx++)
            {
                
                reservoir_history[reservoir_history_idx][reservoir_node_idx] = reservoir[(virtual_nodes - 1) - reservoir_node_idx];
            }

            reservoir_history_idx++;
        }

        // determine if the next input sample should be processed
        if(k % virtual_nodes == 0) input_idx++;
    }

    // matrix multiplication with weights
    int output_idx = 0;
    int weight_idx = 0;

    for (output_idx = 0; output_idx < test_len; output_idx++){
      long output_sum = 0;
      for (weight_idx = 0; weight_idx < virtual_nodes; weight_idx++){
        output_sum = output_sum + ((long) weights[weight_idx]) * ((long) reservoir_history[output_idx][(virtual_nodes - 1) - weight_idx]);
      }
      outputs[output_idx] = output_sum;

    }

}
