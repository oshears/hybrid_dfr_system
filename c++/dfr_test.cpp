#include <stdio.h>
#include <stdlib.h>

#include "dfr.h"

void dfr_batch_gd_test(){

    // set random number generator seed
    srand(0);
    
    // dfr parameters

    // input gain
    float gamma = 0.05;
    
    // feedback scale
    float eta = 0.5;

    // delay
    int tau = 80;

    // number of virtual nodes
    int N = 400;
    int LAST_NODE = N - 1;

    // learning rate for sgd
    float alpha = 0.001;

    // inputs & outputs

    // total number of samples
    int num_samples = 10000;

    // number of initialization samples
    int init_samples = 200;

    // number of training/testing samples
    int m = 4000;

    // generate narma10 inputs and outputs
    float* u = narma10_inputs(num_samples);
    float* y = narma10_outputs(u,num_samples);

    // generate mask for each input sample
    float* M = generate_mask(N);

    // generate weights for each virtual node
    float* W = generate_weights(N);

    // initialize an empty reservoir
    float X[N];
    for (int i = 0; i < N; i++)
        X[i] = 0;

    // training phase

    // configure indexes

    // keep track of the index where the training data ends
    int train_data_end_idx = init_samples + m;

    // reservoir initialization

    // loop for init_samples
    for(int k = 0; k < init_samples; k++){

        // process each masked input sample (each theta in tau == each node in N)
        for(int node_idx = 0; node_idx < N; node_idx++){
            
            // calculate current masked input
            float J = M[node_idx] * u[k];

            // perform nonlinear transformation on the input data and reservoir feedback
            float mg_out  = mackey_glass(gamma * J + eta * X[LAST_NODE]);
            
            // update node states by shifting each value to the next virtual node
            for(int i = LAST_NODE; i > 0; i--) X[i] = X[i - 1];

            // store the current output in the first virtual node
            X[0] = mg_out;

        }
    }

    // reservoir evaluation

    // keep track of the output error for each sample
    float output_error = 0;

    // DEBUG: keep track of the total error
    float total_error = 0;

    // keep track of the output predictions
    float* y_hat = new float[m]();

    // keep track of the output index
    int output_idx = 0;

    // reservoir history
    float X_history[m][N];

    // loop from the end of the initialization samples to the end of the training data
    for(int k = init_samples; k < train_data_end_idx; k++){

        // process each masked input sample (each theta in tau == each node in N)
        for(int node_idx = 0; node_idx < N; node_idx++){

            // calculated masked input
            float J = M[node_idx] * u[k];

            // perform nonlinear transformation on the input data and reservoir feedback
            float mg_out = mackey_glass(gamma * J + eta * X[LAST_NODE]);
            
            // update node states by shifting each value to the next virtual node
            for(int i = LAST_NODE; i > 0; i--) X[i] = X[i - 1];

            // store the current output in the first virtual node
            X[0] = mg_out;

            // update dfr output calculation (matrix-vector multiplication)
            X_history[output_idx][node_idx] = mg_out;

        }
        output_idx++;
    }

    float output_errors[m];

    float nrmse;
    float mse;

    // standard gradient descent w/ epochs

    int epochs = 1000;
    for(int iter = 0; iter < epochs; iter++){

        // calculate output
        for(int sample = 0; sample < m; sample++){
            float output = 0;
            for (int node = 0; node < N; node++){
                output += W[LAST_NODE - node] * X[node];
            }

            // calculate error
            output_errors[sample] = output - y[sample];
            y_hat[sample] = output;
        }

        // calculate the NRMSE of the predicted output
        if (iter % (epochs/4) == 0){
            nrmse = get_nrmse(y_hat,y,m);
            printf("[%d] Train NRMSE = %f\n",iter,nrmse);

            mse = get_mse(y_hat,y,m);
            printf("Train MSE = %f\n",mse);
        }
            
        // adjust weights
        float delta_W_sum = 0;
        for(int sample = 0; sample < m; sample++){
            for(int node = 0; node < N; node++){
                //adjust weights
                float delta_W = alpha * output_errors[sample] * X[node];
                
                if (node == 0) delta_W_sum += delta_W;
                
                W[LAST_NODE - node] = W[LAST_NODE - node] - delta_W;

            }
            
        }
        if (iter % (epochs/4) == 0){
            printf("\tdelta_W Sum = %f\n",delta_W_sum);
        }
        
    }

    


    // testing phase

    // configure indexes

    // keep track of the index where the testing initialization data begins
    int test_init_start_data_idx = init_samples + m;

    // keep track of the index where the testing data begins
    int test_data_start_idx = test_init_start_data_idx + init_samples;

    // keep track of the index where the tesing data ends
    int test_data_end_idx = test_data_start_idx + m;

    // reservoir initialization
    
    for(int k = test_init_start_data_idx; k < test_data_start_idx; k++){
        for(int node_idx = 0; node_idx < N; node_idx++){
            
            // calculated masked input
            float J = M[node_idx] * u[k];

            // if reservoir has processed the first sample, adjust the mg function input
            float mg_out = mackey_glass(gamma * J + eta * X[LAST_NODE]);
            
            // update node states
            for(int i = LAST_NODE; i > 0; i--) X[i] = X[i - 1];
            X[0] = mg_out;

        }
    }

    // reservoir evaluation

    float* y_hat_test = new float[m]();

    output_idx = 0;

    for(int k = test_data_start_idx; k < test_data_end_idx; k++){

        // reset output result
        float dfr_out = 0;

        for(int node_idx = 0; node_idx < N; node_idx++){

            // calculated masked input
            float J = M[node_idx] * u[k];

            // calculate next node value
            float mg_out = mackey_glass(gamma * J + eta * X[LAST_NODE]);
            
            // update node states
            for(int i = LAST_NODE; i > 0; i--) X[i] = X[i - 1];
            X[0] = mg_out;

            // update output calculation
            dfr_out += W[node_idx] * mg_out;

        }

        // store dfr output
        y_hat_test[output_idx++] = dfr_out;

    }

    nrmse = get_nrmse(y_hat_test,y,m);
    printf("Test NRMSE = %f\n",nrmse);

    mse = get_mse(y_hat_test,y,m);
    printf("Test MSE = %f\n",mse);


}

void dfr_batch_sgd_test(){

    // set random number generator seed
    srand(0);
    
    // dfr parameters

    // input gain
    float gamma = 0.05;
    
    // feedback scale
    float eta = 0.5;

    // delay
    int tau = 80;

    // number of virtual nodes
    int N = 400;
    int LAST_NODE = N - 1;

    // learning rate for sgd
    float alpha = 0.001;

    // batch size for sgd
    int batch_size = 100;

    // inputs & outputs

    // total number of samples
    int num_samples = 10000;

    // number of initialization samples
    int init_samples = 200;

    // number of training/testing samples
    int m = 4000;

    // generate narma10 inputs and outputs
    float* u = narma10_inputs(num_samples);
    float* y = narma10_outputs(u,num_samples);

    // generate mask for each input sample
    float* M = generate_mask(N);

    // generate weights for each virtual node
    float* W = generate_weights(N);

    // initialize an empty reservoir
    float X[N];
    for (int i = 0; i < N; i++)
        X[i] = 0;

    // training phase

    // configure indexes

    // keep track of the index where the training data ends
    int train_data_end_idx = init_samples + m;

    // reservoir initialization

    // loop for init_samples
    for(int k = 0; k < init_samples; k++){

        // process each masked input sample (each theta in tau == each node in N)
        for(int node_idx = 0; node_idx < N; node_idx++){
            
            // calculate current masked input
            float J = M[node_idx] * u[k];

            // perform nonlinear transformation on the input data and reservoir feedback
            float mg_out  = mackey_glass(gamma * J + eta * X[LAST_NODE]);
            
            // update node states by shifting each value to the next virtual node
            for(int i = LAST_NODE; i > 0; i--) X[i] = X[i - 1];

            // store the current output in the first virtual node
            X[0] = mg_out;

        }
    }

    // reservoir evaluation

    // keep track of the output error for each sample
    float output_error = 0;

    // DEBUG: keep track of the total error
    float total_error = 0;

    // keep track of the output predictions
    float* y_hat = new float[m]();

    // keep track of the output index
    int output_idx = 0;

    int batch_idx = 0;

    // temp weights
    float W_temp[N];
    for(int i = 0; i < N; i++) W_temp[i] = W[i];

    // loop from the end of the initialization samples to the end of the training data
    for(int k = init_samples; k < train_data_end_idx; k++){

        // reset output result
        float dfr_out = 0;

        // process each masked input sample (each theta in tau == each node in N)
        for(int node_idx = 0; node_idx < N; node_idx++){

            // if the first training sample was processed, update the current node's weights based on the error of the previous sample
            if (output_idx > 0) W_temp[node_idx] = W_temp[node_idx] - alpha * output_error * X[LAST_NODE];

            // if batch size has been reached, update weights
            if (output_idx % batch_size == 0) W[node_idx] = W_temp[node_idx];
            
            // calculated masked input
            float J = M[node_idx] * u[k];

            // perform nonlinear transformation on the input data and reservoir feedback
            float mg_out = mackey_glass(gamma * J + eta * X[LAST_NODE]);
            
            // update node states by shifting each value to the next virtual node
            for(int i = LAST_NODE; i > 0; i--) X[i] = X[i - 1];

            // store the current output in the first virtual node
            X[0] = mg_out;

            // update dfr output calculation (matrix-vector multiplication)
            dfr_out += W[node_idx] * mg_out;

        }

        // store dfr output after the sample has been fully processed
        y_hat[output_idx++] = dfr_out;

        // calculate the difference between the predicted output and expected output
        output_error = dfr_out - y[output_idx];

        // DEBUG: report MSE over time
        total_error += (output_error * output_error);
        if (output_idx % 1000 == 0){
            float mse = total_error / (k + 1);
            printf("MSE[%d] = %f\n",k,mse);
        }

    }

    // calculate the NRMSE of the predicted output
    float nrmse = get_nrmse(y_hat,y,m);
    printf("Train NRMSE = %f\n",nrmse);

    float mse = get_mse(y_hat,y,m);
    printf("Train MSE = %f\n",mse);


    // testing phase

    // configure indexes

    // keep track of the index where the testing initialization data begins
    int test_init_start_data_idx = init_samples + m;

    // keep track of the index where the testing data begins
    int test_data_start_idx = test_init_start_data_idx + init_samples;

    // keep track of the index where the tesing data ends
    int test_data_end_idx = test_data_start_idx + m;

    // reservoir initialization
    
    for(int k = test_init_start_data_idx; k < test_data_start_idx; k++){
        for(int node_idx = 0; node_idx < N; node_idx++){
            
            // calculated masked input
            float J = M[node_idx] * u[k];

            // if reservoir has processed the first sample, adjust the mg function input
            float mg_out = mackey_glass(gamma * J + eta * X[LAST_NODE]);
            
            // update node states
            for(int i = LAST_NODE; i > 0; i--) X[i] = X[i - 1];
            X[0] = mg_out;

        }
    }

    // reservoir evaluation

    float* y_hat_test = new float[m]();

    output_idx = 0;

    for(int k = test_data_start_idx; k < test_data_end_idx; k++){

        // reset output result
        float dfr_out = 0;

        for(int node_idx = 0; node_idx < N; node_idx++){

            // calculated masked input
            float J = M[node_idx] * u[k];

            // calculate next node value
            float mg_out = mackey_glass(gamma * J + eta * X[LAST_NODE]);
            
            // update node states
            for(int i = LAST_NODE; i > 0; i--) X[i] = X[i - 1];
            X[0] = mg_out;

            // update output calculation
            dfr_out += W[node_idx] * mg_out;

        }

        // store dfr output
        y_hat_test[output_idx++] = dfr_out;

    }

    nrmse = get_nrmse(y_hat_test,y,m);
    printf("Test NRMSE = %f\n",nrmse);

    mse = get_mse(y_hat_test,y,m);
    printf("Test MSE = %f\n",mse);


}