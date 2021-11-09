#include <stdio.h>
#include <stdlib.h>

#include "HLS/hls.h"
#include "HLS/math.h"
#include "HLS/ac_fixed.h"
#include "HLS/ac_fixed_math.h"

#include "dfr.h"

using namespace ihc;

// Frobenius norm
FixedPoint norm(FixedPoint x){
    return ihc_sqrt(x * x);
}

// Frobenius norm for an array
FixedPoint norm(FixedPoint* x, int size){

    FixedPoint sum = 0;
    for (int i = 0; i < size; i++){
        FixedPoint x_i = x[i];
        sum = sum + (x_i * x_i);
    }

    return ihc_sqrt(sum);
}

// calculate kian's nrmse
FixedPoint get_nrmse(FixedPoint* y_hat, FixedPoint* y, int size){
    
    FixedPoint nrmse = 0;

    FixedPoint* y_error = new FixedPoint[size]();

    for (int i = 0; i < size; i++){
        y_error[i] = y_hat[i] - y[i];
    }

    return norm(y_error,size) / norm(y,size);
}

FixedPoint get_mse(FixedPoint* y_hat, FixedPoint* y, int size){
    FixedPoint mse = 0;


    for (int i = 0; i < size; i++){
        FixedPoint y_error = y_hat[i] - y[i];
        mse += (y_error * y_error);
    }
    mse /= size;

    return mse;

}

