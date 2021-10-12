#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "dfr.h"

int main(){

    // set random number generator seed
    srand(0);
    
    // dfr parameters
    float gamma = 0.05;
    float eta = 0.5;
    int tau = 80;
    int N = 400;

    // learning rate for sgd
    float alpha = 0.0001;

    // inputs & outputs
    int num_samples = 6000;
    int init_samples = 200;
    int m = 4000;
    float* u = narma10_inputs(num_samples);
    float* y = narma10_outputs(u,num_samples);

    // mask
    float* M = generate_mask(N);

    // weights
    float* W = generate_weights(N);

    // reservoir state
    float X[N];
    float X_prev[N];

    // reservoir initialization
    for(int k = 0; k < init_samples; k++){
        for(int node_idx = 0; node_idx < N; node_idx++){
            
            // calculated masked input
            float J = M[node_idx] * u[k];

            // if reservoir has processed the first sample, adjust the mg function input
            float mg_out = 0;
            if(k > 0)
                mg_out = mackey_glass(gamma * J + eta * X[N - 1]);
            else
                mg_out = mackey_glass(gamma * J);
            
            // update node states
            for(int i = N - 1; i > 0; i--){
                X[i] = X[i - 1];
            }
            X[0] = mg_out;

        }
    }

    // reservoir evaluation

    float output_error = 0;
    float total_error = 0;

    float* y_hat = new float[m]();

    for(int k = 0; k < m; k++){

        // reset output result
        float dfr_out = 0;

        for(int node_idx = 0; node_idx < N; node_idx++){

            // update weights for prev sample
            if (k > 0){
                W[node_idx] = W[node_idx] - alpha * output_error * X[N - 1];
            }
            
            // calculated masked input
            float J = M[node_idx] * u[init_samples + k];

            // calculate next node value
            float mg_out = mackey_glass(gamma * J + eta * X[N - 1]);
            
            // update node states
            for(int i = N - 1; i > 0; i--){
                X[i] = X[i - 1];
            }
            X[0] = mg_out;

            // update output calculation
            dfr_out = dfr_out + W[node_idx] * mg_out;

        }

        y_hat[k] = dfr_out;

        // calculate error MSE
        output_error = dfr_out - y[k];

        // report MSE over time
        total_error += (output_error * output_error);
        if (k % 1000 == 0){
            // float mse = (output_error * output_error);
            float mse = total_error / (k + 1);
            printf("MSE[%d] = %f\n",k,mse);
        }
        
    }

    float nrmse = get_nrmse(y_hat,y,m);
    printf("NRMSE = %f\n",nrmse);


}