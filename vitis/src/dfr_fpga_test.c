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

#define CTRL_REG_ADDR 0x43C00000
#define DEBUG_REG_ADDR 0x43C00004
#define NUM_INIT_SAMPLES_REG_ADDR 0x43C00008
#define NUM_TRAIN_SAMPLES_REG_ADDR 0x43C0000C
#define NUM_TEST_SAMPLES_REG_ADDR 0x43C00010
#define NUM_STEPS_PER_SAMPLE_REG_ADDR 0x43C00014
#define NUM_INIT_STEPS_REG_ADDR 0x43C00018
#define NUM_TRAIN_STEPS_REG_ADDR 0x43C0001C
#define NUM_TEST_STEPS_REG_ADDR 0x43C00020

#define NUM_STEPS_PER_SAMPLE 100
#define NUM_INIT_SAMPLES 100
#define NUM_TEST_SAMPLES 100

int main2()
{
    int read_data = 0;


    init_platform();

    printf("DFR FPGA Test Project\n\r");


    while(1){

        // Configure Widths
        Xil_Out32(NUM_INIT_SAMPLES_REG_ADDR,NUM_INIT_SAMPLES);
        Xil_Out32(NUM_TRAIN_SAMPLES_REG_ADDR,0);
        Xil_Out32(NUM_TEST_SAMPLES_REG_ADDR,NUM_TEST_SAMPLES);

        Xil_Out32(NUM_INIT_STEPS_REG_ADDR,NUM_INIT_SAMPLES * NUM_STEPS_PER_SAMPLE);
        Xil_Out32(NUM_TRAIN_STEPS_REG_ADDR,0);
        Xil_Out32(NUM_TEST_STEPS_REG_ADDR,NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE);
        
        Xil_Out32(NUM_STEPS_PER_SAMPLE_REG_ADDR,NUM_STEPS_PER_SAMPLE);

        // Configure Input Samples
        //Select Input Mem
        Xil_Out32(CTRL_REG_ADDR,0x00000000);

        FILE* file = fopen ("/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/python/data/dfr_narma10_data.txt", "r");
        int i = 0;

        while (!feof (file))
        {  
            fscanf (file, "%d", &i);      
            printf ("%d ", i);
        }
        fclose (file);    


    }
    

    cleanup_platform();
    return 0;
}
