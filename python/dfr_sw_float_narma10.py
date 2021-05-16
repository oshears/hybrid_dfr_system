############################################################
#
#   Delay-feedback Reservoir (DFR)
#   NARMA-10 (Float)
#
############################################################

import numpy as np

MG_FUNCTION_RESOLUTION = 2**16

MAX_INPUT = 0


# ASIC Mackey-Glass Activation Function
mg_vector = np.genfromtxt("./data/asic_function_onboard_dac.csv", delimiter=",").T

def mackey_glass(inData):

    if inData < MG_FUNCTION_RESOLUTION:
        # scaled_input = int(MG_FUNCTION_RESOLUTION * inData)
        scaled_input = int(MG_FUNCTION_RESOLUTION * inData / MAX_INPUT )
        if scaled_input < MG_FUNCTION_RESOLUTION and scaled_input > 0:
            float_output = mg_vector[1,scaled_input] / (2**12)
            return float_output
    
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

##  (Training) Initialization of reservoir dynamics

# nodeC     = reservoir dynamic at the current cycle
# nodeN     = reservoir dynamic at the next cycle
# nodeE     = reservoir dynamic at every timestep during training
# nodeTR    = a snapshot of all node states at each full rotation through 
#             the reservoir during training

nodeC   = np.zeros(shape=(N, 1))
nodeN   = np.zeros(shape=(N, 1))
nodeE	= np.zeros(shape=(N , trainLen * Tp))
nodeTR	= np.zeros(shape=(N , trainLen))


##  (Training) Apply masking to training data
inputTR = np.ndarray(shape=((initLen + trainLen) * Tp,1))

for k in range(0,(initLen + trainLen)):
    uTR = data[0,k]
    # multiply input by mask and convert to int
    masked_input = (M * uTR)
    inputTR[k*Tp:(k+1)*Tp] = masked_input.copy()

MAX_INPUT = np.max(inputTR)

##  (Training) Initialize the reservoir layer
# No need to store these values since they won't be used in training
for k in range(0,(initLen * Tp)):

    # Compute the new input data for initialization
    initJTR = (inputTR[k,0]) + eta * (nodeC[N-1,0])
    
    # Activation
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
Yt = target[0,initLen:(initLen + trainLen)].reshape(1,trainLen)

# Transpose nodeR for matrix claculation
nodeTR_T = nodeTR.T

# Calculate output weights
reg = 1e-8
Wout = np.dot(np.dot(Yt,nodeTR_T),np.linalg.inv((np.dot(nodeTR,nodeTR_T)) + reg * np.eye(N)))

# Calculate the NMSE
predicted_target = np.dot(Wout,nodeTR)
mse   = np.sum(np.power(Yt - predicted_target,2)) / Yt.size
nrmse = (np.linalg.norm(Yt - predicted_target) / np.linalg.norm(Yt))

print('--------------------------------------------------')
print('Testing Errors')
print(f'testing mse: {mse}')
print(f'testing nrmse: {nrmse}')

## (Testing) Initialize the reservoir layer

# nodeC     = reservoir dynamic at the current cycle
# nodeN     = reservoir dynamic at the next cycle
# nodeE     = reservoir dynamic at every timestep during training
# nodeTS    = a snapshot of all node states at each full rotation through 
#             the reservoir during testing

nodeC   = np.zeros(shape=(N, 1))
nodeN   = np.zeros(shape=(N, 1))
nodeE	= np.zeros(shape=(N , testLen * Tp))
nodeTS	= np.zeros(shape=(N , testLen))


##  (Testing) Apply masking to input testing data
inputTS = np.ndarray(shape=((initLen + testLen) * Tp,1))

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
Yt = target[0,initLen + trainLen + initLen : initLen + trainLen + initLen + testLen].reshape(1,testLen)


# Calculate the NMSE
predicted_target = np.dot(Wout,nodeTS)
mse   = np.sum(np.power(Yt - predicted_target,2)) / Yt.size
nrmse = (np.linalg.norm(Yt - predicted_target) / np.linalg.norm(Yt))

print('--------------------------------------------------')
print('Testing Errors')
print(f'testing mse: {mse}')
print(f'testing nrmse: {nrmse}')


# DFR: An Energy-efficient Analog Delay Feedback Reservoir Computing System
# Table 2. Performance Comparison in Different Models
#                           Model   Training Error (NRMSE)  Testing Error(NRMSE)    Error Rate Reduction
# (Rodan and Tino2011)      ESN     /                       0.1075                  36.5%
# (Appeltant et al.2011)    DFR     /                       0.15                    54.5%
# (Goudarzi et al.2014)     DFR     0.065                   0.464                   85.3%
# (Ortín and Pesquera2017)  DFR     /                       0.17                    59.8%
# This Work                 DFR     0.0849                  0.0683                  /
