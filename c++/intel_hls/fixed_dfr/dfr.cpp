//  Copyright (c) 2021 Intel Corporation                                  
//  SPDX-License-Identifier: MIT                                          
#include <stdio.h>

#include "HLS/hls.h"
#include "HLS/math.h"
#include "HLS/ac_fixed.h"
#include "HLS/ac_fixed_math.h"


#include "dfr.h"

using namespace ihc;

FixedPoint MASK[] = {
FixedPoint(0.1844695213843095),
FixedPoint(-0.2308243009875388),
FixedPoint(0.379384693045007),
FixedPoint(0.12531862837886942),
FixedPoint(0.31963441030186024),
FixedPoint(0.07848475992899717),
FixedPoint(0.026910959575573545),
FixedPoint(-0.24754069651724442),
FixedPoint(0.05912404963670359),
FixedPoint(-0.18824303639848894),
FixedPoint(0.28382345601855563),
FixedPoint(-0.04533020315592318),
FixedPoint(0.07454481441100602),
FixedPoint(-0.4817039017638479),
FixedPoint(0.13310825021828876),
FixedPoint(0.10220874511280675),
FixedPoint(-0.33491703431809483),
FixedPoint(-0.084764854777307),
FixedPoint(0.3468994795797784),
FixedPoint(0.20542718862755072),
FixedPoint(-0.4445575514411918),
FixedPoint(-0.4647203853982612),
FixedPoint(-0.4996234836585868),
FixedPoint(0.1195894924597054),
FixedPoint(-0.386695850100201),
FixedPoint(0.3557372406595454),
FixedPoint(0.3950870597718438),
FixedPoint(-0.07954222571661018),
FixedPoint(0.12966496168998654),
FixedPoint(-0.3544313251253989),
FixedPoint(-0.11683407601199969),
FixedPoint(0.38615440701076176),
FixedPoint(0.01212910849110238),
FixedPoint(-0.2522832981877229),
FixedPoint(0.10446660135388475),
FixedPoint(-0.20789735734231363),
FixedPoint(0.014463904385244919),
FixedPoint(0.4957850701534463),
FixedPoint(0.4715508283866162),
FixedPoint(-0.2299096293720605),
FixedPoint(0.4031173638489982),
FixedPoint(-0.46638804519732424),
FixedPoint(0.04910634682180093),
FixedPoint(-0.3219207045248914),
FixedPoint(0.11223595850808321),
FixedPoint(-0.29202115983464594),
FixedPoint(0.25904853971400277),
FixedPoint(-0.09887987531930875),
FixedPoint(0.26287452905700903),
FixedPoint(0.4640670451490331)
};

FixedPoint W[] = {
FixedPoint(-6.603760242462158),
FixedPoint(-375.97887420654297),
FixedPoint(-9.276952743530273),
FixedPoint(-266.8567237854004),
FixedPoint(425.4580078125),
FixedPoint(661.2137622833252),
FixedPoint(-206.8925724029541),
FixedPoint(1272.4864540100098),
FixedPoint(17.395394325256348),
FixedPoint(50.57408332824707),
FixedPoint(-714.5072937011719),
FixedPoint(-37.87939381599426),
FixedPoint(-6.382023572921753),
FixedPoint(-107.54367036372423),
FixedPoint(-492.3594055175781),
FixedPoint(409.37791442871094),
FixedPoint(36.312721252441406),
FixedPoint(14.654291457496583),
FixedPoint(-150.2114622592926),
FixedPoint(-610.1216945648193),
FixedPoint(-82.88774108886719),
FixedPoint(-171.44318771362305),
FixedPoint(991.3926095962524),
FixedPoint(-62.271422386169434),
FixedPoint(64.6613941192627),
FixedPoint(144.72294402122498),
FixedPoint(512.8984661102295),
FixedPoint(-27.28133726119995),
FixedPoint(9.10367202758789),
FixedPoint(-191.64594340324402),
FixedPoint(378.64263916015625),
FixedPoint(188.30925464630127),
FixedPoint(1031.890172958374),
FixedPoint(-281.38884234428406),
FixedPoint(262.6715679168701),
FixedPoint(-484.01390075683594),
FixedPoint(36.5869836807251),
FixedPoint(-521.624098777771),
FixedPoint(2822.2589168548584),
FixedPoint(-547.3736209869385),
FixedPoint(785.2117309570312),
FixedPoint(3147.451301574707),
FixedPoint(-142.90264892578125),
FixedPoint(449.27632158994675),
FixedPoint(-932.9185276031494),
FixedPoint(174.44380950927734),
FixedPoint(173.27429580688477),
FixedPoint(-169.7334280014038),
FixedPoint(-695.9745664596558),
FixedPoint(-1074.1348266601562)
};

int iteration = 0;
// constexpr auto Rnd = ihc::fp_config::FP_Round::RZERO;
// using double_type  = ihc::hls_float<11, 52, Rnd>;
// #include <cmath>

FixedPoint mackey_glass(FixedPoint x){

    FixedPoint C = 2;
    FixedPoint b = 2.1;
    FixedPoint p = 10;
    FixedPoint a = 0.8;
    FixedPoint c = 0.2;

    // if(iteration == 0){
    //   printf("%s\n",(b * x).get_str().c_str());
    //   printf("%s\n",(ihc_powr( double_type(b * x), double_type(p)  ) ).get_str().c_str());
    //   // printf("%s\n",(ihc_powr( double_type(b.HLSLDoubleToLongDouble() * x), double_type(p)  ) ).get_str().c_str());
    //   printf("%s\n",(c * ihc_powr(b * x, p)).get_str().c_str());
    //   printf("%s\n",(a + c * ihc_powr(b * x, p)).get_str().c_str());
    //   printf("%s\n",(C * x).get_str().c_str());
    //   printf("%s\n",((C * x) / (a + c * ihc_powr(b * x, p) )).get_str().c_str());
    // }

    // if (ihc_powr(b * x, p).is_nan())
    //   return 1;
    // else
    return (C * x) / (a + c * ihc_powr(b * x, p) );
    // return ihc_atan(x);

}

component FixedPoint dfr(FixedPoint sample) {

  // dfr parameters
  constexpr int N = 50;
  constexpr int LAST_NODE = N - 1;
  FixedPoint gamma = 0.5;
  FixedPoint eta = 0.4;

  static FixedPoint reservoir[N] = {};

  // process sample through reservoir

  // track output
  FixedPoint dfr_out = 0;
  
  // loop through each masked input subsample
  for(int node_idx = 0; node_idx < N; node_idx++){
    
    // calculate next node value based on current subsample
    FixedPoint masked_sample_i = MASK[node_idx] * sample;
    FixedPoint mg_in = gamma * masked_sample_i + eta * reservoir[LAST_NODE];
    FixedPoint mg_out = mackey_glass(mg_in);

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
  FixedPoint* u = narma10_inputs(NUM_TOTAL_SAMPLES);
  FixedPoint* y = narma10_outputs(u,NUM_TOTAL_SAMPLES);
  // char const* narma10_input_file = "./data/FixedPoint_input_data.txt";
  // FixedPoint* u = read_FixedPoint_vector_from_file(narma10_input_file,NUM_TOTAL_SAMPLES);
  // char const* narma10_output_file = "./data/FixedPoint_output_data.txt";
  // FixedPoint* y = read_FixedPoint_vector_from_file(narma10_output_file,NUM_TOTAL_SAMPLES);


  // get test data vectors
  printf("Parsing test input and output vectors...\n");
  FixedPoint* u_test = get_vector_indexes(u,NUM_INIT_SAMPLES,NUM_TOTAL_SAMPLES);
  FixedPoint* y_test = get_vector_indexes(y,NUM_INIT_SAMPLES,NUM_TOTAL_SAMPLES);

  // store test data outputs
  FixedPoint y_hat_test[NUM_TEST_SAMPLES];

  // reservoir initialization
  printf("Initializing Reservoir...\n");
  for(unsigned int i = 0; i < NUM_INIT_SAMPLES; i++) ihc_hls_enqueue_noret(&dfr,u[i]);
  ihc_hls_component_run_all(dfr);

  // reservoir test
  printf("Testing DFR...\n");
  for(unsigned int i = 0; i < NUM_TEST_SAMPLES; i++) ihc_hls_enqueue(&y_hat_test[i], &dfr,u_test[i]);
  ihc_hls_component_run_all(dfr);

  // calculate the NRMSE of the predicted output
  FixedPoint nrmse = get_nrmse(y_hat_test,y_test,NUM_TEST_SAMPLES);
  printf("Test NRMSE\t= %s\n",nrmse.get_str().c_str());

  // calculate the MSE of the predicted output
  FixedPoint mse = get_mse(y_hat_test,y,NUM_TEST_SAMPLES);
  printf("Test MSE\t= %s\n",mse.get_str().c_str());

  return 0;

}
