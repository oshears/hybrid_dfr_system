import numpy as np
import matplotlib.pyplot as plt
from numpy.core.fromnumeric import shape
from numpy.core.function_base import linspace


# https://www.nature.com/articles/ncomms1476

def mg(x):

    a = 2
    b = 0.8
    c = 0.2
    d = 2.1
    p = 10

    return (a * x) / (b + c * np.power( (d * x), p) )

# def mg(x):
#     C = 1.33
#     # p = 6.88
#     # p = 7
#     p = 1
#     b = 0.4

#     return C * x / (1 + np.power(b * x,p)) 


def mg_deriv(x):

    a = 2
    b = 0.8
    c = 0.2
    d = 2.1
    p = 10


    return (a * (b - (p - 1) * c * np.power(d * x, p))) / np.power((b + c * np.power( (d * x), p) ),2)

def relu(x):
    return np.array([np.max(xi,0) for xi in x])

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

num_samples = 20000
init_samples = 200
train_samples = 10000

rng = np.random.default_rng(0)

# NARMA10
def narma10_create(inLen):

    # Compute the random uniform input matrix
    inp = 0.5*rng.random(inLen)

    # Compute the target matrix
    tar = np.zeros(inLen)

    for k in range(10,(inLen - 1)):
        tar[k+1] = 0.3 * tar[k] + 0.05 * tar[k] * np.sum(tar[k-9:k]) + 1.5 * inp[k] * inp[k - 9] + 0.1
    
    return (inp, tar)

x, y = narma10_create(num_samples)

y_train = y[init_samples:init_samples+train_samples]

## dfr parameters
# virtual nodes [10,100]
# input gain (gamma) [0,1]
# feedback scale (eta) [0,1]
# weight matrix (W)
# activation function (g(x)) [mg,tanh,sigmoid,relu]
# training technique [bptt,regression]
# mask [uniform,]
# learning rate (alpha) [1,0.1,0.01,0.001,0.0001]

N = 400
gamma = 0.05
eta = 0.5

alpha = 0.001  # learning rate

# weight generation
W = (2*rng.random(N) - 1) * 1e-3

mask = rng.choice([-0.1,0.1],N)

# mask generation
masked_samples = np.empty((num_samples,N))
for i in range(num_samples):
    masked_samples[i] = mask * x[i]

reservoir = np.zeros(N)
reservoir_history = np.zeros((train_samples,N))

# initialization
for i in range(init_samples):
    for j in range(N):
        g_i = mg(gamma * masked_samples[i][j] + eta * reservoir[N - 1])
        reservoir[1:N] = reservoir[0:N - 1]
        reservoir[0] = g_i

# dfr stage
output_error = 0
total_error = 0
reservoir_old = 0

y_hat = np.zeros(train_samples)
for i in range(train_samples):
    for j in range(N):

        W[j] = (W[j] - alpha * output_error * reservoir[N - 1]) if (i > 0) else W[j]

        g_i = mg(gamma * masked_samples[i + init_samples][j] + eta * reservoir[N - 1])
        reservoir[1:N] = reservoir[0:N - 1]
        reservoir[0] = g_i

        y_hat[i] += W[j] * g_i

    output_error = y_hat[i] - y_train[i]
    total_error += np.square(output_error)

    reservoir_old = reservoir.copy()

    if i % 1000 == 0:
        running_mse = total_error / (i + 1)
        print(f"MSE[{i}]: {running_mse}")

    reservoir_history[i] = reservoir

loss = (np.linalg.norm(y_train - y_hat) / np.linalg.norm(y_train))
print(f"SGD NRMSE: {loss}")

# regression approach
reg = 1e-8
W = np.dot(np.dot(y_train,reservoir_history),np.linalg.inv((np.dot(reservoir_history.T,reservoir_history)) + reg * np.eye(N)))
y_hat_reg = reservoir_history.dot(W)
loss = (np.linalg.norm(y_train - y_hat_reg) / np.linalg.norm(y_train))
print(f"Ridge Regression NRMSE: {loss}")