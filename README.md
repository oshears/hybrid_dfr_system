# Hybrid DFR System
The FPGA design for MICS' Hybrid DFR System

## Directory Organization
```
.
├── linux                   # contains the petalinux configuration information and code to use the embedded hardware interfaces
│   │
│   ├── code_examples       # contains code to use the embedded hardware interfaces
│   │
│   │   ├── asic_function   # contains code to use the ASIC function hardware
│   │   │
│   │   ├── dfr_fpga        # contains code to use the DFR accelerator hardware
│   
├── python                  # contains the Python software models used to simulate the system behavior
│   │
│   ├── data                # contains the data used to train and test the software and hardware models
│   
├── rtl                     # contains the SystemVerilog code used to build the DFR accelerator hardware
│   │
│   ├── src                 # contains the synthesizable source code used to build the DFR accelerator
│   │
│   ├── tb                  # contains the simulation source code used to verify the DFR accelerator functionality
│   
├── vitis                   # contains debugging code used to test the hardware in Vitis after implementation
│ 
├── vivado                  # contains the Vivado project scripts to develop the DFR accelerator IP cores and bitstream file
│ 
├── xdc                     # contains the constraints for the Vivado projects
```


## PMOD DAC Information
- Reference Voltage: 2.5V
- Resolution: 16 Bits
- Data Sheet: https://www.analog.com/media/en/technical-documentation/data-sheets/AD5541A.pdf
- Output Voltage Calculation:
    - Vout = (2.5 x D) / 65,536 


## XADC Information
- Reference Voltage: 1.0V
- Resolution: 12 Bits
- User Guide: https://www.xilinx.com/support/documentation/user_guides/ug480_7Series_XADC.pdf

## PetaLinux Configuration
```
petalinux-config --get-hw-description=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/asic_function_system_project/asic_function_system_wrapper.xsa
petalinux-build
petalinux-package --boot --fsbl ./images/linux/zynq_fsbl.elf --fpga /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/asic_function_system_project/asic_function_system_project.runs/impl_1/asic_function_system_wrapper.bit --u-boot --force
sudo rm -rf /media/oshears/ROOTFS/*
sudo rm -rf /media/oshears/BOOT/*
cp images/linux/BOOT.BIN /media/oshears/BOOT/
cp images/linux/image.ub /media/oshears/BOOT/
cp images/linux/boot.scr /media/oshears/BOOT/
sudo tar xvf ./images/linux/rootfs.tar.gz -C /media/oshears/ROOTFS/
sync
```