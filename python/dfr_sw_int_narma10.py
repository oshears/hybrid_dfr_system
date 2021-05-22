############################################################
#
#   Delay-feedback Reservoir (DFR)
#   NARMA-10 (Int)
#
############################################################

import numpy as np

MG_FUNCTION_RESOLUTION = 2**16

MAX_INPUT = 2**16

MAX_MG_OUTPUT = 2**12

YT_SCALE = 2**32


# ASIC Mackey-Glass Activation Function
mg_vector = np.genfromtxt("./data/asic_function_onboard_dac.csv", delimiter=",").T

def mackey_glass(inData):

    # scaled the input based on the max MG function input (MG_FUNCTION_RESOLUTION)
    # and the max input data value
    scaled_input = int(inData) & (MG_FUNCTION_RESOLUTION - 1)

    # if the scaled result is in the range of the MG function
    if scaled_input < MG_FUNCTION_RESOLUTION and scaled_input >= 0:
        
        # scale the output back within the range of the max input values
        int_output = MAX_INPUT * ( mg_vector[1,scaled_input] / MAX_MG_OUTPUT )
        return int_output
    
    return 0

# NARMA10
def narma10_create(inLen):

    # Compute the random uniform input matrix
    inp = 0.5*np.random.rand(1, inLen)

    # Compute the target matrix
    tar = np.zeros(shape=(1, inLen))

    for k in range(10,(inLen - 1)):
        tar[0,k+1] = 0.3 * tar[0,k] + 0.05 * tar[0,k] * np.sum(tar[0,k-9:k]) + 1.5 * inp[0,k] * inp[0,k - 9] + 0.1
    
    return (inp, tar)

##	Import dataset

# 10th order nonlinear auto-regressive moving average (NARMA10)
seed = 0
np.random.seed(seed)
data, target = narma10_create(10100)


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
gamma       = 1
# eta         = 1 - gamma
eta         = 1/2
initLen     = 100 
trainLen	= 5900
testLen     = 4000

##  Define the masking (input weight, choose one of the followings)

# Random Uniform [0, MAX_INPUT]
M = np.random.rand(Tp, 1) * MAX_INPUT

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
    masked_input = (M * uTR)
    inputTR[k*Tp:(k+1)*Tp] = masked_input.copy()

##  (Training) Initialize the reservoir layer
# No need to store these values since they won't be used in training
for k in range(0,(initLen * Tp)):
    # Compute the new input data for initialization
    initJTR = (inputTR[k,0]) + eta * (nodeC[N-1,0])
    
    # Activation
    # multiply by 8 to scale 12-bit output to 16 bits (15 bits unsigned)
    nodeN[0,0]	= (mackey_glass(initJTR))
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
Yt = target[0,initLen:(initLen + trainLen)].reshape(1,trainLen) * YT_SCALE

# Transpose nodeR for matrix claculation
nodeTR_T = nodeTR.T

# Calculate output weights
# initialize regularization coefficient
reg = 1e8
Wout = np.round( np.dot(np.dot(Yt,nodeTR_T),np.linalg.inv((np.dot(nodeTR,nodeTR_T)) + reg * np.eye(N))) )


# Calculate the NMSE
predicted_target = np.dot(Wout,nodeTR)
mse   = np.sum(np.power(Yt - predicted_target,2)) / Yt.size
nrmse = (np.linalg.norm(Yt - predicted_target) / np.linalg.norm(Yt))

print('--------------------------------------------------')
print('Training Errors')
print(f'training mse: {mse}')
print(f'training nrmse: {nrmse}')


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
    masked_input = (M * uTS)
    inputTS[k*Tp:(k+1)*Tp] = masked_input.copy()


## (Testing) Initialize the reservoir layer

# No need to store these values since they won't be used in testing
for k in range(0,(initLen * Tp)):

    # Compute the new input data for initialization
    initJTS = (inputTS[k,0]) + eta * (nodeC[N-1,0])
    
    # Activation
    nodeN[0,0]	= (mackey_glass(initJTS))
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
    nodeN[1:N]  = nodeC[0:(N - 1)]
    
    # Update the current node state
    nodeC       = nodeN.copy()
    
    # Updete all node states
    nodeE[:, k] = nodeC[:,0]



# Consider the data just once everytime it loops around
nodeTS[:,0:testLen] = nodeE[:, N*np.arange(1,testLen + 1)-1]

##  Compute testing errors

# Call-out the target outputs
Yt = target[0,initLen + trainLen + initLen : initLen + trainLen + initLen + testLen].reshape(1,testLen) * YT_SCALE

# Calculate the NMSE
predicted_target = np.dot(Wout,nodeTS)
mse   = np.sum(np.power(Yt - predicted_target,2)) / Yt.size
nrmse = (np.linalg.norm(Yt - predicted_target) / np.linalg.norm(Yt))

print('--------------------------------------------------')
print('Testing Errors')
print(f'testing mse: {mse}')
print(f'testing nrmse: {nrmse}')


########################################################################
########################################################################

### Write Data for Hybrid System Simulation ###
# Save Inputs
fh = open("./data/narma10/dfr_sw_int_narma10_inputs.txt","w")
for i in range(inputTS.size):
    fh.write(f"{inputTS[i,0]}\n")
fh.close()

# Save Reservoir Outputs
fh = open("./data/narma10/dfr_sw_int_narma10_reservoir_outputs.txt","w")
for input_idx in range(nodeTS.shape[1]):
    for sample_idx in range(nodeTS.shape[0] - 1, -1,-1):
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
    fh.write(f"{int(predicted_target[0,i])}\n")
fh.close()

# Save Expected NARMA10 Outputs
fh = open("./data/narma10/dfr_sw_int_narma10_expected_dfr_outputs.txt","w")
for i in range(Yt.size):
    fh.write(f"{int(Yt[0,i])}\n")
fh.close()

# DFR: An Energy-efficient Analog Delay Feedback Reservoir Computing System
# Table 2. Performance Comparison in Different Models
#                           Model   Training Error (NRMSE)  Testing Error(NRMSE)    Error Rate Reduction
# (Rodan and Tino2011)      ESN     /                       0.1075                  36.5%
# (Appeltant et al.2011)    DFR     /                       0.15                    54.5%
# (Goudarzi et al.2014)     DFR     0.065                   0.464                   85.3%
# (Ortín and Pesquera2017)  DFR     /                       0.17                    59.8%
# This Work                 DFR     0.0849                  0.0683                  /
