
#2.5V (1.8V)
dac_data = 0xFFFF
regs[ASIC_OUT_REG_ADDR : ASIC_OUT_REG_ADDR + 4] = bytes([dac_data & 0xFF, (dac_data >> 8) & 0xFF, 0x00, 0x00])
regs[CTRL_REG_ADDR] = 0x1

results_bytes = asic_function_regs[ASIC_IN_REG_ADDR : ASIC_IN_REG_ADDR + 4]
results = int.from_bytes(results_bytes,"little") / (2**4)