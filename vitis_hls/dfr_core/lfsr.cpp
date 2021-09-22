#include "dfr_core.h"

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