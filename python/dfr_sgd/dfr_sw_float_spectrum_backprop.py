############################################################
#
#   Delay-feedback Reservoir (DFR)
#   Spectrum (Float)
#
############################################################

import numpy as np

MG_FUNCTION_RESOLUTION = 2**16

MAX_INPUT = 0


def mackey_glass(x):
    xi = 10
    return x / (1 + np.power(x,xi))

def mackey_glass_deriv(x):
    return -1 * (9 * np.power(x,10) - 1) / np.power(np.power(x,10) + 1, 2)

##	Import dataset
seed = 0
np.random.seed(seed)
NOISE = 10
ANT = 6
spectrum_vector = np.genfromtxt(f"./data/spectrum/spectrum_-{NOISE}_db_{ANT}_ant.csv", delimiter=",")


data   = spectrum_vector[:,0].reshape((1,spectrum_vector.shape[0]))
target = spectrum_vector[:,1].reshape((1,spectrum_vector.shape[0]))

# normalize data set
data   = data / np.max(data)


##	Reservoir Parameters

# Tp        = sample/hold time frame for input (length of input mask)
# N         = number of virtual nodes in the reservoir (must equal to Tp)
# theta     = distance between virtual nodes
# gamma     = input gain
# eta       = feedback gain (leaking rate)
# initLen	= number of samples used in initialization
# trainLen	= number of samples used in training
# testLen	= number of samples used in testing
NUM_SAMPLES = 6102
Tp          = 100
N           = Tp
theta       = Tp / N
gamma       = 2
# eta         = 1 - gamma
eta         = 1/4
initLen     = 20 
trainLen	= 49 * initLen 
testLen     = NUM_SAMPLES - (trainLen + initLen + initLen)

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

nodeC   = np.zeros(shape=(N, 1))
nodeN   = np.zeros(shape=(N, 1))
nodeE	= np.zeros(shape=(N , trainLen * Tp))
nodeTR	= np.zeros(shape=(N , trainLen))


##  (Training) Apply masking to training data
inputTR = np.ndarray(shape=((initLen + trainLen) * Tp,1))

for k in range(0,(initLen + trainLen)):
    uTR = data[0,k]
    masked_input = (M * uTR)
    inputTR[k*Tp:(k+1)*Tp] = masked_input.copy()

##  (Training) Initialize the reservoir layer

# No need to store these values since they won't be used in training
for k in range(0,(initLen * Tp)):

    # Compute the new input data for initialization
    initJTR = gamma * (inputTR[k,0]) + eta * (nodeC[N-1,0])
    
    # Activation
    nodeN[0,0]	= mackey_glass(initJTR)
    nodeN[1:N]  = nodeC[0:(N - 1)]
    
    # Update the current node state
    nodeC       = nodeN.copy()


##	(Training) Run data through the reservoir
for k in range(0,(trainLen * Tp)):

    # Define the time step that starts storing node states
    t = initLen * Tp + k
    
    # Compute the new input data for training
    trainJ = gamma * (inputTR[t,0]) + eta * (nodeC[N-1,0])
    
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
# nodeTR_T = nodeTR.T

# Calculate output weights
# reg = 1e-8
# Wout = np.dot(np.dot(Yt,nodeTR_T),np.linalg.inv((np.dot(nodeTR,nodeTR_T)) + reg * np.eye(N)))
Wout = np.random((1,Tp))
for output_idx in range(trainLen):
    predicted_output = np.round(np.dot(Wout,nodeTR[:,output_idx]))
    predicted_output_binary = predicted_output > 0.5
    expected_output = Yt
    cost = 0.5 * (expected_output - predicted_output) * mackey_glass_deriv()

# Calculate the NMSE
predicted_target = np.dot(Wout,nodeTR)
predicted_target = predicted_target > 0.5
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
predicted_target = predicted_target > 0.5
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

import matplotlib.pyplot as plt
SAMPLES = 100
x = np.linspace(0,SAMPLES-1,SAMPLES)
plt.plot(x,Yt[0,0:SAMPLES],label="Yt")
plt.plot(x,predicted_target[0,0:SAMPLES],'--',label="Predicted Target")
plt.legend()
plt.savefig("./data/spectrum/dfr_sw_float_spectrum_fig.png")