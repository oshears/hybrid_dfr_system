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

MG_FUNCTION_RESOLUTION = 2**16

MAX_INPUT = 0

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
        # scaled_input = int(MG_FUNCTION_RESOLUTION * inData)
        scaled_input = int(MG_FUNCTION_RESOLUTION * inData / MAX_INPUT )
        if scaled_input < MG_FUNCTION_RESOLUTION and scaled_input > 0:
            float_output = mg_vector[1,scaled_input] * ( (2**16) / (2**12) )
            return float_output
    
    return 0

##	Import dataset

# 10th order nonlinear auto-regressive moving average (NARMA10)
# seed = 0
# np.random.seed(seed)
data, target = narma10_create(10000)


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
gamma       = 0.8
# eta         = 1 - gamma
eta         = 1/4
initLen     = 1 
trainLen	= 5900
testLen     = 4000

##  Define the masking (input weight, choose one of the followings)

# Random Uniform [0, 1]
M = np.random.rand(Tp, 1)
# M = np.random.rand(Tp,1) * 2 - 1
# M = np.sign(M) * 0.1

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
inputTR = np.ndarray(shape=((initLen + trainLen) * Tp,1),dtype=int)

for k in range(0,(initLen + trainLen)):
    uTR = data[0,k]
    # multiply input by mask and convert to int
    masked_input = (M * uTR) * 2**16
    inputTR[k*Tp:(k+1)*Tp] = masked_input.copy()

MAX_INPUT = np.max(inputTR)

##  (Training) Initialize the reservoir layer
# No need to store these values since they won't be used in training
for k in range(0,(initLen * Tp)):
    # Compute the new input data for initialization
    initJTR = (inputTR[k,0]) + eta * (nodeC[N-1,0])
    
    # Activation
    # multiply by 8 to scale 12-bit output to 16 bits (15 bits unsigned)
    nodeN[0,0]	= (mackey_glass(initJTR))
    # nodeN[0,0]  = (1 / (1 + np.exp( 12 * (inputTR[k,0] - 0.75) ) ) ) - eta * nodeC[N-1,0]
    nodeN[1:N]  = nodeC[0:(N - 1)]
    
    # Update the current node state
    nodeC       = nodeN.copy()


##	(Training) Run data through the reservoir
for k in range(0,(trainLen * Tp)):
    # Define the time step that starts storing node states
    t = initLen * Tp + k
    
    # Compute the new input data for training
    trainJ = (inputTR[t,0]) + eta * (nodeC[N-1,0])
    
    # Activation
    nodeN[0,0]	= (mackey_glass(trainJ))
    # nodeN[0,0]  = (1 / (1 + np.exp( 12 * (inputTR[k,0] - 0.75) ) ) ) - eta * nodeC[N-1,0]
    nodeN[1:N]  = nodeC[0:(N - 1)]
    
    # Update the current node state
    nodeC       = nodeN.copy()
    
    # Updete all node states
    nodeE[:, k] = nodeC[:,0]



# Consider the data just once everytime it loops around
nodeTR[:,0:trainLen] = nodeE[:, N*np.arange(1,trainLen + 1)-1]

##  Train output weights using ridge regression

# Call-out the target outputs
# Scale to put the data in the same range as input
Yt = target[0,initLen:(initLen + trainLen)].reshape(1,trainLen) * 2**32

# Transpose nodeR for matrix claculation
nodeTR_T = nodeTR.T

# Calculate output weights
reg = 1e-8
# Wout = np.dot(np.dot(Yt,nodeTR_T),np.linalg.inv((np.dot(nodeTR,nodeTR_T))))
Wout = np.dot(np.dot(Yt,nodeTR_T),np.linalg.inv((np.dot(nodeTR,nodeTR_T)) + reg * np.eye(N)))
Wout = np.round(Wout)

##  Compute training error
predicted_target = np.dot(Wout,nodeTR)

# Calculate the MSE through L2 norm
mseTR = (((Yt - predicted_target)**2).mean(axis=1))

# Calculate the NMSE
nmseTR  = (np.linalg.norm(Yt - predicted_target) / np.linalg.norm(Yt))**2
nrmseTR = (np.linalg.norm(Yt - predicted_target) / np.linalg.norm(Yt))
# nmseTR  =         np.sum((Yt - predicted_target)**2 / np.var(Yt)) / Yt.size
# nrmseTR = np.sqrt(np.sum((Yt - predicted_target)**2 / np.var(Yt)) / Yt.size)

print('--------------------------------------------------')
print('Training Errors')
print(f'training MSE     = {mseTR[0]}')
print(f'training NMSE    = {nmseTR}')
# print(f'training NRMSE    = {nrmseTR}')


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


##  (Testing) Apply masking to input testing data
inputTS = np.ndarray(shape=((initLen + testLen) * Tp,1),dtype=int)

for k in range(0,(initLen + testLen)):
    uTS = data[0,initLen + trainLen + k]
    masked_input = (M * uTS) * 2**16
    inputTS[k*Tp:(k+1)*Tp] = masked_input.copy()


## (Testing) Initialize the reservoir layer

# No need to store these values since they won't be used in testing
for k in range(0,(initLen * Tp)):

    # Compute the new input data for initialization
    initJTS = (inputTS[k,0]) + eta * (nodeC[N-1,0])
    
    # Activation
    nodeN[0,0]	= (mackey_glass(initJTS))
    # nodeN[0,0]  = (1 / (1 + np.exp( 12 * (inputTS[k,0] - 0.75) ) ) ) - eta * nodeC[N-1,0]
    nodeN[1:N]  = nodeC[0:(N - 1)]
    
    # Update the current node state
    nodeC       = nodeN.copy()



##  (Testing) Run data through the reservoir
for k in range(0,(testLen * Tp)):
    # Define the time step that starts storing node states
    t = initLen * Tp + k
    
    # Compute the new input data for training
    testJ = (inputTS[t,0]) + eta * (nodeC[N-1,0])
    
    # Activation
    nodeN[0,0]	= (mackey_glass(testJ))
    # nodeN[0,0]  = (1 / (1 + np.exp( 12 * (inputTS[k,0] - 0.75) ) ) ) - eta * nodeC[N-1,0]
    nodeN[1:N]  = nodeC[0:(N - 1)]
    
    # Update the current node state
    nodeC       = nodeN.copy()
    
    # Updete all node states
    nodeE[:, k] = nodeC[:,0]



# Consider the data just once everytime it loops around
nodeTS[:,0:testLen] = nodeE[:, N*np.arange(1,testLen + 1)-1]


##  Compute testing errors

# Call-out the target outputs
Yt = target[0,initLen + trainLen + initLen + 1 : initLen + trainLen + initLen + 1 + testLen].reshape(1,testLen) * 2**32

predicted_target = np.dot(Wout,nodeTS)

# Calculate the MSE through L2 norm
mse_testing = (((Yt - predicted_target)**2).mean(axis=1))

# Calculate the NMSE
nmse_testing  = (np.linalg.norm(Yt - predicted_target) / np.linalg.norm(Yt))**2
nrmse_testing = (np.linalg.norm(Yt - predicted_target) / np.linalg.norm(Yt))
# nmse_testing  =         np.sum((Yt - predicted_target)**2 / np.var(Yt)) / Yt.size
# nrmse_testing = np.sqrt(np.sum((Yt - predicted_target)**2 / np.var(Yt)) / Yt.size)

print('--------------------------------------------------')
print('Testing Errors')
print(f'testing MSE     = {mse_testing[0]}')
print(f'testing NMSE    = {nmse_testing}')
# print(f'testing NRMSE    = {nrmse_testing}')


### Write Data for Hybrid System Simulation ###
# Save Inputs
masked_input = np.concatenate((inputTR,inputTS))
fh = open("./data/narma10/dfr_sw_int_narma10_inputs.txt","w")
for i in range(masked_input.size):
    fh.write(f"{masked_input[i,0]}\n")
fh.close()

# Save Reservoir Outputs
fh = open("./data/narma10/dfr_sw_int_narma10_reservoir_outputs.txt","w")
for input_idx in range(nodeTS.shape[1]):
    for sample_idx in range(nodeTS.shape[0]):
        fh.write(f"{nodeTS[sample_idx,input_idx]}\n")
fh.close()

# Save Weights
fh = open("./data/narma10/dfr_sw_int_narma10_weights.txt","w")
for i in range(Wout.size):
    fh.write(f"{int(Wout[0,i])}\n")
fh.close()

# Save DFR Outputs
fh = open("./data/narma10/dfr_sw_int_narma10_dfr_outputs.txt","w")
for i in range(predicted_target.size):
    fh.write(f"{predicted_target[0,i]}\n")
fh.close()

# DFR: An Energy-efficient Analog Delay Feedback Reservoir Computing System
# Table 2. Performance Comparison in Different Models
#                           Model   Training Error (NRMSE)  Testing Error(NRMSE)    Error Rate Reduction
# (Rodan and Tino2011)      ESN     /                       0.1075                  36.5%
# (Appeltant et al.2011)    DFR     /                       0.15                    54.5%
# (Goudarzi et al.2014)     DFR     0.065                   0.464                   85.3%
# (Ortín and Pesquera2017)  DFR     /                       0.17                    59.8%
# This Work                 DFR     0.0849                  0.0683                  /



'''
--------------------------------------------------
Training Errors
training MSE     = 0.007536716963330973
training NMSE    = 0.05501284837934046
training NRMSE    = 0.23454817922836335
--------------------------------------------------
Testing Errors
testing MSE     = 0.010291252049471808
testing NMSE    = 0.07304348311498177
testing NRMSE    = 0.2702655788571341
'''