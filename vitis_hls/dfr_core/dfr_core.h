#define VIRTUAL_NODES	100
#define SAMPLES	6102

#define TP VIRTUAL_NODES

#define INIT_LEN 20
#define TRAIN_LEN 980
#define TEST_LEN 5082

#define MAX_MG_OUTPUT 0x1000
#define MAX_INPUT 0x10000


int mackey_glass(int x);

void dfr_inference(volatile float *inputs, volatile int *weights, volatile unsigned long *outputs, unsigned int virtual_nodes, unsigned int num_samples, unsigned int init_len, unsigned int train_len, unsigned int test_len, unsigned int gamma, unsigned int eta, unsigned int max_input);
