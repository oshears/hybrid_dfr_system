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

mg_deriv_vector = np.zeros(MG_FUNCTION_RESOLUTION)


avg_samples = 1000
for i in range(MG_FUNCTION_RESOLUTION):
    if i < avg_samples:
        # mg_deriv_vector[i] = mg_vector[1,i+1] - mg_vector[1,i]
        # mg_deriv_vector[i] = mg_vector[1,i+1] - np.average(mg_vector[1,i])
        mg_deriv_vector[i] = 0
    elif i == MG_FUNCTION_RESOLUTION - 1 - avg_samples:
        # mg_deriv_vector[i] = mg_vector[1,i] - mg_vector[1,i-1]
        mg_deriv_vector[i] = 0
    else:
        # mg_deriv_vector[i] = mg_vector[1,i+1] - mg_vector[1,i-1]
        mg_deriv_vector[i] = np.average(mg_vector[1,i:i+avg_samples]) - np.average(mg_vector[1,i-avg_samples:i])


# plt.plot(mg_vector[1,:])
# plt.plot(mg_deriv_vector[:])
# plt.show()

delay = 10
samples = 100

mg_model = np.zeros(samples)

for i in range(delay):
    mg_model[i] = np.random.random()


for i in range(delay,samples):
    mg_model[i] = 0.5 * mg_model[i - delay] / ( 1 * np.power((1 + mg_model[i - delay]),4) )

plt.plot(mg_model)
plt.show()