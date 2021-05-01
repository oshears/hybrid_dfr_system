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
import mmap
import time

mem_file = os.open("/dev/uio0", os.O_SYNC | os.O_RDWR)
asic_function_axi_addr_size = 0x10000
asic_function_regs = mmap.mmap(mem_file, asic_function_axi_addr_size, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE, 0) 
regs = asic_function_regs

CTRL_REG_ADDR = 0x0
ASIC_OUT_REG_ADDR = 0x4
ASIC_IN_REG_ADDR = 0x8

ASIC_DONE = 0x2

# NARMA10
def narma10_create(inLen, seedRan=-1):
    # if (nargin > 1)
    #    rng(seedRan);

    # Compute the random uniform input matrix
    inp = 0.5*np.random.rand(1, inLen)

    # Compute the target matrix
    tar = np.zeros(shape=(1, inLen))

    for k in range(10,(inLen - 1)):
        tar[0,k+1] = 0.3 * tar[0,k] + 0.05 * tar[0,k] * np.sum(tar[0,k-9:k]) + 1.5 * inp[0,k] * inp[0,k - 9] + 0.1
    
    return (inp, tar)

# ASIC Mackey-Glass Activation Function
def mackey_glass_asic(inData):

    dac_data = int(inData)

    encoded_dac_data = bytes([dac_data & 0xFF, (dac_data >> 8) & 0xFF, 0x00, 0x00])

    regs[ASIC_OUT_REG_ADDR : ASIC_OUT_REG_ADDR + 4] = encoded_dac_data
    regs[CTRL_REG_ADDR] = 0x1

    while(regs[CTRL_REG_ADDR] != ASIC_DONE):
        continue

    results_bytes = regs[ASIC_IN_REG_ADDR : ASIC_IN_REG_ADDR + 4]
    results = int.from_bytes(results_bytes,"little") / (2**4)

    #print(f"mg({dac_data}) = mg({hex(dac_data)}) = {results}")

    return results
    

##	Import dataset

# 10th order nonlinear auto-regressive moving average (NARMA10)
seed = 9
# 5, 9
np.random.seed(seed)
data, target = narma10_create(2000, seed)

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
initLen     = 100   
trainLen	= 1000
testLen     = 100
SCALE = 2**16
MAX_MG_OUT = 3072

##  Define the masking (input weight, choose one of the followings)

# Random Uniform [-1, 1]
# M = np.random.rand(Tp, 1) * 2 - 1

# Random Uniform [0, 1]
# M = rand(Tp, 1)
M = np.random.rand(Tp, 1) * SCALE

# Random from group [-0.1, +0.1]
# M = rand(Tp, 1) * 2 - 1
# M = sign(M) * 0.1

# Random normal
# M = randn(Tp, 1) * 1

# Constant
# M = ones(Tp, 1) * 0.5
# M = np.ones((Tp, 1)) * SCALE

# Linearly cover [-1, 1]
# M = linspace(-1, 1, Tp)

# Linearly cover, with added random perturbation
# M = linspace(-1, 1, Tp)
# M = M + randn(size(M)) * 0.05


##  (Training) Initialization of reservoir dynamics

# nodeC     = reservoir dynamic at the current cycle
# nodeN     = reservoir dynamic at the next cycle
# nodeE     = reservoir dynamic at every timestep during training
# nodeTR    = a snapshot of all node states at each full rotation through 
#             the reservoir during training

nodeC   = np.zeros(shape=(N, 1),dtype=int)
nodeN   = np.zeros(shape=(N, 1),dtype=int)
nodeE	= np.zeros(shape=(N , trainLen * Tp),dtype=int)
nodeTR	= np.zeros(shape=(N , trainLen),dtype=int)


##  (Training) Apply masking to training data

inputTR = np.ndarray(shape=((initLen + trainLen) * Tp,1))

##  (Training) Initialize the reservoir layer

# No need to store these values since they won't be used in training

for k in range(0,(initLen * Tp)):
    # Compute the new input data for initialization
    # initJTR = (gamma * inputTR[k,0]) + (eta * nodeC[N-1,0])
    initJTR = (inputTR[k,0]) + (nodeC[N-1,0])
    
    # Activation
    # nodeN[0,0]	= (np.tanh(initJTR / SCALE) * SCALE).astype(int)   
    # nodeN[0,0]	= (mackey_glass_fpga(initJTR)) * ( (SCALE / 2) / MAX_MG_OUT)
    nodeN[0,0]	= (mackey_glass_asic(initJTR)) * (2 ** 3)
    # print(nodeN[0,0]) #OK
    # print(nodeN[N - 1,0]) #OK
    # print(f" mg({inputTR[k,0]} + {nodeC[N-1,0]}) = {mackey_glass_fpga(initJTR)} => {nodeN[0,0]}") #OK
    nodeN[1:N]  = nodeC[0:(N - 1)]
    
    # Update the current node state
    nodeC       = nodeN.copy()


##	(Training) Run data through the reservoir

for k in range(0,(trainLen * Tp)):
    # Define the time step that starts storing node states
    t = initLen * Tp + k
    
    # Compute the new input data for training
    # trainJ = (gamma * inputTR[t,0]) + (eta * nodeC[N-1,0])
    trainJ = (inputTR[t,0]) + (nodeC[N-1,0])
    
    # Activation
    # nodeN[0,0]	= (np.tanh(trainJ / SCALE) * SCALE).astype(int)   
    # nodeN[0,0]	= (mackey_glass_fpga(trainJ)) * ( (SCALE / 2) / MAX_MG_OUT)
    nodeN[0,0]	= (mackey_glass_asic(trainJ)) * (2 ** 3)
    # print(f" mg({inputTR[t,0]} + {nodeC[N-1,0]}) = {mackey_glass_fpga(trainJ)} => {nodeN[0,0]}") #OK
    #nodeN[1,0]	= mackey_glass_asic(trainJ)	
    # print(nodeN[0,0]) #OK
    nodeN[1:N]  = nodeC[0:(N - 1)]
    # print(nodeN[N - 1,0]) #OK
    
    # Update the current node state
    nodeC       = nodeN.copy()
    
    # Updete all node states
    nodeE[:, k] = nodeC[:,0]


# Consider the data just once everytime it loops around
nodeTR[:,0:trainLen] = nodeE[:, N*np.arange(1,trainLen + 1)-1]
##  Train output weights using ridge regression

# Call-out the target outputs
# Yt = target[0,initLen:(initLen + trainLen)].reshape(1,trainLen)
Yt = target[0,initLen:(initLen + trainLen)].reshape(1,trainLen) * SCALE
# Yt = Yt.astype(int)  
# print(Yt)

# Transpose nodeR for matrix claculation
# nodeTR = nodeTR / SCALE
# Higher Accuracy:
# nodeTR = np.round(nodeTR / SCALE, 4)
# nodeTR = np.round(nodeTR / SCALE, 4)
nodeTR_T = nodeTR.T
# print(nodeTR) #OK

# Calculate output weights
# Wout = np.dot(Yt,nodeTR_T) / (np.dot(nodeTR,nodeTR_T) + (regC * np.eye(N)))
# print(np.dot(Yt,nodeTR_T)) #OK
# print(np.dot(nodeTR,nodeTR_T)) #OK
# print(np.linalg.inv((np.dot(nodeTR,nodeTR_T))))
# print(np.dot(np.dot(Yt,nodeTR_T),np.linalg.inv((np.dot(nodeTR,nodeTR_T) + (regC * np.eye(N))))))
# Wout = np.dot(np.dot(Yt,nodeTR_T),np.linalg.inv((np.dot(nodeTR,nodeTR_T) + (regC * np.eye(N)))))
Wout = np.dot(np.dot(Yt,nodeTR_T),np.linalg.inv((np.dot(nodeTR,nodeTR_T))))
# Wout = Wout.astype(int)  
Wout = np.round(Wout, 4)
# print(Wout)
# print(Wout.shape)

# High Accuracy:
# Wout_int = Wout * (10 ** 4)
# Wout_int = Wout_int.astype(int)
# nodeTR_int = nodeTR * (10 ** 4)
# nodeTR_int = nodeTR_int.astype(int)

ROUND_FACTOR = 0
Wout_int = Wout * (10 ** ROUND_FACTOR)
Wout_int = Wout_int.astype(int)
nodeTR_int = nodeTR * (10 ** ROUND_FACTOR)
nodeTR_int = nodeTR_int.astype(int)

# Lower Accuracy:
# Wout_int = Wout 
# Wout_int = Wout_int.astype(int)
# nodeTR_int = nodeTR 
# nodeTR_int = nodeTR_int.astype(int)

##  Compute training error


# predicted_target = np.dot(Wout,nodeTR)
predicted_target_int = np.dot(Wout_int,nodeTR_int)
print(Wout_int)
print(nodeTR_int[:,0])
print(predicted_target_int[0])
predicted_target = predicted_target_int / (10 ** (ROUND_FACTOR * 2))
#expected fpga outputs

# Calculate the MSE through L2 norm
mseTR = (((Yt - predicted_target)**2).mean(axis=1))

# Calculate the NMSE
nmseTR = (np.linalg.norm(Yt - predicted_target) / np.linalg.norm(Yt))**2

print('--------------------------------------------------')
print('Training Errors')
print(f'training MSE     = {mseTR[0]}')
print(f'training NMSE    = {nmseTR}')

