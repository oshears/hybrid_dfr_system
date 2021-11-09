//  Copyright (c) 2021 Intel Corporation                                  
//  SPDX-License-Identifier: MIT                                          
#include <stdio.h>

#include "HLS/hls.h"
#include "HLS/math.h"
#include "HLS/hls_float.h"
#include "HLS/hls_float_math.h"


#include "dfr.h"

using namespace ihc;

DFR_FP MASK[] = {
DFR_FP(0.1844695213843095),
DFR_FP(-0.2308243009875388),
DFR_FP(0.379384693045007),
DFR_FP(0.12531862837886942),
DFR_FP(0.31963441030186024),
DFR_FP(0.07848475992899717),
DFR_FP(0.026910959575573545),
DFR_FP(-0.24754069651724442),
DFR_FP(0.05912404963670359),
DFR_FP(-0.18824303639848894),
DFR_FP(0.28382345601855563),
DFR_FP(-0.04533020315592318),
DFR_FP(0.07454481441100602),
DFR_FP(-0.4817039017638479),
DFR_FP(0.13310825021828876),
DFR_FP(0.10220874511280675),
DFR_FP(-0.33491703431809483),
DFR_FP(-0.084764854777307),
DFR_FP(0.3468994795797784),
DFR_FP(0.20542718862755072),
DFR_FP(-0.4445575514411918),
DFR_FP(-0.4647203853982612),
DFR_FP(-0.4996234836585868),
DFR_FP(0.1195894924597054),
DFR_FP(-0.386695850100201),
DFR_FP(0.3557372406595454),
DFR_FP(0.3950870597718438),
DFR_FP(-0.07954222571661018),
DFR_FP(0.12966496168998654),
DFR_FP(-0.3544313251253989),
DFR_FP(-0.11683407601199969),
DFR_FP(0.38615440701076176),
DFR_FP(0.01212910849110238),
DFR_FP(-0.2522832981877229),
DFR_FP(0.10446660135388475),
DFR_FP(-0.20789735734231363),
DFR_FP(0.014463904385244919),
DFR_FP(0.4957850701534463),
DFR_FP(0.4715508283866162),
DFR_FP(-0.2299096293720605),
DFR_FP(0.4031173638489982),
DFR_FP(-0.46638804519732424),
DFR_FP(0.04910634682180093),
DFR_FP(-0.3219207045248914),
DFR_FP(0.11223595850808321),
DFR_FP(-0.29202115983464594),
DFR_FP(0.25904853971400277),
DFR_FP(-0.09887987531930875),
DFR_FP(0.26287452905700903),
DFR_FP(0.4640670451490331)
};

DFR_FP W[] = {
DFR_FP(-6.603760242462158),
DFR_FP(-375.97887420654297),
DFR_FP(-9.276952743530273),
DFR_FP(-266.8567237854004),
DFR_FP(425.4580078125),
DFR_FP(661.2137622833252),
DFR_FP(-206.8925724029541),
DFR_FP(1272.4864540100098),
DFR_FP(17.395394325256348),
DFR_FP(50.57408332824707),
DFR_FP(-714.5072937011719),
DFR_FP(-37.87939381599426),
DFR_FP(-6.382023572921753),
DFR_FP(-107.54367036372423),
DFR_FP(-492.3594055175781),
DFR_FP(409.37791442871094),
DFR_FP(36.312721252441406),
DFR_FP(14.654291457496583),
DFR_FP(-150.2114622592926),
DFR_FP(-610.1216945648193),
DFR_FP(-82.88774108886719),
DFR_FP(-171.44318771362305),
DFR_FP(991.3926095962524),
DFR_FP(-62.271422386169434),
DFR_FP(64.6613941192627),
DFR_FP(144.72294402122498),
DFR_FP(512.8984661102295),
DFR_FP(-27.28133726119995),
DFR_FP(9.10367202758789),
DFR_FP(-191.64594340324402),
DFR_FP(378.64263916015625),
DFR_FP(188.30925464630127),
DFR_FP(1031.890172958374),
DFR_FP(-281.38884234428406),
DFR_FP(262.6715679168701),
DFR_FP(-484.01390075683594),
DFR_FP(36.5869836807251),
DFR_FP(-521.624098777771),
DFR_FP(2822.2589168548584),
DFR_FP(-547.3736209869385),
DFR_FP(785.2117309570312),
DFR_FP(3147.451301574707),
DFR_FP(-142.90264892578125),
DFR_FP(449.27632158994675),
DFR_FP(-932.9185276031494),
DFR_FP(174.44380950927734),
DFR_FP(173.27429580688477),
DFR_FP(-169.7334280014038),
DFR_FP(-695.9745664596558),
DFR_FP(-1074.1348266601562)
};

DFR_FP mackey_glass(DFR_FP x){

    DFR_FP C = 2;
    DFR_FP b = 2.1;
    DFR_FP p = 10;
    DFR_FP a = 0.8;
    DFR_FP c = 0.2;

    return (C * x) / (a + c * ihc_pow(b * x,p));
}

component DFR_FP dfr(DFR_FP sample) {

  // dfr parameters
  constexpr int N = 50;
  constexpr int LAST_NODE = N - 1;
  DFR_FP gamma = 0.5;
  DFR_FP eta = 0.4;

  static DFR_FP reservoir[N] = {};

  // process sample through reservoir

  // track output
  DFR_FP dfr_out = 0;
  
  // loop through each masked input subsample
  for(int node_idx = 0; node_idx < N; node_idx++){
    
    // calculate next node value based on current subsample
    DFR_FP masked_sample_i = MASK[node_idx] * sample;
    DFR_FP mg_in = gamma * masked_sample_i + eta * reservoir[LAST_NODE];
    DFR_FP mg_out = mackey_glass(mg_in);

    // update reservoir  
    for(int i = LAST_NODE; i > 0; i--) reservoir[i] = reservoir[i - 1];
    reservoir[0] = mg_out;

    // calculate output
    dfr_out += W[LAST_NODE - node_idx] * mg_out;
  }

  return dfr_out;
}

int main() {

  // define sample counts
  constexpr int NUM_INIT_SAMPLES = 200;
  constexpr int NUM_TEST_SAMPLES = 15000;
  constexpr int NUM_TOTAL_SAMPLES = NUM_INIT_SAMPLES + NUM_TEST_SAMPLES;

  // generate narma10 inputs and outputs
  printf("Creating input and output data vectors...\n");
  DFR_FP* u = narma10_inputs(NUM_TOTAL_SAMPLES);
  DFR_FP* y = narma10_outputs(u,NUM_TOTAL_SAMPLES);


  // get test data vectors
  printf("Parsing test input and output vectors...\n");
  DFR_FP* u_test = get_vector_indexes(u,NUM_INIT_SAMPLES,NUM_TOTAL_SAMPLES);
  DFR_FP* y_test = get_vector_indexes(y,NUM_INIT_SAMPLES,NUM_TOTAL_SAMPLES);

  // store test data outputs
  DFR_FP y_hat_test[NUM_TEST_SAMPLES];

  // reservoir initialization
  printf("Initializing Reservoir...\n");
  for(unsigned int i = 0; i < NUM_INIT_SAMPLES; i++) ihc_hls_enqueue_noret(&dfr,u[i]);
  ihc_hls_component_run_all(dfr);

  // reservoir test
  printf("Testing DFR...\n");
  for(unsigned int i = 0; i < NUM_TEST_SAMPLES; i++) ihc_hls_enqueue(&y_hat_test[i], &dfr,u_test[i]);
  ihc_hls_component_run_all(dfr);

  // calculate the NRMSE of the predicted output
  DFR_FP nrmse = get_nrmse(y_hat_test,y_test,NUM_TEST_SAMPLES);
  printf("Test NRMSE\t= %s\n",nrmse.get_str().c_str());

  // calculate the MSE of the predicted output
  DFR_FP mse = get_mse(y_hat_test,y,NUM_TEST_SAMPLES);
  printf("Test MSE\t= %s\n",mse.get_str().c_str());

  return 0;

}
