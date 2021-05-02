import os
import mmap
import time


mem_file = os.open("/dev/uio0", os.O_SYNC | os.O_RDWR)
dfr_core_axi_addr_size = 0x10000
dfr_core_regs = mmap.mmap(mem_file, dfr_core_axi_addr_size, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE, 0) 
regs = dfr_core_regs

CTRL_REG_ADDR = 0x0
ASIC_OUT_REG_ADDR = 0x4
ASIC_IN_REG_ADDR = 0x8

ASIC_DONE = 0x2

CTRL_REG_ADDR = 0x43C00000
DEBUG_REG_ADDR = 0x43C00004
NUM_INIT_SAMPLES_REG_ADDR = 0x43C00008
NUM_TRAIN_SAMPLES_REG_ADDR = 0x43C0000C
NUM_TEST_SAMPLES_REG_ADDR = 0x43C00010
NUM_STEPS_PER_SAMPLE_REG_ADDR = 0x43C00014
NUM_INIT_STEPS_REG_ADDR = 0x43C00018
NUM_TRAIN_STEPS_REG_ADDR = 0x43C0001C
NUM_TEST_STEPS_REG_ADDR = 0x43C00020

EXT_MEM_ADDR = 0x43C0_0100

NUM_STEPS_PER_SAMPLE = 100
NUM_INIT_SAMPLES = 100
NUM_TEST_SAMPLES = 100
NUM_VIRTUAL_NODES = 100


# Configure Widths
regs[NUM_INIT_SAMPLES_REG_ADDR] = NUM_INIT_SAMPLES
regs[NUM_TRAIN_SAMPLES_REG_ADDR] = 0
regs[NUM_TEST_SAMPLES_REG_ADDR] = NUM_TEST_SAMPLES

regs[NUM_INIT_STEPS_REG_ADDR] = NUM_INIT_SAMPLES * NUM_STEPS_PER_SAMPLE
regs[NUM_TRAIN_STEPS_REG_ADDR] = 0
regs[NUM_TEST_STEPS_REG_ADDR] = NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE

regs[NUM_STEPS_PER_SAMPLE_REG_ADDR] = NUM_STEPS_PER_SAMPLE

# Configure Input Samples
# Select Input Mem
regs[CTRL_REG_ADDR] = 0x0000_0000

# Write DFR Input Mem
fh = open("dfr_narma10_data","r")
lines = fh.readlines()
addr_offset = 0
for line in lines:
    sample_val = int(line.strip())
    regs[EXT_MEM_ADDR + addr_offset] = sample_val
    addr_offset += 1

fh.close()

# Configure Weights
# Select Weight Mem
regs[CTRL_REG_ADDR] = 0x0000_0020

# Write DFR Weight Mem
fh = open("dfr_narma10_weights","r")
lines = fh.readlines()
addr_offset = NUM_VIRTUAL_NODES - 1
for line in lines:
    weight_val = int(line.strip())
    regs[EXT_MEM_ADDR + addr_offset] = weight_val
    addr_offset -= 1

fh.close()

# Launch DFR
regs[CTRL_REG_ADDR] = 0x0000_0001

time.sleep(1)

# Select DFR Output Mem
regs[CTRL_REG_ADDR] = 0x0000_0030

# Read DFR Output Mem
addr_offset = 0
for addr_offset in range(100):
    output_val = regs[EXT_MEM_ADDR + addr_offset]
    print(f"Output @ {addr_offset}: {output_val}")
