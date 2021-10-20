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
def narma10_create(inLen,seedRan=-1):
    # if (nargin > 1)
    #    rng(seedRan);

    # Compute the random uniform input matrix
    inp = 0.5*np.random.rand(1, inLen);

    # Compute the target matrix
    tar = np.zeros(shape=(1, inLen));

    for k in range(10,(inLen - 1)):
        tar[0,k+1] = 0.3 * tar[0,k] + 0.05 * tar[0,k] * np.sum(tar[0,k-9:k]) + 1.5 * inp[0,k] * inp[0,k - 9] + 0.1
    
    return (inp, tar)

# ASIC Mackey-Glass Activation Function
def mackey_glass_asic(inData,inDataMax):

    # Open ASIC Activation Function File
    fh = open("mackey_glass_asic.csv",mode="r")
    
    # Read All Lines
    lines = fh.readlines()

    # Scale Input Data
    scaledInData = (inData / inDataMax) * 1.8

    for line in lines:
        # Parse Data
        vals = line.split("\n")
        vals = vals[0].split(",")
        inVal = float(vals[0])
        outVal = float(vals[1])

        # If Data is Equal to/Less Than inVal, return outVal
        if scaledInData <= inVal:
            return outVal

    return 0

##	Import dataset

# 10th order nonlinear auto-regressive moving average (NARMA10)
seed = 50
data, target = narma10_create(10000, seed)



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
gamma       = 0.99
eta         = 1 - gamma
initLen     = 500   
trainLen	= 5500
testLen     = 500


##  Define the masking (input weight, choose one of the followings)

# Random Uniform [-1, 1]
M = np.random.rand(Tp, 1) * 2 - 1

# Random Uniform [0, 1]
# M = rand(Tp, 1)

# Random from group [-0.1, +0.1]
# M = rand(Tp, 1) * 2 - 1
# M = sign(M) * 0.1

# Random normal
# M = randn(Tp, 1) * 1

# Constant
# M = ones(Tp, 1) * 0.5

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

nodeC   = np.zeros(shape=(N, 1))
nodeN   = np.zeros(shape=(N, 1))
nodeE	= np.zeros(shape=(N , trainLen * Tp))
nodeTR	= np.zeros(shape=(N , trainLen))


##  (Training) Apply masking to training data

inputTR = np.ndarray(shape=((initLen + trainLen) * Tp,1))

for k in range(0,(initLen + trainLen)):
    uTR = data[0,k]
    inputTR[k:k+Tp,:] = M * uTR



##  (Training) Initialize the reservoir layer

# No need to store these values since they won't be used in training

for k in range(0,(initLen * Tp)):
    # Compute the new input data for initialization
    initJTR = (gamma * inputTR[k,0]) + (eta * nodeC[N-1,0])
    
    # Activation
    nodeN[0]	= np.tanh(initJTR)   
    nodeN[1:N,0]  = nodeC[0:(N - 1),0]
    
    # Update the current node state
    nodeC       = nodeN


##	(Training) Run data through the reservoir

for k in range(0,(trainLen * Tp)):
    # Define the time step that starts storing node states
    t = initLen * Tp + k
    
    # Compute the new input data for training
    trainJ = (gamma * inputTR[t,0]) + (eta * nodeC[N-1,0])
    
    # Activation
    nodeN[1,0]	= np.tanh(trainJ)	
    #nodeN[1,0]	= mackey_glass_asic(trainJ)	
    nodeN[1:N,0]  = nodeC[0:(N - 1),0]
    
    # Update the current node state
    nodeC       = nodeN
    
    # Updete all node states
    nodeE[:, k] = nodeC[:,0]


# Consider the data just once everytime it loops around
nodeTR[:,0:trainLen] = nodeE[:, N*np.arange(1,trainLen + 1)-1]


##  Train output weights using ridge regression

# Define the regularization coefficient
regC = 1e-8

# Call-out the target outputs
Yt = target[0,initLen:(initLen + trainLen)].reshape(1,trainLen)

# Transpose nodeR for matrix claculation
nodeTR_T = nodeTR.T

# Calculate output weights
Wout = np.dot(Yt,nodeTR_T) / (np.dot(nodeTR,nodeTR_T) + (regC * np.eye(N)))


##  Compute training error

# Claculate the MSE through L2 norm
mseTR = (((Yt - np.dot(Wout,nodeTR))**2).mean(axis=0))

# Calculate the NMSE
nmseTR = 0
# nmseTR = (norm(Yt - (Wout * nodeTR)) / np.norm(Yt))^2

print('--------------------------------------------------')
print('Training Errors')
print(f'training MSE     = {mseTR} \n')
print(f'training NMSE    = {nmseTR} \n')


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