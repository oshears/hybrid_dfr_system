/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include <stdio.h>
#include "xil_io.h"
#include "sleep.h"

#define CTRL_REG_ADDR 0x40000000
#define DEBUG_REG_ADDR 0x40000004
#define NUM_INIT_SAMPLES_REG_ADDR 0x40000008
#define NUM_TRAIN_SAMPLES_REG_ADDR 0x4000000C
#define NUM_TEST_SAMPLES_REG_ADDR 0x40000010
#define NUM_STEPS_PER_SAMPLE_REG_ADDR 0x40000014
#define NUM_INIT_STEPS_REG_ADDR 0x40000018
#define NUM_TRAIN_STEPS_REG_ADDR 0x4000001C
#define NUM_TEST_STEPS_REG_ADDR 0x40000020

#define DFR_INPUT_MEM_ADDR_OFFSET 0x41000000
#define DFR_RESERVOIR_ADDR_MEM_OFFSET 0x42000000
#define DFR_WEIGHT_MEM_ADDR_OFFSET 0x43000000
#define DFR_OUTPUT_MEM_ADDR_OFFSET 0x44000000

#define NUM_STEPS_PER_SAMPLE 100
#define NUM_INIT_SAMPLES 1
#define NUM_TEST_SAMPLES 1

#define NUM_VIRTUAL_NODES 100

int main2()
{
    int read_data = 0;


    init_platform();

    printf("==============================================================\n\r");
    printf("DFR FPGA Test Project\n\r");


    // Configure Widths
    Xil_Out32(NUM_INIT_SAMPLES_REG_ADDR,NUM_INIT_SAMPLES);
    read_data = Xil_In32(NUM_INIT_SAMPLES_REG_ADDR);
    printf("NUM_INIT_SAMPLES_REG_ADDR: %d\n\r",read_data);
    Xil_Out32(NUM_TRAIN_SAMPLES_REG_ADDR,0);
    read_data = Xil_In32(NUM_TRAIN_SAMPLES_REG_ADDR);
    printf("NUM_TRAIN_SAMPLES_REG_ADDR: %d\n\r",read_data);
    Xil_Out32(NUM_TEST_SAMPLES_REG_ADDR,NUM_TEST_SAMPLES);
    read_data = Xil_In32(NUM_TEST_SAMPLES_REG_ADDR);
    printf("NUM_TEST_SAMPLES_REG_ADDR: %d\n\r",read_data);

    Xil_Out32(NUM_INIT_STEPS_REG_ADDR,NUM_INIT_SAMPLES * NUM_STEPS_PER_SAMPLE);
    read_data = Xil_In32(NUM_INIT_STEPS_REG_ADDR);
    printf("NUM_INIT_STEPS_REG_ADDR: %d\n\r",read_data);
    Xil_Out32(NUM_TRAIN_STEPS_REG_ADDR,0);
    read_data = Xil_In32(NUM_TRAIN_STEPS_REG_ADDR);
    printf("NUM_TRAIN_STEPS_REG_ADDR: %d\n\r",read_data);
    Xil_Out32(NUM_TEST_STEPS_REG_ADDR,NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE);
    read_data = Xil_In32(NUM_TEST_STEPS_REG_ADDR);
    printf("NUM_TEST_STEPS_REG_ADDR: %d\n\r",read_data);
    
    Xil_Out32(NUM_STEPS_PER_SAMPLE_REG_ADDR,NUM_STEPS_PER_SAMPLE);
    read_data = Xil_In32(NUM_STEPS_PER_SAMPLE_REG_ADDR);
    printf("NUM_STEPS_PER_SAMPLE_REG_ADDR: %d\n\r",read_data);

    int i = 0;

    // Configure Input Mem
    printf("Configuring Input Mem\n\r");
    for (i = 0; i < (NUM_INIT_SAMPLES + NUM_TEST_SAMPLES) * NUM_STEPS_PER_SAMPLE; i = i + 1){
        Xil_Out32(DFR_INPUT_MEM_ADDR_OFFSET + i * 4, i*300);
        read_data = Xil_In32(DFR_INPUT_MEM_ADDR_OFFSET + i * 4);
        printf("Read Input: %d\n\r",read_data);
    }

    // Configure Weights
    printf("Configuring Weights\n\r");
    for (i = 0; i < NUM_VIRTUAL_NODES; i = i + 1){
        Xil_Out32(DFR_WEIGHT_MEM_ADDR_OFFSET + i * 4, i);
        read_data = Xil_In32(DFR_WEIGHT_MEM_ADDR_OFFSET + i * 4);
        printf("Read Weight: %d\n\r",read_data);
    }

    // Launch DFR
    printf("Launching DFR\n\r");
    Xil_Out32(CTRL_REG_ADDR,0x1);

    read_data = Xil_In32(CTRL_REG_ADDR);
    while(read_data & 0x2 != 0){
        read_data = Xil_In32(CTRL_REG_ADDR);
        printf("CTRL_REG: %x\n\r",read_data);
    }

    read_data = Xil_In32(DEBUG_REG_ADDR);
    printf("Read Debug Reg: %x\n\r",read_data);

    for (i = 0; i < NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE; i = i + 1){
        read_data = Xil_In32(DFR_RESERVOIR_ADDR_MEM_OFFSET + i * 4);
        printf("Read Reservoir Output: %d\n\r",read_data);
    }

    for (i = 0; i < NUM_TEST_SAMPLES; i = i + 1){
        read_data = Xil_In32(DFR_OUTPUT_MEM_ADDR_OFFSET + i * 4);
        printf("Read DFR Output: %d\n\r",read_data);
    }


    printf("Done...\n\r");
    
    cleanup_platform();
    return 0;
}
