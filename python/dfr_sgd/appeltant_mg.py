import numpy as np
import matplotlib.pyplot as plt
from numpy.core.function_base import linspace
import sys


# https://www.nature.com/articles/ncomms1476
# https://core.ac.uk/download/pdf/33010007.pdf


rng = np.random.default_rng(0)


num_samples = 6000
init_samples = 200
m = 4000

gamma = 0.05
eta = 0.5

if len(sys.argv) > 2:
    gamma = float(sys.argv[1])
    eta = float(sys.argv[2])


tau = 80
N = 400
theta = tau / N # node separation: more delay = higher separation; more nodes = lower separation

# def mg(X,J):
def mg(x):
    C = 1.33
    # p = 6.88
    # p = 7
    p = 1
    b = 0.4

    return C * x / (1 + np.power(b * x,p)) 


# NARMA10
def narma10_create(inLen):

    # Compute the random uniform input matrix
    inp = 0.5*rng.random(inLen)

    # Compute the target matrix
    tar = np.zeros(inLen)

    for k in range(9,(inLen - 1)):
        tar[k+1] = 0.3 * tar[k] + 0.05 * tar[k] * np.sum(tar[k-9:k]) + 1.5 * inp[k] * inp[k - 9] + 0.1
    
    
    return (inp, tar)

u, y = narma10_create(num_samples)
y_train = y[init_samples:init_samples+m]

# weight generation
W = rng.random(N)

# mask values: [-0.1,0.1]
M = rng.choice([-0.1,0.1],N)

# mask generation
J = np.empty((num_samples,N))
for i in range(num_samples):
    J[i] = M * u[i]

# reservoir initialization
X = np.zeros(N)
X_history = np.zeros((m,N))
for i in range(init_samples):
    for j in range(N):
        g_i = mg(gamma * J[i][j] + eta * X[N - 1])
        X[1:N] = X[0:N - 1]
        X[0] = g_i
    X_history[i] = X

# dfr stage
for i in range(m):
    for j in range(N):
        g_i = mg(gamma * J[init_samples + i][j] + eta * X[N - 1])
        X[1:N] = X[0:N - 1]
        X[0] = g_i
    X_history[i] = X


# regression approach
# reg = 1e-8
reg = 1
W = np.dot(np.dot(y_train,X_history),np.linalg.inv((np.dot(X_history.T,X_history)) + reg * np.eye(N)))
y_hat_reg = X_history.dot(W)
# loss = np.sum(np.power(y_hat_reg - y_train,2)) / train_samples
# loss = (np.linalg.norm(y_train - y_hat_reg) / np.linalg.norm(y_train))
print(f"Gamma: {gamma}; Eta: {eta}")
nrmse = np.sqrt( np.average( np.square(y_hat_reg - y_train) / np.var(y_train) ) )
print(f"Ridge Regression NRMSE (Appeltant): {nrmse}")
nrmse = (np.linalg.norm(y_hat_reg - y_train) / np.linalg.norm(y_train))
print(f"Ridge Regression NRMSE (Kian): {nrmse}")


# plt_samples = 200
# plt.plot(y_train[:plt_samples],label="Y")
# # plt.plot(y_hat[train_samples - 100:train_samples],label="Y_hat BPTT")
# plt.plot(y_hat_reg[:plt_samples],label="Y_hat Regression")
# plt.legend()
# plt.show()
