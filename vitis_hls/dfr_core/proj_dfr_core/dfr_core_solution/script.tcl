############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
############################################################
open_project proj_dfr_core
set_top dfr_inference
add_files mackey_glass.cpp
add_files dfr_core.cpp
add_files -tb dfr_core_test.cpp -cflags "-Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"
open_solution "dfr_core_solution" -flow_target vivado
set_part {xc7z020-clg484-1}
create_clock -period 10MHz -name default
config_interface -default_slave_interface s_axilite
source "./proj_dfr_core/dfr_core_solution/directives.tcl"
csim_design
csynth_design
cosim_design -wave_debug -trace_level all
export_design -format ip_catalog
