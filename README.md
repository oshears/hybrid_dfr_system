# Hybrid DFR System
The FPGA design for MICS' Hybrid DFR System


# Notes
## PMOD Dac
- Reference Voltage: 2.5V
- Resolution: 16 Bits
- Data Sheet: https://www.analog.com/media/en/technical-documentation/data-sheets/AD5541A.pdf
- Output Voltage Calculation:
    - Vout = (2.5 x D) / 65,536 
## XADC
- Reference Voltage: 1.0V
- Resolution: 12 Bits
- User Guide: https://www.xilinx.com/support/documentation/user_guides/ug480_7Series_XADC.pdf