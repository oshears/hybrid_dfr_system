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

int* generate_lfsr_input_mask(int mask_length,int mask_scale){
	int lfsr_start_state = 0xACE1;
#ifndef __SYNTHESIS__
	int* const input_mask = new int[MAX_VIRTUAL_NODES]();
#else
	int input_mask[MAX_VIRTUAL_NODES];
#endif
	int lfsr = lfsr_start_state;
	int bit = 0;
    LFSR_INIT_LOOP:
	for(int i = 0; i < mask_length; i++){
		bit = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5));
		lfsr = ((lfsr >> 1) | (bit << 15)) & 0xFFFF;
		input_mask[i] = lfsr / mask_scale;
	}
	return input_mask;
}

// Note: Functions that can use an ap_fifo interface often use pointers and might access the same variable multiple times. To understand the importance of the volatile qualifier when using this coding style, see Multi-Access Pointers on the Interface.

void dfr_core(float* inputs, int* weights, long* outputs, unsigned int num_virtual_nodes, unsigned int num_samples, unsigned int init_len, unsigned int train_len, unsigned int test_len, unsigned int gamma, unsigned int eta, unsigned int max_input)
{
#pragma HLS INTERFACE s_axilite port=return            bundle=DFR_CTRL_BUS
#pragma HLS INTERFACE s_axilite port=num_virtual_nodes bundle=DFR_CTRL_BUS
#pragma HLS INTERFACE s_axilite port=num_samples       bundle=DFR_CTRL_BUS
#pragma HLS INTERFACE s_axilite port=init_len          bundle=DFR_CTRL_BUS
#pragma HLS INTERFACE s_axilite port=train_len         bundle=DFR_CTRL_BUS
#pragma HLS INTERFACE s_axilite port=test_len          bundle=DFR_CTRL_BUS
#pragma HLS INTERFACE s_axilite port=gamma             bundle=DFR_CTRL_BUS
#pragma HLS INTERFACE s_axilite port=eta               bundle=DFR_CTRL_BUS
#pragma HLS INTERFACE s_axilite port=max_input         bundle=DFR_CTRL_BUS
#pragma HLS INTERFACE m_axi port=inputs  depth=8192 bundle=INPUT_DATA_BUS 
#pragma HLS INTERFACE m_axi port=weights depth=128  bundle=WEIGHT_DATA_BUS
#pragma HLS INTERFACE m_axi port=outputs depth=8192 bundle=OUTPUT_DATA_BUS


#ifndef __SYNTHESIS__
    int*  const reservoir = new int[MAX_VIRTUAL_NODES]();
    int** const reservoir_history = new int*[test_len]();
    for (int i = 0; i < MAX_TEST_LEN; i++)
        reservoir_history[i] = new int[MAX_VIRTUAL_NODES]();
#else
    // arrays must be specified with constant size
    int reservoir[MAX_VIRTUAL_NODES];
	int reservoir_history[MAX_TEST_LEN][MAX_VIRTUAL_NODES];
#endif



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
