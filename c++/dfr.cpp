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
    float inputs[size];

    for (int i = 0; i < size; i++){
        float u = 0.2 * (static_cast<float>(rand()) / static_cast<float>(RAND_MAX)) - 0.1;
        inputs[i] = u;
    }

    return inputs;
}

// narma10 outputs
float* narma10_outputs(float* inputs, int size){

    float outputs[size];

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
	
	float mask[size];

    for(int i = 0; i < size; i++){
        int random = rand();
        mask[i] = (random & 1 == 0) ? 0.1 : -0.1;
    }

    return mask;
}

// generate random weight matrix
float* generate_weights(int size){
    float weights[size];
    for(int i = 0; i < size; i++){
        weights[i] = static_cast<float>(rand()) / static_cast<float>(RAND_MAX);
    }
    return weights;
}


int main(){
    
    int num_samples = 6000;
    int init_samples = 200;
    int m = 4000;

    float gamma = 0.05;
    float eta = 0.5;

    int tau = 80;
    int N = 400;


    // inputs & outputs
    float* u = narma10_inputs(num_samples);
    float* y = narma10_outputs(u,num_samples);

    // mask
    float* M = generate_mask(N);

    // weights
    float* W = generate_weights(N);

    // reservoir initialization
    float X[N];

    for(int k = 0; k < init_samples; k++){
        for(int node_idx = 0; node_idx < N; node_idx++){
            
            float J = M[node_idx] * u[k];

            // if reservoir has processed the first sample
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

    for(int k = 0; k < m; k++){
        for(int node_idx = 0; node_idx < N; node_idx++){
            
            float J = M[node_idx] * u[init_samples + k];

            // if reservoir has processed the first sample
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


    // ridge regression

}