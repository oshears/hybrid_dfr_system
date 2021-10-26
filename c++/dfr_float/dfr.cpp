#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <fstream>

#include "dfr.h"

int main(){

    // dfr_batch_gd_test();
    // dfr_batch_sgd_test();

    printf("========== DFR Stochastic Gradient Descent ==========\n");

    // set random number generator seed
    srand(0);

    
    // ================== dfr parameters ================== //

    // input gain
    float gamma = 0.5;
    
    // feedback scale
    float eta = 0.4;

    // delay
    // int tau = 80;

    // number of virtual nodes
    int N = 50;
    int LAST_NODE = N - 1;

    // learning rate for sgd
    float alpha = 0.001;


    // ================== inputs & outputs ================== //

    // total number of samples
    int num_samples = 20000;

    // number of initialization samples
    int init_samples = 200;

    // number of training samples
    int m_train = 15000;

    // number of testing samples
    int m_test = 1000;

    // generate narma10 inputs and outputs
    float* u = narma10_inputs(num_samples);
    float* y = narma10_outputs(u,num_samples);

    // keep track of the index where the training data begins
    int train_data_start_idx = init_samples;
    
    // keep track of the index where the training data ends
    int train_data_end_idx = train_data_start_idx + m_train;
    
    // keep track of the index where the testing data begins
    int test_data_start_idx = train_data_end_idx + init_samples;
    
    // keep track of the index where the tesing data ends
    int test_data_end_idx = test_data_start_idx + m_test;

    // make subvector containing y train outputs
    float* y_train = get_vector_indexes(y, train_data_start_idx, train_data_end_idx);
    
    // make subvector containing y test outputs
    float* y_test  = get_vector_indexes(y, test_data_start_idx, test_data_end_idx);


    // =============== mask & weights =============== //

    // generate mask for each input sample
    float* M = generate_mask_range(-0.5,0.5,N);

    // generate weights for each virtual node
    float* W = generate_weights(N);

    // initialize an empty reservoir
    float X[N];
    for (int i = 0; i < N; i++) X[i] = 0;


    // =============== training phase =============== //

    // reservoir initialization

    // loop for init_samples
    for(int k = 0; k < train_data_start_idx; k++){

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

    // keep track of output index, start from 0
    int output_idx = 0;

    std::ofstream trainFile;
    trainFile.open ("dfr_train_progress.csv");
    trainFile << "weight change,output error" << std::endl;

    int batch_size = 16;
    float new_W[N];
    for (int i = 0; i < N; i++) new_W[i] = W[i];

    // loop from the end of the initialization samples to the end of the training data
    for(int k = train_data_start_idx; k < train_data_end_idx; k++){

        // reset output result
        float dfr_out = 0;

        float weight_change[m_train / batch_size];

        // process each masked input sample (each theta in tau == each node in N)
        for(int node_idx = 0; node_idx < N; node_idx++){
            
            // if the end of the batch is reached
            if (output_idx % batch_size == 0){
                // DEBUG: monitor weight changes
                float weight_difference = W[node_idx] - new_W[node_idx];
                weight_change[node_idx] = (weight_difference > 0) ? weight_difference : -1 * weight_difference;
                
                // update the weights according to the batch changes
                W[node_idx] = new_W[node_idx];
            } 
            
            // if the first training sample was processed, update the current node's weights based on the error of the previous sample
            if (output_idx > 0) new_W[node_idx] = new_W[node_idx] - alpha * output_error * X[LAST_NODE];

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

        // calculate the difference between the predicted output and expected output
        output_error = dfr_out - y_train[output_idx++];

        // calc avg weight change
        float avg_weight_change = 0;
        for (int i = 0; i < N; i++) if (weight_change >= 0) avg_weight_change += weight_change[i]; else avg_weight_change -= weight_change[i];
        avg_weight_change / N;

        // if(output_idx % static_cast<int>(m_train / 100) == 0){
        //     printf("%d\n",static_cast<int>(m_train / 1000));
        // printf("[%d] output error: %f\n",k,output_error);
        float reported_error = (output_error > 0) ? output_error : -1 * output_error;
        trainFile << std::fixed << avg_weight_change << "," << std::fixed << reported_error << std::endl;
        // }

    }

    // =============== training evaluation phase =============== //

    // reservoir initialization

    // clear reservoir
    for (int i = 0; i < N; i++) X[i] = 0;

    // loop for init_samples
    for(int k = 0; k < train_data_start_idx; k++){

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

    // keep track of the output predictions (y_hat_train)
    float* y_hat_train = new float[m_train]();

    // keep track of output index, start from 0
    output_idx = 0;

    // loop from the end of the initialization samples to the end of the training data
    for(int k = train_data_start_idx; k < train_data_end_idx; k++){

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
        y_hat_train[output_idx++] = dfr_out;
    }

    printf("=====================\n");

    // calculate the NRMSE of the predicted output
    float nrmse = get_nrmse(y_hat_train,y_train,m_train);
    printf("Train NRMSE\t= %f\n",nrmse);
    
    // calculate the MSE of the predicted output
    float mse = get_mse(y_hat_train,y_train,m_train);
    printf("Train MSE\t= %f\n",mse);


    // =============== testing phase =============== //

    // reservoir initialization
    
    // loop for init_samples
    for(int k = train_data_end_idx; k < test_data_start_idx; k++){

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

    // keep track of the output predictions (y_hat_test)
    float* y_hat_test = new float[m_test]();

    // keep track of output index, start from 0
    output_idx = 0;

    std::ofstream outFile;
    outFile.open ("dfr_outputs.csv");
    outFile << "inputs,actual,expected" << std::endl;

    // loop from the end of the initialization samples to the end of the test data
    for(int k = test_data_start_idx; k < test_data_end_idx; k++){

        // reset output result
        float dfr_out = 0;

        // process each masked input sample (each theta in tau == each node in N)
        for(int node_idx = 0; node_idx < N; node_idx++){

            if(output_idx < 1){
                // printf("W[%d] = %f\n",node_idx,W[node_idx]);
            }

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

        // printf("[%d] Actual: %f; Expected: %f\n",dfr_out,y_test[output_idx - 1]);
        outFile << std::fixed << u[k] << "," << std::fixed << dfr_out << "," << std::fixed << y_test[output_idx - 1] << std::endl;

    }

    outFile.close();

    printf("=====================\n");

    // calculate the NRMSE of the predicted output
    nrmse = get_nrmse(y_hat_test,y_test,m_test);
    printf("Test NRMSE\t= %f\n",nrmse);

    // calculate the MSE of the predicted output
    mse = get_mse(y_hat_test,y_test,m_test);
    printf("Test MSE\t= %f\n",mse);


}