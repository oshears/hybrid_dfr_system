import os
import mmap
import time


mem_file = os.open("/dev/uio0", os.O_SYNC | os.O_RDWR)
asic_function_axi_addr_size = 0x10000
asic_function_regs = mmap.mmap(mem_file, asic_function_axi_addr_size, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE, 0) 
regs = asic_function_regs

CTRL_REG_ADDR = 0x0
ASIC_OUT_REG_ADDR = 0x4
ASIC_IN_REG_ADDR = 0x8

ASIC_DONE = 0x2

dac_data = 0
for i in range(16):

    print(f"Writing: {hex(dac_data)}; {(dac_data * 2.5) / (2**16)} V")
    encoded_dac_data = bytes([dac_data & 0xFF, (dac_data >> 8) & 0xFF, 0x00, 0x00])
    regs[ASIC_OUT_REG_ADDR : ASIC_OUT_REG_ADDR + 4] = encoded_dac_data
    results = []
    for j in range(16):
        

        regs[CTRL_REG_ADDR] = 0x1

        while(regs[CTRL_REG_ADDR] != ASIC_DONE):
            continue

        results_bytes = regs[ASIC_IN_REG_ADDR : ASIC_IN_REG_ADDR + 4]
        results.append(int.from_bytes(results_bytes,"little"))

    
    for j in range(16):
        print(f"Result {hex(results[j] >> 4)}; {(results[j] >> 4) / (2**12)} V @ {times[j] - start_time}")

    print("============================")

    dac_data = (i+1) * 0x1111