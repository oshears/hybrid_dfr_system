#include <stdio.h>
#include <stdlib.h>

#include "HLS/hls.h"
#include "HLS/math.h"
#include "HLS/hls_float.h"
#include "HLS/hls_float_math.h"

#include "dfr.h"

using namespace ihc;

// Frobenius norm
FPhalf norm(FPhalf x){
    return ihc_sqrt(x * x);
}

// Frobenius norm for an array
FPhalf norm(FPhalf* x, int size){

    FPhalf sum = 0;
    for (int i = 0; i < size; i++){
        FPhalf x_i = x[i];
        sum = sum + (x_i * x_i);
    }

    return ihc_sqrt(sum);
}

// calculate kian's nrmse
FPhalf get_nrmse(FPhalf* y_hat, FPhalf* y, int size){
    
    FPhalf nrmse = 0;

    FPhalf* y_error = new FPhalf[size]();

    for (int i = 0; i < size; i++){
        y_error[i] = y_hat[i] - y[i];
    }

    return norm(y_error,size) / norm(y,size);
}

FPhalf get_mse(FPhalf* y_hat, FPhalf* y, int size){
    FPhalf mse = 0;


    for (int i = 0; i < size; i++){
        FPhalf y_error = y_hat[i] - y[i];
        mse += (y_error * y_error);
    }
    mse /= size;

    return mse;

}

