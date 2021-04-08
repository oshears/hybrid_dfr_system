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
import matplotlib.pyplot as plt

##	Reset the environment

# clc
# close all
# clear all


##	Configure the property of figures

# format long 
# set(gcf, 'DefaultFigureColor', [0.5 0.5 0.5])
# set(gcf, 'DefaultAxesFontSize', 22)
# set(gca, 'FontWeight', 'bold')
# set(gcf, 'DefaultAxesLineWidth', 2)
# set(gcf, 'Position', [50 500 560*1.2 420*1.2])
# set(gca, 'xtick',[])
# set(gca, 'ytick',[])

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
def mackey_glass_fpga(inData):

    # Open ASIC Activation Function File
    # fh = open("mackey_glass_asic.csv",mode="r")
    fh = open("mackey_glass_fpga_16bit_hw.csv",mode="r")
    
    # Read All Lines
    lines = fh.readlines()

    # Scale Input Data
    # scaledInData = (inData / inDataMax) * 1.8

    for line in lines:
        # Parse Data
        vals = line.split("\n")
        vals = vals[0].split(",")
        inVal = float(vals[0])
        outVal = float(vals[1])

        # If Data is Equal to/Less Than inVal, return outVal
        if inData <= inVal:
            return outVal

    return 0

##	Import dataset

# 10th order nonlinear auto-regressive moving average (NARMA10)
seed = 9
# 5, 9
np.random.seed(seed)
data, target = narma10_create(2000, seed)

# print(data[0])
# plt.plot(data[0])
# # plt.plot(target)
# plt.show()
# input()

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

fh = open("./data/dfr_narma10_data.txt","w")
for k in range(0,(initLen + trainLen)):
    uTR = data[0,k]
    masked_input = (M * uTR).astype(int)
    inputTR[k*Tp:(k+1)*Tp] = masked_input.copy()
    # print(masked_input) #(OK)
    for i in range(Tp):
        fh.write(str(masked_input[i,0])+"\n")
fh.close()

##  (Training) Initialize the reservoir layer

# No need to store these values since they won't be used in training

for k in range(0,(initLen * Tp)):
    # Compute the new input data for initialization
    # initJTR = (gamma * inputTR[k,0]) + (eta * nodeC[N-1,0])
    initJTR = (inputTR[k,0]) + (nodeC[N-1,0])
    
    # Activation
    # nodeN[0,0]	= (np.tanh(initJTR / SCALE) * SCALE).astype(int)   
    # nodeN[0,0]	= (mackey_glass_fpga(initJTR)) * ( (SCALE / 2) / MAX_MG_OUT)
    nodeN[0,0]	= (mackey_glass_fpga(initJTR)) * (2 ** 3)
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
    nodeN[0,0]	= (mackey_glass_fpga(trainJ)) * (2 ** 3)
    # print(f" mg({inputTR[t,0]} + {nodeC[N-1,0]}) = {mackey_glass_fpga(trainJ)} => {nodeN[0,0]}") #OK
    #nodeN[1,0]	= mackey_glass_asic(trainJ)	
    # print(nodeN[0,0]) #OK
    nodeN[1:N]  = nodeC[0:(N - 1)]
    # print(nodeN[N - 1,0]) #OK
    
    # Update the current node state
    nodeC       = nodeN.copy()
    
    # Updete all node states
    nodeE[:, k] = nodeC[:,0]

    # input()


# Consider the data just once everytime it loops around
nodeTR[:,0:trainLen] = nodeE[:, N*np.arange(1,trainLen + 1)-1]
# print(nodeTR) #OK
##  Train output weights using ridge regression

# Define the regularization coefficient
# regC = 1e-8

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

fh = open("./data/dfr_narma10_weights.txt","w")
for i in range(N):
    fh.write(str(Wout_int[0,i])+"\n")
fh.close()
##  Compute training error


# predicted_target = np.dot(Wout,nodeTR)
predicted_target_int = np.dot(Wout_int,nodeTR_int)
print(Wout_int)
print(nodeTR_int[:,0])
print(predicted_target_int[0])
predicted_target = predicted_target_int / (10 ** (ROUND_FACTOR * 2))
#expected fpga outputs
fh = open("./data/dfr_narma10_fpga_outputs.txt","w")
for i in range(trainLen):
    fh.write(str(predicted_target_int[0,i])+"\n")
fh.close()

# Calculate the MSE through L2 norm
mseTR = (((Yt - predicted_target)**2).mean(axis=1))

# Calculate the NMSE
nmseTR = (np.linalg.norm(Yt - predicted_target) / np.linalg.norm(Yt))**2

print('--------------------------------------------------')
print('Training Errors')
print(f'training MSE     = {mseTR[0]}')
print(f'training NMSE    = {nmseTR}')

x = np.linspace(0,Yt.size - 1,Yt.size)
plt.plot(x,Yt[0],'--',label="Yt")
# print(Yt[0])
plt.plot(x,predicted_target[0],label="Predicted Target")
# print(predicted_target_scaled[0])
plt.legend()
plt.show()
# input()


'''

## (Testing) Initialize the reservoir layer

# nodeC     = reservoir dynamic at the current cycle
# nodeN     = reservoir dynamic at the next cycle
# nodeE     = reservoir dynamic at every timestep during training
# nodeTS    = a snapshot of all node states at each full rotation through 
#             the reservoir during testing

nodeC   = zeros(N, 1)
nodeN   = zeros(N, 1)
nodeE	= zeros(N , testLen * Tp)
nodeTS  = zeros(N , testLen)


##  (Testing) Apply masking to input testing data

inputTS = []

for k = 1:(initLen + testLen)
    uTS = data(initLen + trainLen + k)
    inputTS = [inputTS (M * uTS)]
end


## (Testing) Initialize the reservoir layer

# No need to store these values since they won't be used in testing

for k = 1:(testLen * Tp)
    # Compute the new input data for initialization during testing
    initJTS = (gamma * inputTS(k)) + (eta * nodeC(N))
    
    # Activation
    nodeN(1)	= tanh(initJTR)   
    nodeN(2:N)  = nodeC(1:(N - 1))
    
    # Update the current node state
    nodeC       = nodeN
end


##  (Testing) Run data through the reservoir

for k = 1:(testLen * Tp)
    # Define the time step that starts storing node states
    t = initLen * Tp + k
    
    # Compute the new input data for training
    testJ = (gamma * inputTS(t)) + (eta * nodeC(N))
    
    # Activation
    nodeN(1)	= tanh(testJ)	
	nodeN(2:N)  = nodeC(1:(N - 1))
    
    # Update the current node state
    nodeC       = nodeN
    
    # Updete all node states
    nodeE(:, k) = nodeC
end

# Consider the data just once everytime it loops around
nodeTS(:, (1:testLen)) = nodeE(:, (Tp * (1:testLen)))


##  Compute testing errors

# Call-out the target outputs
Ytest = target(initLen + trainLen + 1: initLen + trainLen + testLen)

# Claculate the MSE through L2 norm
mse_testing = (norm(Ytest - Wout * nodeTS)^2) / testLen

# Calculate the NMSE
nmse_testing = (norm(Ytest - Wout * nodeTS) / norm(Ytest))^2


disp('--------------------------------------------------')
disp('Testing Errors')
fprintf('Testing MSE     = #e \n',  mse_testing)
fprintf('Testing NMSE    = #e \n', nmse_testing)


##  Compare actual outputs and target outputs

plot(target(initLen+trainLen+1:initLen+trainLen+testLen), '-')
hold on
plot(Ytest, '--')
hold off
grid on
ylabel('Sampled Value')
xlabel('#')
legend('target output', 'predicted output')



'''