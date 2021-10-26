#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "dfr.h"

// Frobenius norm
float norm(float* x, int size){

    float sum = 0;
    for (int i = 0; i < size; i++){
        float x_i = x[i];
        sum = sum + (x_i * x_i);
    }

    return sqrt(sum);
}

// calculate kian's nrmse
float get_nrmse(float* y_hat, float* y, int size){
    
    float nrmse = 0;

    float* y_error = new float[size]();

    for (int i = 0; i < size; i++){
        y_error[i] = y_hat[i] - y[i];
    }

    return norm(y_error,size) / norm(y,size);
}

float get_mse(float* y_hat, float* y, int size){
    float mse = 0;


    for (int i = 0; i < size; i++){
        float y_error = y_hat[i] - y[i];
        mse += (y_error * y_error);
    }
    mse /= size;

    return mse;

}

