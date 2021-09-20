#define VIRTUAL_NODES	100
#define SAMPLES	6102

#define TP VIRTUAL_NODES

#define INIT_LEN 20
#define TRAIN_LEN 49 * INIT_LEN
#define TEST_LEN (SAMPLES - (TRAIN_LEN + INIT_LEN + INIT_LEN))

#define GAMMA 1.0
#define ETA 1.0 / 16.0

#define MAX_MG_OUTPUT 0x1000
#define MAX_INPUT 0x10000


int mackey_glass(int x);

void dfr_inference(volatile float *inputs, volatile int *weights, volatile long *outputs, int virtual_nodes, int num_samples, int init_len, int train_len, int test_len, int gamma, int eta, int max_input);
