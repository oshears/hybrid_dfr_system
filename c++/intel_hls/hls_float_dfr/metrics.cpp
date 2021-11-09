#include <stdio.h>
#include <stdlib.h>

#include "HLS/hls.h"
#include "HLS/math.h"
#include "HLS/hls_float.h"
#include "HLS/hls_float_math.h"

#include "dfr.h"

using namespace ihc;

// Frobenius norm
DFR_FP norm(DFR_FP x){
    return ihc_sqrt(x * x);
}

// Frobenius norm for an array
DFR_FP norm(DFR_FP* x, int size){

    DFR_FP sum = 0;
    for (int i = 0; i < size; i++){
        DFR_FP x_i = x[i];
        sum = sum + (x_i * x_i);
    }

    return ihc_sqrt(sum);
}

// calculate kian's nrmse
DFR_FP get_nrmse(DFR_FP* y_hat, DFR_FP* y, int size){
    
    DFR_FP nrmse = 0;

    DFR_FP* y_error = new DFR_FP[size]();

    for (int i = 0; i < size; i++){
        y_error[i] = y_hat[i] - y[i];
    }

    return norm(y_error,size) / norm(y,size);
}

DFR_FP get_mse(DFR_FP* y_hat, DFR_FP* y, int size){
    FPLdouble mse = 0;
    constexpr auto RndZ = ihc::fp_config::FP_Round::RZERO;

    int iter = 0;
    for (int i = 0; i < size; i++){
        FPLdouble y_error = y_hat[i].convert_to<15, 63, RndZ>() - y[i].convert_to<15, 63, RndZ>();

        FPLdouble new_mse = mse;
        new_mse += (y_error * y_error);
        if(new_mse.is_inf() && iter != 1){
            printf("inf @ %d, %s ^ 2 + %s\n",i,y_error.get_str().c_str(),mse.get_str().c_str());
            iter = 1;
        }

        mse += (y_error * y_error);
        // if(i > 14900) printf("%s + %s\n",y_error.get_str().c_str());
        
    }
    mse /= size;


    return mse;

}

