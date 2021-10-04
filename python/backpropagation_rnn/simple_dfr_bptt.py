import numpy as np
import matplotlib.pyplot as plt

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
plt.subplot(2,2,1)
plt.plot(x,y_mg)
plt.subplot(2,2,2)
plt.plot(x,y_relu)
plt.subplot(2,2,3)
plt.plot(x,y_mg_deriv)
plt.subplot(2,2,4)
plt.plot(x,y_relu_deriv)
plt.show()

###############################################