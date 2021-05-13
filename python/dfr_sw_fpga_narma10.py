############################################################
#
#   Delay-feedback Reservoir (DFR)
#   NARMA-10 (Int)
#
############################################################

import numpy as np

MG_FUNCTION_RESOLUTION = 2**16

MAX_INPUT = 2**15

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

# ASIC Mackey-Glass Activation Function
def mackey_glass(inData):

    if inData < MG_FUNCTION_RESOLUTION:
        # scaled_input = int(MG_FUNCTION_RESOLUTION * inData)
        scaled_input = int(MG_FUNCTION_RESOLUTION * inData / MAX_INPUT )
        if scaled_input < MG_FUNCTION_RESOLUTION and scaled_input > 0:
            float_output = mg_vector[1,scaled_input] * ( (2**16) / (2**12) )
            return float_output
    
    return 0

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

# Load DFR Input Samples
inputTS = np.ndarray(shape=((initLen + testLen) * Tp,1),dtype=int)
input_cntr = 0
fh = open("./data/narma10/dfr_sw_int_narma10_inputs.txt","r")
file_lines = fh.readlines()
for file_line in file_lines:
    if input_cntr < initLen + testLen:
        input_sample = int(file_line.strip())
        inputTS[input_cntr,0] = input_sample
    input_cntr += 1

# Load Weight Data
Wout = np.ndarray(shape=(1,N),dtype=int)
weight_cntr = 0
fh = open("./data/narma10/dfr_sw_int_narma10_weights.txt","r")
for file_line in file_lines:
    if weight_cntr < N:
        input_weight = int(file_line.strip())
        Wout[0,weight_cntr] = input_weight
    weight_cntr += 1


# No need to store these values since they won't be used in testing
for k in range(0,(initLen * Tp)):

    # Compute the new input data for initialization
    initJTS = (inputTS[k,0]) + eta * (nodeC[N-1,0])
    
    # Activation
    nodeN[0,0]	= (mackey_glass(initJTS))
    nodeN[1:N]  = nodeC[0:(N - 1)]
    if k == 0:
        print(100*"=")
        print(inputTS[k,0])
        print(nodeC[N-1,0])
        print(initJTS)
        print(nodeN[0,0])
    
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
    nodeN[1:N]  = nodeC[0:(N - 1)]
    if k == 0:
        print(100*"=")
        print(inputTS[t,0])
        print(nodeC[N-1,0])
        print(testJ)
        print(nodeN[0,0])

    # Update the current node state
    nodeC       = nodeN.copy()
    
    # Updete all node states
    nodeE[:, k] = nodeC[:,0]



# Consider the data just once everytime it loops around
nodeTS[:,0:testLen] = nodeE[:, N*np.arange(1,testLen + 1)-1]

##  Compute testing errors

# Call-out the target outputs
# Yt = target[0,initLen + trainLen + initLen + 1 : initLen + trainLen + initLen + 1 + testLen].reshape(1,testLen) * 2**32
Yt = np.ndarray(shape=(1,testLen))
expected_output_cntr = 0
fh = open("./data/narma10/dfr_sw_int_narma10_expected_dfr_outputs.txt","r")
file_lines = fh.readlines()
for file_line in file_lines:
    if expected_output_cntr < testLen:
        Yt[0,expected_output_cntr] = float(file_line.strip())
    expected_output_cntr += 1
    

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


# DFR: An Energy-efficient Analog Delay Feedback Reservoir Computing System
# Table 2. Performance Comparison in Different Models
#                           Model   Training Error (NRMSE)  Testing Error(NRMSE)    Error Rate Reduction
# (Rodan and Tino2011)      ESN     /                       0.1075                  36.5%
# (Appeltant et al.2011)    DFR     /                       0.15                    54.5%
# (Goudarzi et al.2014)     DFR     0.065                   0.464                   85.3%
# (Ortín and Pesquera2017)  DFR     /                       0.17                    59.8%
# This Work                 DFR     0.0849                  0.0683                  /
