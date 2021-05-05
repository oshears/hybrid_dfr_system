import os
import mmap
import time

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

NUM_STEPS_PER_SAMPLE = 100
NUM_INIT_SAMPLES = 100
NUM_TEST_SAMPLES = 100
NUM_VIRTUAL_NODES = 100

DFR_INPUT_MEM_ADDR_OFFSET     = 0x100_0000
DFR_RESERVOIR_ADDR_MEM_OFFSET = 0x200_0000
DFR_WEIGHT_MEM_ADDR_OFFSET    = 0x300_0000
DFR_OUTPUT_MEM_ADDR_OFFSET    = 0x400_0000

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
fh = open("dfr_narma10_data.txt","r")
lines = fh.readlines()
addr_offset = 0
for line in lines:
    sample_val = int(line.strip())
    regs[DFR_INPUT_MEM_ADDR_OFFSET + addr_offset*4 : DFR_INPUT_MEM_ADDR_OFFSET + addr_offset*4 + 4] = int2bytes(sample_val)
    
    # Test Read
    # readback = bytes2int(regs[DFR_INPUT_MEM_ADDR_OFFSET + addr_offset*4 : DFR_INPUT_MEM_ADDR_OFFSET + addr_offset*4 + 4])
    # print(f"Wrote: {readback}")

    # Next Addr
    addr_offset += 1

    if addr_offset == NUM_STEPS_PER_SAMPLE * (NUM_TEST_SAMPLES + NUM_INIT_SAMPLES + NUM_VIRTUAL_NODES):
        break

fh.close()

# Configure Weights
print("Configuring Weight Memory")

# Write DFR Weight Mem
fh = open("dfr_narma10_weights.txt","r")
lines = fh.readlines()
addr_offset = NUM_VIRTUAL_NODES - 1
for line in lines:
    
    # Read Weight Value and Write
    weight_val = int(line.strip())
    regs[DFR_WEIGHT_MEM_ADDR_OFFSET + addr_offset*4 : DFR_WEIGHT_MEM_ADDR_OFFSET + addr_offset*4 + 4] = int2bytes(weight_val)

    # Test Read
    # readback = bytes2int(regs[DFR_WEIGHT_MEM_ADDR_OFFSET + addr_offset*4 : DFR_WEIGHT_MEM_ADDR_OFFSET + addr_offset + 4])
    # print(f"Wrote: {readback}")

    # Next Addr
    addr_offset -= 1

fh.close()

# Launch DFR
print("Running DFR")
regs[CTRL_REG_ADDR] = 0x0000_0001

while(regs[CTRL_REG_ADDR] != 0x2):
    continue

# Check CTRL_REG (Bit 1 = Busy)
ctrl_reg_val = regs[CTRL_REG_ADDR]
print(f"CTRL_REG: {ctrl_reg_val}")

# Read Outputs
print("Reading Output Memory")

# Read DFR Output Mem
addr_offset = 0
for addr_offset in range(100):
    output_val = bytes2int(regs[DFR_OUTPUT_MEM_ADDR_OFFSET + addr_offset*4 : DFR_OUTPUT_MEM_ADDR_OFFSET + addr_offset*4 + 4])
    print(f"Output @ {addr_offset}: {output_val}")


exit()



# peek 0x40000000
# peek 0x40000004
# peek 0x40000008
# peek 0x4000000C
# peek 0x40000010
# peek 0x40000014
# peek 0x40000018
# peek 0x4000001C
# peek 0x40000020