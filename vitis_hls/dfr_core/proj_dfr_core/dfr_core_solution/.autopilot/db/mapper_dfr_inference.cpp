#include <systemc>
#include <vector>
#include <iostream>
#include "hls_stream.h"
#include "ap_int.h"
#include "ap_fixed.h"
using namespace std;
using namespace sc_dt;
class AESL_RUNTIME_BC {
  public:
    AESL_RUNTIME_BC(const char* name) {
      file_token.open( name);
      if (!file_token.good()) {
        cout << "Failed to open tv file " << name << endl;
        exit (1);
      }
      file_token >> mName;//[[[runtime]]]
    }
    ~AESL_RUNTIME_BC() {
      file_token.close();
    }
    int read_size () {
      int size = 0;
      file_token >> mName;//[[transaction]]
      file_token >> mName;//transaction number
      file_token >> mName;//pop_size
      size = atoi(mName.c_str());
      file_token >> mName;//[[/transaction]]
      return size;
    }
  public:
    fstream file_token;
    string mName;
};
extern "C" void dfr_inference(int*, int*, long long*);
extern "C" void apatb_dfr_inference_hw(volatile void * __xlx_apatb_param_inputs, volatile void * __xlx_apatb_param_weights, volatile void * __xlx_apatb_param_outputs) {
  // Collect __xlx_inputs__tmp_vec
  vector<sc_bv<32> >__xlx_inputs__tmp_vec;
  for (int j = 0, e = 510200; j != e; ++j) {
    __xlx_inputs__tmp_vec.push_back(((int*)__xlx_apatb_param_inputs)[j]);
  }
  int __xlx_size_param_inputs = 510200;
  int __xlx_offset_param_inputs = 0;
  int __xlx_offset_byte_param_inputs = 0*4;
  int* __xlx_inputs__input_buffer= new int[__xlx_inputs__tmp_vec.size()];
  for (int i = 0; i < __xlx_inputs__tmp_vec.size(); ++i) {
    __xlx_inputs__input_buffer[i] = __xlx_inputs__tmp_vec[i].range(31, 0).to_uint64();
  }
  // Collect __xlx_weights__tmp_vec
  vector<sc_bv<32> >__xlx_weights__tmp_vec;
  for (int j = 0, e = 100; j != e; ++j) {
    __xlx_weights__tmp_vec.push_back(((int*)__xlx_apatb_param_weights)[j]);
  }
  int __xlx_size_param_weights = 100;
  int __xlx_offset_param_weights = 0;
  int __xlx_offset_byte_param_weights = 0*4;
  int* __xlx_weights__input_buffer= new int[__xlx_weights__tmp_vec.size()];
  for (int i = 0; i < __xlx_weights__tmp_vec.size(); ++i) {
    __xlx_weights__input_buffer[i] = __xlx_weights__tmp_vec[i].range(31, 0).to_uint64();
  }
  // Collect __xlx_outputs__tmp_vec
  vector<sc_bv<64> >__xlx_outputs__tmp_vec;
  for (int j = 0, e = 5082; j != e; ++j) {
    __xlx_outputs__tmp_vec.push_back(((long long*)__xlx_apatb_param_outputs)[j]);
  }
  int __xlx_size_param_outputs = 5082;
  int __xlx_offset_param_outputs = 0;
  int __xlx_offset_byte_param_outputs = 0*8;
  long long* __xlx_outputs__input_buffer= new long long[__xlx_outputs__tmp_vec.size()];
  for (int i = 0; i < __xlx_outputs__tmp_vec.size(); ++i) {
    __xlx_outputs__input_buffer[i] = __xlx_outputs__tmp_vec[i].range(63, 0).to_uint64();
  }
  // DUT call
  dfr_inference(__xlx_inputs__input_buffer, __xlx_weights__input_buffer, __xlx_outputs__input_buffer);
// print __xlx_apatb_param_inputs
  sc_bv<32>*__xlx_inputs_output_buffer = new sc_bv<32>[__xlx_size_param_inputs];
  for (int i = 0; i < __xlx_size_param_inputs; ++i) {
    __xlx_inputs_output_buffer[i] = __xlx_inputs__input_buffer[i+__xlx_offset_param_inputs];
  }
  for (int i = 0; i < __xlx_size_param_inputs; ++i) {
    ((int*)__xlx_apatb_param_inputs)[i] = __xlx_inputs_output_buffer[i].to_uint64();
  }
// print __xlx_apatb_param_weights
  sc_bv<32>*__xlx_weights_output_buffer = new sc_bv<32>[__xlx_size_param_weights];
  for (int i = 0; i < __xlx_size_param_weights; ++i) {
    __xlx_weights_output_buffer[i] = __xlx_weights__input_buffer[i+__xlx_offset_param_weights];
  }
  for (int i = 0; i < __xlx_size_param_weights; ++i) {
    ((int*)__xlx_apatb_param_weights)[i] = __xlx_weights_output_buffer[i].to_uint64();
  }
// print __xlx_apatb_param_outputs
  sc_bv<64>*__xlx_outputs_output_buffer = new sc_bv<64>[__xlx_size_param_outputs];
  for (int i = 0; i < __xlx_size_param_outputs; ++i) {
    __xlx_outputs_output_buffer[i] = __xlx_outputs__input_buffer[i+__xlx_offset_param_outputs];
  }
  for (int i = 0; i < __xlx_size_param_outputs; ++i) {
    ((long long*)__xlx_apatb_param_outputs)[i] = __xlx_outputs_output_buffer[i].to_uint64();
  }
}
