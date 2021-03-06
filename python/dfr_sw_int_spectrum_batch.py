############################################################
#
#   Delay-feedback Reservoir (DFR)
#   Spectrum (Int)
#
############################################################

import numpy as np
import sklearn
from sklearn.metrics import roc_curve
from sklearn.metrics import roc_auc_score
import matplotlib.pyplot as plt

MG_FUNCTION_RESOLUTION = 2**16

MAX_INPUT = 2**16

MAX_MG_OUTPUT = 2**12

YT_SCALE = 2**32


# ASIC Mackey-Glass Activation Function
mg_vector = np.genfromtxt("./data/asic_function_onboard_dac.csv", delimiter=",").T

def mackey_glass(inData):

    # scaled the input based on the max MG function input (MG_FUNCTION_RESOLUTION)
    # and the max input data value
    # scaled_input = int( MG_FUNCTION_RESOLUTION * ( inData / MAX_INPUT ) )
    scaled_input = int(inData) & (MG_FUNCTION_RESOLUTION - 1)

    # if the scaled result is in the range of the MG function
    if scaled_input < MG_FUNCTION_RESOLUTION and scaled_input >= 0:
        
        # scale the output back within the range of the max input values
        int_output = MAX_INPUT * ( mg_vector[1,scaled_input] / MAX_MG_OUTPUT )
        return int_output
    
    return 0

plot_idx = 0
colors = ['seagreen','seagreen','seagreen','cornflowerblue','cornflowerblue','cornflowerblue','salmon','salmon','salmon']
markers = ['.','v','s','.','v','s','.','v','s']
for AMNT_NOISE in ([10,15,20]):
    for NUM_ANT in ([2,4,6]):
        ##	Import dataset
        seed = 0
        np.random.seed(seed)
        NOISE = AMNT_NOISE
        ANT = NUM_ANT
        spectrum_vector = np.genfromtxt(f"./data/spectrum/spectrum_-{NOISE}_db_{ANT}_ant.csv", delimiter=",")
        data   = spectrum_vector[:,0].reshape((1,spectrum_vector.shape[0]))
        # normalize the data
        data = data / np.max(data)
        target = spectrum_vector[:,1].reshape((1,spectrum_vector.shape[0]))


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
        gamma       = 1
        # eta         = 1 - gamma
        eta         = 1/16
        initLen     = 20 
        trainLen	= 49 * initLen 
        testLen     = NUM_SAMPLES - (trainLen + initLen + initLen)

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
        predicted_target = (predicted_target > YT_SCALE / 2) * YT_SCALE
        mse   = np.sum(np.power(Yt - predicted_target,2)) / Yt.size
        nrmse = (np.linalg.norm(Yt - predicted_target) / np.linalg.norm(Yt))

        # print('--------------------------------------------------')
        # print('Training Errors')
        # print(f'training mse: {mse}')
        # print(f'training nrmse: {nrmse}')


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
        Yt = (target[0,initLen + trainLen + initLen : initLen + trainLen + initLen + testLen].reshape(1,testLen))
        Yt = Yt.astype(int)

        # Calculate the NMSE
        predicted_target = np.dot(Wout,nodeTS)
        predicted_target_binary = (predicted_target > YT_SCALE / 2)
        predicted_target_binary.astype(int)
        predicted_target_probs = predicted_target / (YT_SCALE)
        mse   = np.sum(np.power(Yt - predicted_target_binary,2)) / Yt.size
        nrmse = (np.linalg.norm(Yt - predicted_target_binary) / np.linalg.norm(Yt))

        # print('--------------------------------------------------')
        # print('Testing Errors')
        # print(f'testing mse: {mse}')
        # print(f'testing nrmse: {nrmse}')

        ########################################################################
        ########################################################################

        
        auc = roc_auc_score(Yt[0], predicted_target_probs[0])
        print('NOISE: %d ANT: %d NRMSE: %.3f AUC: %.3f' % (AMNT_NOISE, NUM_ANT, nrmse, auc) )

        # plt.clf()
        predicted_target_probs = np.round(predicted_target_probs,1)
        fpr, tpr, _ = roc_curve(Yt[0], predicted_target_probs[0])
        plt.plot(fpr, tpr, marker=markers[plot_idx], color=colors[plot_idx], label=f"SNR = -{AMNT_NOISE}dB, {NUM_ANT} Antennae")
        plot_idx += 1
plt.xlabel('Probability of False Alarm of Subcarriers', fontweight='bold')
plt.ylabel('Probability of Detection of Subcarriers', fontweight='bold')
# show the legend
plt.legend()
# show the plot
plt.show()