import numpy as np
import matplotlib.pyplot as plt
from numpy.core.fromnumeric import shape
from numpy.core.function_base import linspace

def mg(x):

    a = 2
    b = 0.8
    c = 0.2
    d = 2.1


    return (a * x) / (b + c * np.power( (d * x), 10) )

def mg_deriv(x):

    a = 2
    b = 0.8
    c = 0.2
    d = 2.1


    return (a * (b - 9 * c * np.power(d * x, 10))) / np.power((b + c * np.power( (d * x), 10) ),2)

def relu(x):
    return np.array([max(xi,0) for xi in x])

def relu_deriv(x):
    y = np.zeros(x.size)
    y[x >= 0] = 1
    y[x < 0] = 0 
    return y

# inputs
x = np.linspace(-1,1,100)

# mg equation characteristics
y_mg = mg(x)
y_mg_deriv = mg_deriv(x)

# relu characteristics
y_relu = relu(x)
y_relu_deriv = relu_deriv(x)

# plot activation functions
# plt.subplot(2,2,1)
# plt.plot(x,y_mg)
# plt.subplot(2,2,2)
# plt.plot(x,y_relu)
# plt.subplot(2,2,3)
# plt.plot(x,y_mg_deriv)
# plt.subplot(2,2,4)
# plt.plot(x,y_relu_deriv)
# plt.show()

###############################################

num_samples = 3
x = linspace(1,num_samples,num_samples)

# expected output
y = np.empty(num_samples)
for i in range(num_samples):
    y[i] = np.sum(x[0:i+1])


# dfr
N = 5
# gamma = np.random.random()
gamma = 1
# eta = np.random.random()
eta = 1

mask = np.random.random(N)


masked_samples = np.empty((num_samples,N))
for i in range(num_samples):
    masked_samples[i] = mask * x[i]


reservoir = np.zeros(N)
reservoir_history = np.zeros((num_samples,N))
for i in range(num_samples):
    for j in range(N):
        a_i = gamma * masked_samples[i][j] + eta * reservoir[N - 1]
        g_i = mg(a_i)
        reservoir[1:N] = reservoir[0:N - 1]
        reservoir[0] = g_i
    reservoir_history[i] = reservoir


# initialize random weights
W = np.random.random(N)

# perform backprop
epochs = 10 # training loops
alpha = 0.1 # learning rate
for epoch in range(epochs):
    
    y_hat = reservoir_history.dot(W)

    loss = np.sum(np.power(y_hat - y,2)) / num_samples
    print(f"[{epoch}] MSE: {loss}")

    partial_deriv_readout = 0
    for i in range(num_samples):
        partial_deriv_readout += (y_hat[i] - y[i]) * W
        # print(partial_deriv_readout)

    W = W - alpha * partial_deriv_readout
