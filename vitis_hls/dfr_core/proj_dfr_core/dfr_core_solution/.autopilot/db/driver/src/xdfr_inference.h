// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef XDFR_INFERENCE_H
#define XDFR_INFERENCE_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xdfr_inference_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
#else
typedef struct {
    u16 DeviceId;
    u32 Control_BaseAddress;
} XDfr_inference_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u32 IsReady;
} XDfr_inference;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XDfr_inference_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XDfr_inference_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XDfr_inference_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XDfr_inference_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
int XDfr_inference_Initialize(XDfr_inference *InstancePtr, u16 DeviceId);
XDfr_inference_Config* XDfr_inference_LookupConfig(u16 DeviceId);
int XDfr_inference_CfgInitialize(XDfr_inference *InstancePtr, XDfr_inference_Config *ConfigPtr);
#else
int XDfr_inference_Initialize(XDfr_inference *InstancePtr, const char* InstanceName);
int XDfr_inference_Release(XDfr_inference *InstancePtr);
#endif

void XDfr_inference_Start(XDfr_inference *InstancePtr);
u32 XDfr_inference_IsDone(XDfr_inference *InstancePtr);
u32 XDfr_inference_IsIdle(XDfr_inference *InstancePtr);
u32 XDfr_inference_IsReady(XDfr_inference *InstancePtr);
void XDfr_inference_EnableAutoRestart(XDfr_inference *InstancePtr);
void XDfr_inference_DisableAutoRestart(XDfr_inference *InstancePtr);


void XDfr_inference_InterruptGlobalEnable(XDfr_inference *InstancePtr);
void XDfr_inference_InterruptGlobalDisable(XDfr_inference *InstancePtr);
void XDfr_inference_InterruptEnable(XDfr_inference *InstancePtr, u32 Mask);
void XDfr_inference_InterruptDisable(XDfr_inference *InstancePtr, u32 Mask);
void XDfr_inference_InterruptClear(XDfr_inference *InstancePtr, u32 Mask);
u32 XDfr_inference_InterruptGetEnabled(XDfr_inference *InstancePtr);
u32 XDfr_inference_InterruptGetStatus(XDfr_inference *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
