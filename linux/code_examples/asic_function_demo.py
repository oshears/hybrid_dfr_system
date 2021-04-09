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

for i in range(16):

    dac_data = i * 0x1111
    encoded_dac_data = bytes([dac_data & 0x0F, (dac_data >> 8) & 0x0F, 0x00, 0x00])

    print(f"Writing: {hex(dac_data)}")
    print(f"Writing: {encoded_dac_data}")

    regs[ASIC_OUT_REG_ADDR : ASIC_OUT_REG_ADDR + 4] = encoded_dac_data
    regs[CTRL_REG_ADDR] = 0x1

    time.sleep(0.25)
    while(regs[CTRL_REG_ADDR] != ASIC_DONE):
        continue

    results_bytes = regs[ASIC_IN_REG_ADDR : ASIC_IN_REG_ADDR + 4]
    results = int.from_bytes(results_bytes,"little")
    print(f"Result (Bytes): {results_bytes}")
    print(f"Result: {hex(results)}")

    print("============================")