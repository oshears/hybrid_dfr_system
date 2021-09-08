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

void dfr_inference(volatile int *inputs, volatile int *weights, volatile long *outputs)
{
#pragma HLS INTERFACE s_axilite port=return
#pragma HLS INTERFACE m_axi port=inputs  depth=510200 max_widen_bitwidth=32
#pragma HLS INTERFACE m_axi port=weights depth=100    max_widen_bitwidth=32
#pragma HLS INTERFACE m_axi port=outputs depth=5082   max_widen_bitwidth=64


    int i = 0;

    int buff[SAMPLES] = {};
    int reservoir[VIRTUAL_NODES] = {};
    int reservoir_history[TEST_LEN][VIRTUAL_NODES] = {};

    int sample_idx = 0;

    int reservoir_history_idx = 0;

    // reservoir initialization
    for (int k = 0; k < INIT_LEN * TP; k++)
    {

        int node_idx = 0;

        // calculate the next reservoir value and store in the first reservoir node
        int mg_input = GAMMA * inputs[k] + ETA * reservoir[VIRTUAL_NODES - 1];
        int mg_output = ( MAX_INPUT * mackey_glass(mg_input) ) / MAX_MG_OUTPUT;

        // for each node, copy the current data to the next node
        for (node_idx = VIRTUAL_NODES - 1; node_idx >= 1; node_idx--)
        {
            reservoir[node_idx] = reservoir[node_idx - 1];
        }

        reservoir[0] = mg_output;
    }

    // for each input sample
    for (int k = 0; k < TEST_LEN * TP; k++)
    {

        int node_idx = 0;

        int t = INIT_LEN * TP + k;

        

        // calculate the next reservoir value and store in the first reservoir node
        int mg_input = GAMMA * inputs[t] + ETA * reservoir[VIRTUAL_NODES - 1];
        int mg_output = ( MAX_INPUT * mackey_glass(mg_input) ) / MAX_MG_OUTPUT;

        // for each node, copy the current data to the next node
        for (node_idx = VIRTUAL_NODES - 1; node_idx >= 1; node_idx--)
        {
            reservoir[node_idx] = reservoir[node_idx - 1];
        }

        reservoir[0] = mg_output;

        // after every 100 samples, store the complete reservoir state for the matrix multiplication
        if ((k + 1) % VIRTUAL_NODES == 0)
        {
            int reservoir_node_idx = 0;

            // store all 100 reservoir nodes in reservoir history array
            for (reservoir_node_idx = 0; reservoir_node_idx < VIRTUAL_NODES; reservoir_node_idx++)
            {
                
                reservoir_history[reservoir_history_idx][reservoir_node_idx] = reservoir[(VIRTUAL_NODES - 1) - reservoir_node_idx];
            }

            reservoir_history_idx++;
        }
    }

    // matrix multiplication with weights
    int output_idx = 0;
    int weight_idx = 0;

    for (output_idx = 0; output_idx < TEST_LEN; output_idx++){
      long output_sum = 0;
      for (weight_idx = 0; weight_idx < VIRTUAL_NODES; weight_idx++){
        output_sum = output_sum + ((long) weights[weight_idx]) * ((long) reservoir_history[output_idx][(VIRTUAL_NODES - 1) - weight_idx]);
      }
      outputs[output_idx] = output_sum;

    }

}
