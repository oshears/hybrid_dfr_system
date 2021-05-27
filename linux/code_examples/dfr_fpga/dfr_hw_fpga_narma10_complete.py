import os
import mmap
import time
import numpy as np
import math

def int2bytes(data):
    return bytes([data & 0xFF, (data >> 8) & 0xFF, (data >> 16) & 0xFF, (data >> 24) & 0xFF])


def bytes2int(bytes):
    return int.from_bytes(bytes,"little")


mem_file = os.open("/dev/uio0", os.O_SYNC | os.O_RDWR)
dfr_core_axi_addr_size = 0x4000_0000
dfr_core_regs = mmap.mmap(mem_file, dfr_core_axi_addr_size, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE, 0) 
regs = dfr_core_regs

CTRL_REG_ADDR = 0x0
ASIC_OUT_REG_ADDR = 0x4
ASIC_IN_REG_ADDR = 0x8

ASIC_DONE = 0x2

CTRL_REG_ADDR = 0x0000
DEBUG_REG_ADDR = 0x0004
NUM_INIT_SAMPLES_REG_ADDR = 0x0008
NUM_TRAIN_SAMPLES_REG_ADDR = 0x000C
NUM_TEST_SAMPLES_REG_ADDR = 0x0010
NUM_STEPS_PER_SAMPLE_REG_ADDR = 0x0014
NUM_INIT_STEPS_REG_ADDR = 0x0018
NUM_TRAIN_STEPS_REG_ADDR = 0x001C
NUM_TEST_STEPS_REG_ADDR = 0x0020
RESERVOIR_NODE_REG_ADDR = 0x0024

DFR_INPUT_MEM_ADDR_OFFSET     = 0x100_0000
DFR_RESERVOIR_ADDR_MEM_OFFSET = 0x200_0000
DFR_WEIGHT_MEM_ADDR_OFFSET    = 0x300_0000
DFR_OUTPUT_MEM_ADDR_OFFSET    = 0x400_0000

NUM_VIRTUAL_NODES = 100
NUM_STEPS_PER_SAMPLE = 100

NUM_VIRTUAL_NODES = 100
NUM_STEPS_PER_SAMPLE = NUM_VIRTUAL_NODES
MAX_INPUT_SAMPLES_STEPS = int(2 ** 16 / NUM_STEPS_PER_SAMPLE) * NUM_STEPS_PER_SAMPLE
MAX_INPUT_SAMPLES = int(MAX_INPUT_SAMPLES_STEPS / NUM_STEPS_PER_SAMPLE)

# NUM_INIT_SAMPLES + NUM_TEST_SAMPLES must be less than MAX_INPUT_SAMPLES - 1 to prevent internal sample_cntr from overflowing  
NUM_INIT_SAMPLES = 100
NUM_TEST_SAMPLES = MAX_INPUT_SAMPLES - NUM_INIT_SAMPLES
NUM_TEST_SAMPLES_STEPS = NUM_TEST_SAMPLES * 100

TOTAL_STEPS = 410000
TOTAL_SAMPLES = 4100
TOTAL_TEST_SAMPLES = TOTAL_SAMPLES - NUM_INIT_SAMPLES

NUM_TEST_INPUT_BATCHES = math.ceil(TOTAL_TEST_SAMPLES / NUM_TEST_SAMPLES)

# Configure Widths
regs[NUM_INIT_SAMPLES_REG_ADDR : NUM_INIT_SAMPLES_REG_ADDR + 4] = int2bytes(NUM_INIT_SAMPLES)
regs[NUM_TRAIN_SAMPLES_REG_ADDR : NUM_TRAIN_SAMPLES_REG_ADDR + 4] = int2bytes(0)
regs[NUM_TEST_SAMPLES_REG_ADDR : NUM_TEST_SAMPLES_REG_ADDR + 4] = int2bytes(NUM_TEST_SAMPLES)

regs[NUM_INIT_STEPS_REG_ADDR : NUM_INIT_STEPS_REG_ADDR + 4] = int2bytes(NUM_INIT_SAMPLES * NUM_STEPS_PER_SAMPLE)
regs[NUM_TRAIN_STEPS_REG_ADDR : NUM_TRAIN_STEPS_REG_ADDR + 4] = int2bytes(0)
regs[NUM_TEST_STEPS_REG_ADDR : NUM_TEST_STEPS_REG_ADDR + 4] = int2bytes(NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE)

print(f"Samples: {NUM_TEST_SAMPLES}, Steps: {NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE}")

regs[NUM_STEPS_PER_SAMPLE_REG_ADDR : NUM_STEPS_PER_SAMPLE_REG_ADDR + 4] = int2bytes(NUM_STEPS_PER_SAMPLE)

# Used to persistently keep track of inputs
input_cntr = 0
input_addr = 0

# Keep track of DFR predictions
predicted_target = np.ndarray(shape=(1,TOTAL_TEST_SAMPLES))
dfr_output_cntr = 0

# Configure Input Samples
print("Configuring Input Memory")

# Write DFR Input Mem
fh = open("dfr_sw_int_narma10_inputs.txt","r")
input_file_lines = fh.readlines()
fh.close()

# Write Init Samples
for i in range(NUM_INIT_SAMPLES):
    sample_val = int(input_file_lines[input_addr].strip())
    regs[DFR_INPUT_MEM_ADDR_OFFSET + input_cntr*4 : DFR_INPUT_MEM_ADDR_OFFSET + input_cntr*4 + 4] = int2bytes(sample_val)
    input_addr += 1
    input_cntr += 1


# Write Test Samples
for i in range(NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE):
    sample_val = int(input_file_lines[input_addr].strip())
    regs[DFR_INPUT_MEM_ADDR_OFFSET + input_cntr*4 : DFR_INPUT_MEM_ADDR_OFFSET + input_cntr*4 + 4] = int2bytes(sample_val)

# Configure Weights
print("Configuring Weight Memory")

# Write DFR Weight Mem
fh = open("dfr_sw_int_narma10_weights.txt","r")
lines = fh.readlines()
fh.close()

for i in range(NUM_VIRTUAL_NODES):
    
    # Read Weight Value and Write
    weight_val = int(lines[NUM_VIRTUAL_NODES - i - 1].strip())
    regs[DFR_WEIGHT_MEM_ADDR_OFFSET + i*4 : DFR_WEIGHT_MEM_ADDR_OFFSET + i*4 + 4] = int2bytes(weight_val)

# Launch DFR
print("Running DFR")
regs[CTRL_REG_ADDR : CTRL_REG_ADDR + 4] = int2bytes(0x0000_1005)

# Poll until DFR is finished
while(regs[CTRL_REG_ADDR] & 0x2 != 0x0):
    continue

# Read Outputs
print("Reading DFR Output Memory")
for i in range(NUM_TEST_SAMPLES):
    output_val = bytes2int(regs[DFR_OUTPUT_MEM_ADDR_OFFSET + i*4 : DFR_OUTPUT_MEM_ADDR_OFFSET + i*4 + 4])
    predicted_target[0,dfr_output_cntr] = output_val

    if dfr_output_cntr < NUM_VIRTUAL_NODES:
        print(f"Output[{dfr_output_cntr}]: {predicted_target[0,dfr_output_cntr]}")

    dfr_output_cntr += 1


# Reconfigure sample counts
regs[NUM_INIT_SAMPLES_REG_ADDR : NUM_INIT_SAMPLES_REG_ADDR + 4] = int2bytes(0)
regs[NUM_INIT_STEPS_REG_ADDR : NUM_INIT_STEPS_REG_ADDR + 4] = int2bytes(0)

for batch in range(1,NUM_TEST_INPUT_BATCHES+1):
    print(f"Batch: {batch} / {NUM_TEST_INPUT_BATCHES}")

    # Update inputs
    input_pos = 0
    for i in range(NUM_TEST_SAMPLES_STEPS):
        if input_addr > TOTAL_STEPS - 1:
            print("Last Input Step Reached")
            break

        sample_val = int(input_file_lines[input_addr].strip())
        regs[DFR_INPUT_MEM_ADDR_OFFSET + input_pos*4 : DFR_INPUT_MEM_ADDR_OFFSET + input_pos*4 + 4] = int2bytes(sample_val)
        
        if i == 0:
            print(f"Input[{input_addr}] = {sample_val}")

        input_addr += 1
        input_pos += 1

    BATCH_TEST_SAMPLES_STEPS = input_pos
    BATCH_TEST_SAMPLES = int(input_pos / 100)
    print(f"Number of Test Input Steps: {BATCH_TEST_SAMPLES_STEPS}, Samples: {BATCH_TEST_SAMPLES}, Addr: {input_addr}")
    regs[NUM_TEST_SAMPLES_REG_ADDR : NUM_TEST_SAMPLES_REG_ADDR + 4] = int2bytes(BATCH_TEST_SAMPLES)
    regs[NUM_TEST_STEPS_REG_ADDR : NUM_TEST_STEPS_REG_ADDR + 4] = int2bytes(BATCH_TEST_SAMPLES_STEPS)

    node_i = NUM_VIRTUAL_NODES - 1
    # use the node states from the last set of input samples
    for i in range(NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE - NUM_STEPS_PER_SAMPLE, NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE):

        # Read node state from the reservoir history
        node_i_state = bytes2int(regs[DFR_RESERVOIR_ADDR_MEM_OFFSET + i*4 : DFR_RESERVOIR_ADDR_MEM_OFFSET + i*4 + 4])

        # Select Corresponding Node
        # Shift by 4 to write to reservoir node select bits
        regs[CTRL_REG_ADDR : CTRL_REG_ADDR + 4] = int2bytes(node_i << 4)
        

        # Update Node State
        # Shift by 4 to fit in 12-bit reservoir node
        regs[RESERVOIR_NODE_REG_ADDR : RESERVOIR_NODE_REG_ADDR + 4] = int2bytes(node_i_state >> 4)

        # Move to next node
        node_i -= 1

    # Launch DFR
    print("Running DFR")
    regs[CTRL_REG_ADDR : CTRL_REG_ADDR + 4] = int2bytes(0x0000_1005)

    # Poll until DFR is finished
    while(regs[CTRL_REG_ADDR] & 0x2 != 0x0):
        continue

    # Read Outputs
    output_val = 0
    print("Reading DFR Output Memory")
    for i in range(BATCH_TEST_SAMPLES):
        if dfr_output_cntr > TOTAL_TEST_SAMPLES - 1:
            print(f"Last Output: {output_val}")
            print("test samples exceeded")
            break
        output_val = bytes2int(regs[DFR_OUTPUT_MEM_ADDR_OFFSET + i*4 : DFR_OUTPUT_MEM_ADDR_OFFSET + i*4 + 4])
        predicted_target[0,dfr_output_cntr] = output_val
        
        if dfr_output_cntr > TOTAL_TEST_SAMPLES - NUM_VIRTUAL_NODES:
            print(f"Output[{dfr_output_cntr}]: {predicted_target[0,dfr_output_cntr]}")

        

        dfr_output_cntr += 1

# Load Expected Data
Yt = np.ndarray(shape=(1,TOTAL_TEST_SAMPLES))
expected_output_cntr = 0
fh = open("dfr_sw_int_narma10_expected_dfr_outputs.txt","r")
output_file_lines = fh.readlines()
fh.close()
for expected_output_line in output_file_lines:
    if expected_output_cntr < TOTAL_TEST_SAMPLES:
        Yt[0,expected_output_cntr] = float(expected_output_line.strip())
    expected_output_cntr += 1

# Calculate the MSE through L2 norm
mse   = np.sum(np.power(Yt - predicted_target,2)) / Yt.size
nrmse = (np.linalg.norm(Yt - predicted_target) / np.linalg.norm(Yt))
print(Yt.size)
print('--------------------------------------------------')
print('Testing Errors')
print(f'testing mse: {mse}')
print(f'testing nrmse: {nrmse}')