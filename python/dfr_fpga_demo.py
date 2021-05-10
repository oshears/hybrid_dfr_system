############################################################
#
#   Delay-feedback Reservoir (DFR)
#   Modified by Kangjun
#   Department of Electrical and Computer Engineering
#   Virginia Tech
#   Last modify at 06/20/2019
#
############################################################

import numpy as np
import os
# import mmap
import time

# minicom -C capturefile
# exiti minicom: esc-A X

# mem_file = os.open("/dev/uio0", os.O_SYNC | os.O_RDWR)
# asic_function_axi_addr_size = 0x10000
# asic_function_regs = mmap.mmap(mem_file, asic_function_axi_addr_size, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE, 0) 
# regs = asic_function_regs

CTRL_REG_ADDR = 0x0
ASIC_OUT_REG_ADDR = 0x4
ASIC_IN_REG_ADDR = 0x8

ASIC_DONE = 0x2

MG_FUNCTION_RESOLUTION = 65536

def load_mg_vector():
    # Open ASIC Activation Function File
    fh = open("asic_function_onboard_dac.csv",mode="r")
    
    # MG Vector
    mg_vector = np.zeros((2,MG_FUNCTION_RESOLUTION))

    # Read All Lines
    lines = fh.readlines()

    # Scale Input Data
    # scaledInData = (inData / inDataMax) * 1.8

    i = 0
    for line in lines:
        # Parse Data
        vals = line.split("\n")
        vals = vals[0].split(",")
        inVal = float(vals[0])
        outVal = float(vals[1])

        mg_vector[0,i] = inVal
        mg_vector[1,i] = outVal
        i += 1

    return mg_vector

mg_vector = load_mg_vector()

# NARMA10
def narma10_create(inLen):

    # Compute the random uniform input matrix
    inp = 0.5*np.random.rand(1, inLen)

    # Compute the target matrix
    tar = np.zeros(shape=(1, inLen))

    for k in range(10,(inLen - 1)):
        tar[0,k+1] = 0.3 * tar[0,k] + 0.05 * tar[0,k] * np.sum(tar[0,k-9:k]) + 1.5 * inp[0,k] * inp[0,k - 9] + 0.1
    
    return (inp, tar)

# ASIC Mackey-Glass Activation Function
def mackey_glass(inData):

    if inData < MG_FUNCTION_RESOLUTION:
        return mg_vector[1,int(inData)]
    else:
        return 0

# def mackey_glass_asic(inData):
#     encoded_dac_data = bytes([int(inData) & 0xFF, (int(inData) >> 8) & 0xFF, 0x00, 0x00])
#     asic_function_regs[ASIC_OUT_REG_ADDR : ASIC_OUT_REG_ADDR + 4] = encoded_dac_data
#     asic_function_regs[CTRL_REG_ADDR] = 0x1
#     while(asic_function_regs[CTRL_REG_ADDR] != ASIC_DONE):
#         continue
#     results_bytes = asic_function_regs[ASIC_IN_REG_ADDR : ASIC_IN_REG_ADDR + 4]
#     results = int.from_bytes(results_bytes,"little") / (2**4)
#     return results



##	Import dataset

# 10th order nonlinear auto-regressive moving average (NARMA10)
# seed = 0
# np.random.seed(seed)
data, target = narma10_create(5000)


##	Reservoir Parameters

# Tp        = sample/hold time frame for input (length of input mask)
# N         = number of virtual nodes in the reservoir (must equal to Tp)
# theta     = distance between virtual nodes
# gamma     = input gain
# eta       = feedback gain (leaking rate)
# initLen	= number of samples used in initialization
# trainLen	= number of samples used in training
# testLen	= number of samples used in testing

Tp          = 100
N           = Tp
theta       = Tp / N
# gamma       = 0.99
# eta         = 1 - gamma
initLen     = 0 
testLen     = 1
SCALE = 2**16
MAX_MG_OUT = 3072

##  Define the masking (input weight, choose one of the followings)

# Random Uniform [0, 1]
# Scale data for range 0 - 2^16 (65536) 
M = np.random.rand(Tp, 1) * SCALE


## (Testing) Initialize the reservoir layer

# nodeC     = reservoir dynamic at the current cycle
# nodeN     = reservoir dynamic at the next cycle
# nodeE     = reservoir dynamic at every timestep during training
# nodeTS    = a snapshot of all node states at each full rotation through 
#             the reservoir during testing

nodeC   = np.zeros(shape=(N, 1),dtype=int)
nodeN   = np.zeros(shape=(N, 1),dtype=int)
nodeE	= np.zeros(shape=(N , testLen * Tp),dtype=int)
nodeTS	= np.zeros(shape=(N , testLen),dtype=int)


i = 0

## (Testing) Initialize the reservoir layer
print("(Testing) Initialize the reservoir layer")

# No need to store these values since they won't be used in testing
for k in range(0,(initLen * Tp)):
    # Compute the new input data for initialization
    initJTS = i * 600 + (nodeC[N-1,0])
    
    # Activation
    nodeN[0,0]	= (mackey_glass(initJTS)) * (2 ** 3)
    nodeN[1:N]  = nodeC[0:(N - 1)]
    
    # Update the current node state
    nodeC       = nodeN.copy()

    i += 1



##  (Testing) Run data through the reservoir
print("(Testing) Run data through the reservoir")
for k in range(0,(testLen * Tp)):
    # Define the time step that starts storing node states
    t = initLen * Tp + k
    
    # Compute the new input data for training
    testJ = i * 600 + (nodeC[N-1,0])
    
    # Activation
    nodeN[0,0]	= (mackey_glass(testJ)) * (2 ** 3)
    nodeN[1:N]  = nodeC[0:(N - 1)]
    
    # Update the current node state
    nodeC       = nodeN.copy()
    
    # Updete all node states
    nodeE[:, k] = nodeC[:,0]

    i += 1

# Consider the data just once everytime it loops around
nodeTS[:,0:testLen] = nodeE[:, N*np.arange(1,testLen + 1)-1]
print(nodeTS)

##  Setup Weights
Wout = np.linspace(99,0,100).reshape((1,100))


predicted_target = np.dot(Wout,nodeTS)

print(predicted_target)