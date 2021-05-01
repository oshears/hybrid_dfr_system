import os
import mmap
import time

# minicom -C capturefile
# exiti minicom: esc-A X

mem_file = os.open("/dev/uio0", os.O_SYNC | os.O_RDWR)
asic_function_axi_addr_size = 0x10000
asic_function_regs = mmap.mmap(mem_file, asic_function_axi_addr_size, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE, 0) 
regs = asic_function_regs

CTRL_REG_ADDR = 0x0
ASIC_OUT_REG_ADDR = 0x4
ASIC_IN_REG_ADDR = 0x8

ASIC_DONE = 0x2

file = open("asic_function.csv","w")
for i in range(0x10000):
    dac_data = i

    encoded_dac_data = bytes([dac_data & 0xFF, (dac_data >> 8) & 0xFF, 0x00, 0x00])

    regs[ASIC_OUT_REG_ADDR : ASIC_OUT_REG_ADDR + 4] = encoded_dac_data
    regs[CTRL_REG_ADDR] = 0x1

    while(regs[CTRL_REG_ADDR] != ASIC_DONE):
        continue

    results_bytes = regs[ASIC_IN_REG_ADDR : ASIC_IN_REG_ADDR + 4]
    results = int.from_bytes(results_bytes,"little") / (2**4)

    file.write(f"{hex(dac_data)},{dac_data},{hex(round(results))},{results / (2**12)}\n")

file.close()