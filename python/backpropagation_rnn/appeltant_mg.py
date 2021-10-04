import numpy as np
import matplotlib.pyplot as plt
from numpy.core.function_base import linspace


# https://www.nature.com/articles/ncomms1476


M = 1000

x = 1.5 * np.random.random(M)

tau = 2
eta = 1
gamma = 1
p = 9.65

y = np.empty(M)

for i in range(M):
    if i < tau:
        y[i] = 1.5 * np.random.random()
    else:
        y[i] = (eta * (y[i - tau] + gamma * x[i])) / (1 + np.power((y[i - tau] + gamma * x[i]),10))


plt.subplot(2,1,1)
plt.plot(y[tau:],y[:M - tau])
plt.subplot(2,1,2)
plt.plot(y)
plt.show()


plt.subplot(1,1,1)
x = linspace(1,10,10)
y = np.append(x[1:10],x[0])
print(x)
print(y)
plt.plot(x,y)
plt.show()