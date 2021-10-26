import numpy as np
import matplotlib.pyplot as plt
from numpy.core.fromnumeric import shape
from numpy.core.function_base import linspace


# https://www.nature.com/articles/ncomms1476

# def mg(x):

#     a = 2
#     b = 0.8
#     c = 0.2
#     d = 2.1
#     p = 10

#     return (a * x) / (b + c * np.power( (d * x), p) )

def mg(x):
    C = 1.33
    # p = 6.88
    # p = 7
    p = 1
    b = 0.4

    return C * x / (1 + np.power(b * x,p)) 


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

num_samples = 10000
init_samples = 500
# train_samples = 4000
train_samples = 5500

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

# normalize input data
# x = x / np.max(x)

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

N = 100
gamma = 0.9
eta = 0.1
LAST_NODE = N - 1

alpha = 0.001  # learning rate

# weight generation
W = (2*rng.random(N) - 1)*16

# mask = rng.choice([-0.1,0.1],N)
mask = rng.uniform(-0.5,0.5,N)
# mask = np.ones(N) * 0.5

# mask generation
masked_samples = np.empty((num_samples,N))
for i in range(num_samples):
    masked_samples[i] = mask * x[i]

reservoir = np.zeros(N)
reservoir_history = np.zeros((train_samples,N))

# initialization
for i in range(init_samples):
    for j in range(N):
        g_i = np.tanh(gamma * masked_samples[i][j] + eta * reservoir[LAST_NODE])
        reservoir[1:N] = reservoir[0:LAST_NODE]
        reservoir[0] = g_i

# dfr stage
output_error = 0
reservoir_old = 0

# training data configuration

batch_size = 1
W_new = W.copy()

for i in range(train_samples):

    dfr_output = 0

    for j in range(N):

        if (i % batch_size == 0):
            W[j] = W_new[j]
            
        W_new[j] = (W_new[j] - alpha * output_error * reservoir[LAST_NODE]) if (i > 0) else W_new[j]

        g_i = np.tanh(gamma * masked_samples[i + init_samples][j] + eta * reservoir[LAST_NODE])
        reservoir[1:N] = reservoir[0:LAST_NODE]
        reservoir[0] = g_i

        dfr_output += W[j] * g_i

    output_error = dfr_output - y_train[i]

    reservoir_history[i] = reservoir

# initialization
for i in range(init_samples):
    for j in range(N):
        g_i = np.tanh(gamma * masked_samples[i][j] + eta * reservoir[LAST_NODE])
        reservoir[1:N] = reservoir[0:LAST_NODE]
        reservoir[0] = g_i

# training data evaluation
y_hat = np.zeros(train_samples)
for i in range(train_samples):
    for j in range(N):

        g_i = np.tanh(gamma * masked_samples[i + init_samples][j] + eta * reservoir[LAST_NODE])
        reservoir[1:N] = reservoir[0:LAST_NODE]
        reservoir[0] = g_i

        y_hat[i] += W[j] * g_i
        
    reservoir_history[i] = reservoir

loss = (np.linalg.norm(y_train - y_hat) / np.linalg.norm(y_train))
print(f"SGD NRMSE: {loss}")

# regression approach
reg = 1e-8
W = np.dot(np.dot(y_train,reservoir_history),np.linalg.inv((np.dot(reservoir_history.T,reservoir_history)) + reg * np.eye(N)))
y_hat_reg = reservoir_history.dot(W)
loss = (np.linalg.norm(y_train - y_hat_reg) / np.linalg.norm(y_train))
print(f"Ridge Regression NRMSE: {loss}")



plt.plot(y_train[0:100],label="actual")
plt.plot(y_hat[0:100],'--',label="sgd")
plt.plot(y_hat_reg[0:100],'--',label="regression")
plt.legend()
plt.show()


# write narma10 data
train_data = open("train_data.txt","w")
train_label = open("train_label.txt","w")
test_data = open("test_data.txt","w")
test_label = open("test_label.txt","w")

for i in range(200):
    train_data.write(f"{x[i]}\n")
    train_label.write(f"{y[i]}\n")
    test_data.write(f"{x[i+200]}\n")
    test_label.write(f"{y[i+200]}\n")

train_data.close()
train_label.close()
test_data.close()
test_label.close()