// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xdfr_inference.h"

extern XDfr_inference_Config XDfr_inference_ConfigTable[];

XDfr_inference_Config *XDfr_inference_LookupConfig(u16 DeviceId) {
	XDfr_inference_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XDFR_INFERENCE_NUM_INSTANCES; Index++) {
		if (XDfr_inference_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XDfr_inference_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XDfr_inference_Initialize(XDfr_inference *InstancePtr, u16 DeviceId) {
	XDfr_inference_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XDfr_inference_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XDfr_inference_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif

