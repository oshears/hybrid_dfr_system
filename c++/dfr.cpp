#include <stdio.h>
#include <stdlib.h>


//mackey glass function
float mackey_glass(float x){

    float C = 1.33;
    float b = 0.4;

    return (C * x) / (1 + b * x);
}

// narma10 inputs
float* narma10_inputs(int size){

    float* inputs = (float*) malloc(sizeof(float)*size);

    for (int i = 0; i < size; i++){
        float u = 0.5 * (static_cast<float>(rand()) / static_cast<float>(RAND_MAX));
        inputs[i] = u;
    }

    return inputs;
}

// narma10 outputs
float* narma10_outputs(float* inputs, int size){

    float* outputs = (float*) malloc(sizeof(float)*size);

    for (int i = 0; i < 10; i++){
        outputs[i] = 0;
    }

    // determine output from index 10 to size - 1
    for (int i = 9; i < size - 1; i++){

        // calculate sum of last 10 outputs
        float sum = 0;
        for (int j = 0; j < 10; j++){
            sum = sum + outputs[i - j];
        }

        outputs[i + 1] = 0.3 * outputs[i] + 0.05 * outputs[i] * sum + 1.5 * inputs[i] * inputs[i - 9] + 0.1;
    }

    return outputs;
}

// generate mask of random values of -0.1 or 0.1
float* generate_mask(int size){
	
    float* mask = (float*) malloc(sizeof(float)*size);


    for(int i = 0; i < size; i++){
        int random = rand();
        mask[i] = (random & 1 == 0) ? 0.1 : -0.1;
    }

    return mask;
}

// generate random weight matrix in range [-1,1]
float* generate_weights(int size){

    float* weights = (float*) malloc(sizeof(float)*size);

    for(int i = 0; i < size; i++){
        weights[i] = 2 * ( static_cast<float>(rand()) / static_cast<float>(RAND_MAX) ) - 1;
    }
    return weights;
}


int main(){

    // set random number generator seed
    srand(0);
    
    int num_samples = 6000;
    int init_samples = 200;
    int m = 4000;

    float gamma = 0.05;
    float eta = 0.5;

    int tau = 80;
    int N = 400;

    // learning rate for backpropagation
    float alpha = 0.0001;


    // inputs & outputs
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

    for(int k = 0; k < m; k++){

        // reset output result
        float y_hat = 0;

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
            y_hat = y_hat + W[node_idx] * mg_out;

        }

        // calculate error MSE
        output_error = y_hat - y[k];

        // report MSE over time
        total_error += (output_error * output_error);
        if (k % 100 == 0){
            // float mse = (output_error * output_error);
            float mse = total_error / (k + 1);
            printf("MSE[%d] = %f\n",k,mse);
        }
        
    }


}