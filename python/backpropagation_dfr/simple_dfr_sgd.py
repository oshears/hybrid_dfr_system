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


    return (a * x) / (b + c * np.power( (d * x), 10) )

def mg_deriv(x):

    a = 2
    b = 0.8
    c = 0.2
    d = 2.1


    return (a * (b - 9 * c * np.power(d * x, 10))) / np.power((b + c * np.power( (d * x), 10) ),2)

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

num_samples = 6000
init_samples = 200
train_samples = 4000

rng = np.random.default_rng(0)

# x = linspace(1,num_samples,num_samples)

# # expected output
# y = np.empty(num_samples)
# for i in range(num_samples):
#     if i < 2:
#         y[i] = 0
#     else:
#         y[i] = np.sum(x[i - 2:i+1])


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

# x_norm = x / np.max(x)

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

# mask = np.random.random(N)
# mask = rng.uniform(size=N)
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
        a_i = gamma * masked_samples[i][j] + eta * reservoir[N - 1]
        g_i = mg(a_i)
        reservoir[1:N] = reservoir[0:N - 1]
        reservoir[0] = g_i
    reservoir_history[i] = reservoir

reservoir_init = reservoir.copy()

# dfr stage
output_error = 0
total_error = 0
reservoir_old = 0
for i in range(train_samples):
    for j in range(N):

        if(i > 0):
            W[j] = W[j] - alpha * output_error * reservoir[N - 1]

        a_i = gamma * masked_samples[i][j] + eta * reservoir[N - 1]
        g_i = mg(a_i)
        reservoir[1:N] = reservoir[0:N - 1]
        reservoir[0] = g_i

    output_error = W.dot(reservoir) - y_train[i]
    total_error += np.square(output_error)

    reservoir_old = reservoir.copy()

    if i % 100 == 0:
        running_mse = total_error / (i + 1)
        print(f"MSE[{i}]: {running_mse}")

        # print(f"Error Before: {}; Error After: {}")

    reservoir_history[i] = reservoir



# perform stochastic backprop
# for i in range(train_samples):
#     y_hat = reservoir_history.dot(W)

#     # loss = np.sum(np.power(y_hat - y_train,2)) / train_samples

#     # nrmse
#     loss = (np.linalg.norm(y_train - y_hat) / np.linalg.norm(y_train))

#     # if (i % 1000 == 0):
#     #     print(f"[{i}]BPTT NRMSE: {loss}")

#     output_error = (y_hat[i] - y_train[i])
#     for k in range(N):
#         W[k] = W[k] - alpha * output_error * reservoir_history[i][k]


#     print(f"BPTT NRMSE: {loss}\tN = {N}\tgamma = {gamma}\teta = {eta}")


# regression approach
reg = 1e-8
W = np.dot(np.dot(y_train,reservoir_history),np.linalg.inv((np.dot(reservoir_history.T,reservoir_history)) + reg * np.eye(N)))
y_hat_reg = reservoir_history.dot(W)
loss = (np.linalg.norm(y_train - y_hat_reg) / np.linalg.norm(y_train))
print(f"Ridge Regression NRMSE: {loss}")