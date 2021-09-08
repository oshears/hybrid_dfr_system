// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================
/***************************** Include Files *********************************/
#include "xdfr_inference.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XDfr_inference_CfgInitialize(XDfr_inference *InstancePtr, XDfr_inference_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XDfr_inference_Start(XDfr_inference *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XDfr_inference_ReadReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_AP_CTRL) & 0x80;
    XDfr_inference_WriteReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XDfr_inference_IsDone(XDfr_inference *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XDfr_inference_ReadReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XDfr_inference_IsIdle(XDfr_inference *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XDfr_inference_ReadReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XDfr_inference_IsReady(XDfr_inference *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XDfr_inference_ReadReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XDfr_inference_EnableAutoRestart(XDfr_inference *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XDfr_inference_WriteReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XDfr_inference_DisableAutoRestart(XDfr_inference *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XDfr_inference_WriteReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_AP_CTRL, 0);
}

void XDfr_inference_InterruptGlobalEnable(XDfr_inference *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XDfr_inference_WriteReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_GIE, 1);
}

void XDfr_inference_InterruptGlobalDisable(XDfr_inference *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XDfr_inference_WriteReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_GIE, 0);
}

void XDfr_inference_InterruptEnable(XDfr_inference *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XDfr_inference_ReadReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_IER);
    XDfr_inference_WriteReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_IER, Register | Mask);
}

void XDfr_inference_InterruptDisable(XDfr_inference *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XDfr_inference_ReadReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_IER);
    XDfr_inference_WriteReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_IER, Register & (~Mask));
}

void XDfr_inference_InterruptClear(XDfr_inference *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XDfr_inference_WriteReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_ISR, Mask);
}

u32 XDfr_inference_InterruptGetEnabled(XDfr_inference *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XDfr_inference_ReadReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_IER);
}

u32 XDfr_inference_InterruptGetStatus(XDfr_inference *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XDfr_inference_ReadReg(InstancePtr->Control_BaseAddress, XDFR_INFERENCE_CONTROL_ADDR_ISR);
}

