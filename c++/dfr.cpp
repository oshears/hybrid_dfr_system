#include <stdio.h>
#include <stdlib.h>

#include "dfr.h"

int main(){

    // dfr_batch_gd_test();
    // dfr_batch_sgd_test();

    printf("========== DFR Stochastic Gradient Descent ==========\n");

    // set random number generator seed
    srand(0);

    
    // ================== dfr parameters ================== //

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


    // ================== inputs & outputs ================== //


    // total number of samples
    int num_samples = 30000;

    // number of initialization samples
    int init_samples = 200;

    // number of training samples
    int m_train = 20000;

    // number of testing samples
    int m_test = 5000;

    // generate narma10 inputs and outputs
    float* u = narma10_inputs(num_samples);
    float* y = narma10_outputs(u,num_samples);


    // =============== mask & weights =============== //


    // generate mask for each input sample
    float* M = generate_mask(N);

    // generate weights for each virtual node
    float* W = generate_weights(N);

    // initialize an empty reservoir
    float X[N];
    for (int i = 0; i < N; i++)
        X[i] = 0;

    // =============== training phase =============== //

    // configure indexes

    // keep track of the index where the training data ends
    int train_data_end_idx = init_samples + m_train;

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

    // keep track of the output predictions (y_hat)
    float* y_hat = new float[m_train]();

    // keep track of output index, start from 0
    int output_idx = 0;

    // loop from the end of the initialization samples to the end of the training data
    for(int k = init_samples; k < train_data_end_idx; k++){

        // reset output result
        float dfr_out = 0;

        // process each masked input sample (each theta in tau == each node in N)
        for(int node_idx = 0; node_idx < N; node_idx++){

            // if the first training sample was processed, update the current node's weights based on the error of the previous sample
            if (output_idx > 0) W[node_idx] = W[node_idx] - alpha * output_error * X[LAST_NODE];
            
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

        // DEBUG: report NRMSE over time
        if (output_idx % 1000 == 0){
            float nrmse = get_nrmse(y_hat,y,k);
            printf("Train NRMSE[%d]\t= %f\n",k,nrmse);
        }

    }

    printf("=====================\n");

    // calculate the NRMSE of the predicted output
    float nrmse = get_nrmse(y_hat,y,m_train);
    printf("Train NRMSE\t= %f\n",nrmse);
    
    // calculate the MSE of the predicted output
    float mse = get_mse(y_hat,y,m_train);
    printf("Train MSE\t= %f\n",mse);


    // =============== testing phase =============== //


    // configure indexes

    // keep track of the index where the testing initialization data begins
    int test_init_start_data_idx = init_samples + m_train;

    // keep track of the index where the testing data begins
    int test_data_start_idx = test_init_start_data_idx + init_samples;

    // keep track of the index where the tesing data ends
    int test_data_end_idx = test_data_start_idx + m_test;

    // reservoir initialization
    
    // loop for init_samples
    for(int k = test_init_start_data_idx; k < test_data_start_idx; k++){

        // process each masked input sample (each theta in tau == each node in N)
        for(int node_idx = 0; node_idx < N; node_idx++){
            
            // calculate current masked input
            float J = M[node_idx] * u[k];

            // perform nonlinear transformation on the input data and reservoir feedback
            float mg_out = mackey_glass(gamma * J + eta * X[LAST_NODE]);
            
            // update node states by shifting each value to the next virtual node
            for(int i = LAST_NODE; i > 0; i--) X[i] = X[i - 1];

            // store the current output in the first virtual node
            X[0] = mg_out;

        }
    }

    // reservoir evaluation

    // keep track of the output predictions (y_hat)
    float* y_hat_test = new float[m_test]();

    // keep track of output index, start from 0
    output_idx = 0;

    // loop from the end of the initialization samples to the end of the test data
    for(int k = test_data_start_idx; k < test_data_end_idx; k++){

        // reset output result
        float dfr_out = 0;

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
            dfr_out += W[node_idx] * mg_out;

        }

        // store dfr output after the sample has been fully processed
        y_hat_test[output_idx++] = dfr_out;

    }

    printf("=====================\n");

    // calculate the NRMSE of the predicted output
    nrmse = get_nrmse(y_hat_test,y,m_test);
    printf("Test NRMSE\t= %f\n",nrmse);

    // calculate the MSE of the predicted output
    mse = get_mse(y_hat_test,y,m_test);
    printf("Test MSE\t= %f\n",mse);


}