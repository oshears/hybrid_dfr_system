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

#define CTLR_REG_ADDR 0x43C00000
#define ASIC_DATA_OUT_REG_ADDR 0x43C00004
#define ASIC_DATA_IN_REG_ADDR 0x43C00008

int main()
{
    int read_data = 0;


    init_platform();

    printf("Test Project\n\r");


    while(1){
        // printf("Writing to CTLR_REG\n\r");
        // Xil_Out32(CTLR_REG_ADDR, 0xBEEF);

        // printf("Writing to ASIC_DATA_OUT_REG\n\r");
        // Xil_Out32(ASIC_DATA_OUT_REG_ADDR, 0xBEEF);

        // printf("Writing to ASIC_DATA_IN_REG\n\r");
        // Xil_Out32(ASIC_DATA_IN_REG_ADDR, 0xBEEF);

        int i;
        for (i = 0; i < 0x10000; i = i + 0x1000){
            
            printf("Writing %x to ASIC_DATA_OUT_REG\n\r",i);
            Xil_Out32(ASIC_DATA_OUT_REG_ADDR, i);

            printf("Writing to CTLR_REG\n\r");
            Xil_Out32(CTLR_REG_ADDR, 0x1);

            while(read_data == 0){
                read_data = Xil_In32(CTLR_REG_ADDR);
            }
            printf("Reading from CTLR_REG_ADDR\n\r");
            printf("Read: %x\n\r",read_data);

            printf("Reading from ASIC_DATA_IN_REG\n\r");
            read_data = Xil_In32(ASIC_DATA_IN_REG_ADDR);
            printf("Read: %x\n\r",read_data);

            sleep(1);
        }

    }
    

    cleanup_platform();
    return 0;
}
