import os
import mmap
import time
import numpy as np

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
MAX_INPUT_SAMPLES_STEPS = 2 ** 16
MAX_INPUT_SAMPLES = int(MAX_INPUT_SAMPLES_STEPS / NUM_STEPS_PER_SAMPLE)

# NUM_INIT_SAMPLES + NUM_TEST_SAMPLES must be less than MAX_INPUT_SAMPLES - 1 to prevent internal sample_cntr from overflowing  
NUM_INIT_SAMPLES = 1
# NUM_TEST_SAMPLES = MAX_INPUT_SAMPLES - NUM_INIT_SAMPLES - 1
NUM_TEST_SAMPLES = 1


# Configure Widths
regs[NUM_INIT_SAMPLES_REG_ADDR : NUM_INIT_SAMPLES_REG_ADDR + 4] = int2bytes(NUM_INIT_SAMPLES)
regs[NUM_TRAIN_SAMPLES_REG_ADDR : NUM_TRAIN_SAMPLES_REG_ADDR + 4] = int2bytes(0)
regs[NUM_TEST_SAMPLES_REG_ADDR : NUM_TEST_SAMPLES_REG_ADDR + 4] = int2bytes(NUM_TEST_SAMPLES)

regs[NUM_INIT_STEPS_REG_ADDR : NUM_INIT_STEPS_REG_ADDR + 4] = int2bytes(NUM_INIT_SAMPLES * NUM_STEPS_PER_SAMPLE)
regs[NUM_TRAIN_STEPS_REG_ADDR : NUM_TRAIN_STEPS_REG_ADDR + 4] = int2bytes(0)
regs[NUM_TEST_STEPS_REG_ADDR : NUM_TEST_STEPS_REG_ADDR + 4] = int2bytes(NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE)

regs[NUM_STEPS_PER_SAMPLE_REG_ADDR : NUM_STEPS_PER_SAMPLE_REG_ADDR + 4] = int2bytes(NUM_STEPS_PER_SAMPLE)

# Configure Input Samples
print("Configuring Input Memory")

# Write DFR Input Mem
fh = open("dfr_sw_int_narma10_inputs.txt","r")
lines = fh.readlines()
for i in range((NUM_TEST_SAMPLES + NUM_INIT_SAMPLES + 1) * NUM_STEPS_PER_SAMPLE):
    sample_val = int(lines[i].strip())
    regs[DFR_INPUT_MEM_ADDR_OFFSET + i*4 : DFR_INPUT_MEM_ADDR_OFFSET + i*4 + 4] = int2bytes(sample_val)
    
    # Test Read
    # readback = bytes2int(regs[DFR_INPUT_MEM_ADDR_OFFSET + i*4 : DFR_INPUT_MEM_ADDR_OFFSET + i*4 + 4])
    # print(f"DFR_INPUT_MEM_ADDR_OFFSET[{i}] - Wrote: {readback}")

fh.close()

# Configure Weights
print("Configuring Weight Memory")

# Write DFR Weight Mem
fh = open("dfr_sw_int_narma10_weights.txt","r")
lines = fh.readlines()
for i in range(NUM_VIRTUAL_NODES):
    
    # Read Weight Value and Write
    weight_val = int(lines[NUM_VIRTUAL_NODES - i - 1].strip())
    regs[DFR_WEIGHT_MEM_ADDR_OFFSET + i*4 : DFR_WEIGHT_MEM_ADDR_OFFSET + i*4 + 4] = int2bytes(weight_val)

    # Test Read
    # readback = bytes2int(regs[DFR_WEIGHT_MEM_ADDR_OFFSET + i*4 : DFR_WEIGHT_MEM_ADDR_OFFSET + i*4 + 4])
    # print(f"Weight[{i}] - Wrote: {readback}")

fh.close()

# Launch DFR
print("Running DFR")
regs[CTRL_REG_ADDR : CTRL_REG_ADDR + 4] = int2bytes(0x0000_1001)

# Poll until DFR is finished
while(regs[CTRL_REG_ADDR] & 0x2 != 0x0):
    continue

# Read Outputs
print("Reading Output Memory")

Yt = np.ndarray(shape=(1,NUM_TEST_SAMPLES))
expected_output_cntr = 0
fh = open("dfr_sw_int_narma10_expected_dfr_outputs.txt","r")
file_lines = fh.readlines()
for file_line in file_lines:
    if expected_output_cntr < NUM_TEST_SAMPLES:
        Yt[0,expected_output_cntr] = float(file_line.strip())
    expected_output_cntr += 1
fh.close()

predicted_target = np.ndarray(shape=(1,NUM_TEST_SAMPLES))


# Read DFR Output Mem
i = 0
for i in range(NUM_TEST_SAMPLES):
    output_val = bytes2int(regs[DFR_OUTPUT_MEM_ADDR_OFFSET + i*4 : DFR_OUTPUT_MEM_ADDR_OFFSET + i*4 + 4])
    predicted_target[0,i] = output_val
    print(f"DFR_OUTPUT_MEM_ADDR_OFFSET[{i}] - Output @ {i}: {output_val}")

# Read Reservoir Output Mem
i = 0
for i in range((NUM_TEST_SAMPLES) * NUM_STEPS_PER_SAMPLE):
    output_val = bytes2int(regs[DFR_RESERVOIR_ADDR_MEM_OFFSET + i*4 : DFR_RESERVOIR_ADDR_MEM_OFFSET + i*4 + 4])
    print(f"DFR_RESERVOIR_ADDR_MEM_OFFSET[{i}] - Output @ {i}: {output_val}")


# Calculate the MSE through L2 norm
mse   = np.sum(np.power(Yt - predicted_target,2)) / Yt.size
nrmse = (np.linalg.norm(Yt - predicted_target) / np.linalg.norm(Yt))

print('--------------------------------------------------')
print('Testing Errors')
print(f'testing mse: {mse}')
print(f'testing nrmse: {nrmse}')