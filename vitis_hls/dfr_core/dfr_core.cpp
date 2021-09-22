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
	for(int i = 0; i < mask_length; i++){
		bit = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5));
		lfsr = ((lfsr >> 1) | (bit << 15)) & 0xFFFF;
		input_mask[i] = lfsr / mask_scale;
	}
	return input_mask;
}

void dfr_inference(float *inputs, int *weights, unsigned long *outputs, unsigned int num_virtual_nodes, unsigned int num_samples, unsigned int init_len, unsigned int train_len, unsigned int test_len, unsigned int gamma, unsigned int eta, unsigned int max_input)
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
#pragma HLS INTERFACE m_axi port=inputs  depth=5102 max_widen_bitwidth=64 bundle=DFR_DATA_BUS
#pragma HLS INTERFACE m_axi port=weights depth=100  max_widen_bitwidth=64 bundle=DFR_DATA_BUS
#pragma HLS INTERFACE m_axi port=outputs depth=5082 max_widen_bitwidth=64 bundle=DFR_DATA_BUS


    int i = 0;

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

    int sample_idx = 0;
    int input_idx = 0;

    bool reservoir_filled = false;


    int* input_mask = generate_lfsr_input_mask(num_virtual_nodes,max_input);
    
    // reservoir initialization
    input_idx = 0;
    
    for (int k = 0; k < init_len * num_virtual_nodes; k++)
    {

        // apply input mask to current sample
        int masked_input = inputs[input_idx] * input_mask[k % num_virtual_nodes];

        // calculate the next reservoir value and store in the first reservoir node
        int mg_input = (masked_input >> gamma) + (reservoir_filled ? (reservoir[num_virtual_nodes - 1] >> eta) : 0);
        int mg_output = mackey_glass(mg_input);

        // for each node, copy the current data to the next node
        for (int node_idx = num_virtual_nodes - 1; node_idx >= 1; node_idx--)
            reservoir[node_idx] = reservoir[node_idx - 1];

        // store mg output in the first reservoir node
        reservoir[0] = mg_output;

        // determine if the next input sample should be processed
        if((k + 1) % num_virtual_nodes == 0) input_idx++;

        // set reservoir filled to true when num_virtual_nodes samples have been processed
        if(k == num_virtual_nodes - 1) reservoir_filled = true;
    }


    // for each input sample
    long output_sum = 0;
    for (int k = 0; k < test_len * num_virtual_nodes; k++)
    {

        // apply input mask to current sample
        int masked_input = inputs[input_idx] * input_mask[k % num_virtual_nodes];
        
        // calculate the next reservoir value and store in the first reservoir node
        int mg_input = (masked_input >> gamma) + (reservoir[num_virtual_nodes - 1] >> eta);
        int mg_output = mackey_glass(mg_input);

        // for each node, copy the current data to the next node
        for (int node_idx = num_virtual_nodes - 1; node_idx >= 1; node_idx--)
            reservoir[node_idx] = reservoir[node_idx - 1];

        // store mg output in the first reservoir node
        reservoir[0] = mg_output;

        // record output in reservoir history array for matrix multiplication
        int output_idx = input_idx - init_len;
        reservoir_history[output_idx][k % num_virtual_nodes] = reservoir[0];
        
        int weight_idx = (num_virtual_nodes - 1) - (k % num_virtual_nodes);
        output_sum = output_sum + ((long) weights[weight_idx]) * ((long) mg_output);

        // determine if the next input sample should be processed
        // increment input index
        if((k + 1) % num_virtual_nodes == 0){
            outputs[output_idx] = output_sum;
            output_sum = 0;
        	input_idx++;
        }
    }

}
