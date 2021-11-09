//  Copyright (c) 2021 Intel Corporation                                  
//  SPDX-License-Identifier: MIT                                          
#include <stdio.h>

#include "HLS/hls.h"
#include "HLS/math.h"
#include "HLS/hls_float.h"
#include "HLS/hls_float_math.h"


#include "dfr.h"

using namespace ihc;

FPhalf MASK[] = {
FPhalf(0.1844695213843095),
FPhalf(-0.2308243009875388),
FPhalf(0.379384693045007),
FPhalf(0.12531862837886942),
FPhalf(0.31963441030186024),
FPhalf(0.07848475992899717),
FPhalf(0.026910959575573545),
FPhalf(-0.24754069651724442),
FPhalf(0.05912404963670359),
FPhalf(-0.18824303639848894),
FPhalf(0.28382345601855563),
FPhalf(-0.04533020315592318),
FPhalf(0.07454481441100602),
FPhalf(-0.4817039017638479),
FPhalf(0.13310825021828876),
FPhalf(0.10220874511280675),
FPhalf(-0.33491703431809483),
FPhalf(-0.084764854777307),
FPhalf(0.3468994795797784),
FPhalf(0.20542718862755072),
FPhalf(-0.4445575514411918),
FPhalf(-0.4647203853982612),
FPhalf(-0.4996234836585868),
FPhalf(0.1195894924597054),
FPhalf(-0.386695850100201),
FPhalf(0.3557372406595454),
FPhalf(0.3950870597718438),
FPhalf(-0.07954222571661018),
FPhalf(0.12966496168998654),
FPhalf(-0.3544313251253989),
FPhalf(-0.11683407601199969),
FPhalf(0.38615440701076176),
FPhalf(0.01212910849110238),
FPhalf(-0.2522832981877229),
FPhalf(0.10446660135388475),
FPhalf(-0.20789735734231363),
FPhalf(0.014463904385244919),
FPhalf(0.4957850701534463),
FPhalf(0.4715508283866162),
FPhalf(-0.2299096293720605),
FPhalf(0.4031173638489982),
FPhalf(-0.46638804519732424),
FPhalf(0.04910634682180093),
FPhalf(-0.3219207045248914),
FPhalf(0.11223595850808321),
FPhalf(-0.29202115983464594),
FPhalf(0.25904853971400277),
FPhalf(-0.09887987531930875),
FPhalf(0.26287452905700903),
FPhalf(0.4640670451490331)
};

FPhalf W[] = {
FPhalf(-6.603760242462158),
FPhalf(-375.97887420654297),
FPhalf(-9.276952743530273),
FPhalf(-266.8567237854004),
FPhalf(425.4580078125),
FPhalf(661.2137622833252),
FPhalf(-206.8925724029541),
FPhalf(1272.4864540100098),
FPhalf(17.395394325256348),
FPhalf(50.57408332824707),
FPhalf(-714.5072937011719),
FPhalf(-37.87939381599426),
FPhalf(-6.382023572921753),
FPhalf(-107.54367036372423),
FPhalf(-492.3594055175781),
FPhalf(409.37791442871094),
FPhalf(36.312721252441406),
FPhalf(14.654291457496583),
FPhalf(-150.2114622592926),
FPhalf(-610.1216945648193),
FPhalf(-82.88774108886719),
FPhalf(-171.44318771362305),
FPhalf(991.3926095962524),
FPhalf(-62.271422386169434),
FPhalf(64.6613941192627),
FPhalf(144.72294402122498),
FPhalf(512.8984661102295),
FPhalf(-27.28133726119995),
FPhalf(9.10367202758789),
FPhalf(-191.64594340324402),
FPhalf(378.64263916015625),
FPhalf(188.30925464630127),
FPhalf(1031.890172958374),
FPhalf(-281.38884234428406),
FPhalf(262.6715679168701),
FPhalf(-484.01390075683594),
FPhalf(36.5869836807251),
FPhalf(-521.624098777771),
FPhalf(2822.2589168548584),
FPhalf(-547.3736209869385),
FPhalf(785.2117309570312),
FPhalf(3147.451301574707),
FPhalf(-142.90264892578125),
FPhalf(449.27632158994675),
FPhalf(-932.9185276031494),
FPhalf(174.44380950927734),
FPhalf(173.27429580688477),
FPhalf(-169.7334280014038),
FPhalf(-695.9745664596558),
FPhalf(-1074.1348266601562)
};

int iteration = 0;
constexpr auto Rnd = ihc::fp_config::FP_Round::RZERO;
using double_type  = ihc::hls_float<11, 52, Rnd>;
#include <cmath>

FPhalf mackey_glass(FPhalf x){

    FPhalf C = 2;
    FPhalf b = 2.1;
    FPhalf p = 10;
    FPhalf a = 0.8;
    FPhalf c = 0.2;

    if(iteration == 0){
      printf("%s\n",(b * x).get_str().c_str());
      printf("%s\n",(ihc_powr( double_type(b * x), double_type(p)  ) ).get_str().c_str());
      printf("%s\n",(ihc_powr( double_type(b * x), double_type(p)  ) ).get_str().c_str());
      printf("%s\n",(c * ihc_powr(b * x, p)).get_str().c_str());
      printf("%s\n",(a + c * ihc_powr(b * x, p)).get_str().c_str());
      printf("%s\n",(C * x).get_str().c_str());
      printf("%s\n",((C * x) / (a + c * ihc_powr(b * x, p) )).get_str().c_str());
    }

    return (C * x) / (a + c * ihc_powr(b * x, p) );

}

component FPhalf dfr(FPhalf sample) {

  // dfr parameters
  constexpr int N = 50;
  constexpr int LAST_NODE = N - 1;
  FPhalf gamma = 0.5;
  FPhalf eta = 0.4;

  static FPhalf reservoir[N] = {};

  // process sample through reservoir

  // track output
  FPhalf dfr_out = 0;
  
  // loop through each masked input subsample
  for(int node_idx = 0; node_idx < N; node_idx++){
    
    // calculate next node value based on current subsample
    FPhalf masked_sample_i = MASK[node_idx] * sample;
    FPhalf mg_in = gamma * masked_sample_i + eta * reservoir[LAST_NODE];
    FPhalf mg_out = mackey_glass(mg_in);

    // update reservoir  
    for(int i = LAST_NODE; i > 0; i--) reservoir[i] = reservoir[i - 1];
    reservoir[0] = mg_out;

    if(iteration == 0)
      printf("node_idx[%d] = %s = %s * %s + %s * %s\n",LAST_NODE - node_idx, mg_out.get_str().c_str(),gamma.get_str().c_str(),masked_sample_i.get_str().c_str(),eta.get_str().c_str(),reservoir[LAST_NODE].get_str().c_str());

    // calculate output
    dfr_out += W[LAST_NODE - node_idx] * mg_out;
  }
  iteration++;

  return dfr_out;
}

int main() {

  // define sample counts
  constexpr int NUM_INIT_SAMPLES = 200;
  constexpr int NUM_TEST_SAMPLES = 15000;
  constexpr int NUM_TOTAL_SAMPLES = NUM_INIT_SAMPLES + NUM_TEST_SAMPLES;

  // generate narma10 inputs and outputs
  printf("Creating input and output data vectors...\n");
  FPhalf* u = narma10_inputs(NUM_TOTAL_SAMPLES);
  FPhalf* y = narma10_outputs(u,NUM_TOTAL_SAMPLES);
  // char const* narma10_input_file = "./data/FPhalf_input_data.txt";
  // FPhalf* u = read_FPhalf_vector_from_file(narma10_input_file,NUM_TOTAL_SAMPLES);
  // char const* narma10_output_file = "./data/FPhalf_output_data.txt";
  // FPhalf* y = read_FPhalf_vector_from_file(narma10_output_file,NUM_TOTAL_SAMPLES);


  // get test data vectors
  printf("Parsing test input and output vectors...\n");
  FPhalf* u_test = get_vector_indexes(u,NUM_INIT_SAMPLES,NUM_TOTAL_SAMPLES);
  FPhalf* y_test = get_vector_indexes(y,NUM_INIT_SAMPLES,NUM_TOTAL_SAMPLES);

  // store test data outputs
  FPhalf y_hat_test[NUM_TEST_SAMPLES];

  // reservoir initialization
  printf("Initializing Reservoir...\n");
  for(unsigned int i = 0; i < NUM_INIT_SAMPLES; i++) ihc_hls_enqueue_noret(&dfr,u[i]);
  ihc_hls_component_run_all(dfr);

  // reservoir test
  printf("Testing DFR...\n");
  for(unsigned int i = 0; i < NUM_TEST_SAMPLES; i++) ihc_hls_enqueue(&y_hat_test[i], &dfr,u_test[i]);
  ihc_hls_component_run_all(dfr);

  // calculate the NRMSE of the predicted output
  FPhalf nrmse = get_nrmse(y_hat_test,y_test,NUM_TEST_SAMPLES);
  printf("Test NRMSE\t= %s\n",nrmse.get_str().c_str());

  // calculate the MSE of the predicted output
  FPhalf mse = get_mse(y_hat_test,y,NUM_TEST_SAMPLES);
  printf("Test MSE\t= %s\n",mse.get_str().c_str());

  return 0;

}
