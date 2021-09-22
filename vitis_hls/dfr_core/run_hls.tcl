#
# Copyright 2021 Xilinx, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Create a project
open_project -reset proj_dfr_core

# Add design files
add_files dfr_core.cpp
add_files mackey_glass.cpp
# Add test bench & files
add_files -tb dfr_core_test.cpp

# Set the top-level function
set_top dfr_core

# ########################################################
# Create a solution
open_solution -reset dfr_core_solution
# Define technology and clock rate
set_part  {xc7z020clg484-1}
create_clock -period "10MHz"

config_interface -default_slave_interface s_axilite
# config_interface -m_axi_max_widen_bitwidth 512
# config_interface -m_axi_alignment_byte_size=64

# Source x_hls.tcl to determine which steps to execute
source x_hls.tcl
csim_design
# Set any optimization directives
# End of directives

if {$hls_exec == 1} {
	# Run Synthesis and Exit
	csynth_design
	
} elseif {$hls_exec == 2} {
	# Run Synthesis, RTL Simulation and Exit
	csynth_design
	
	cosim_design
} elseif {$hls_exec == 3} { 
	# Run Synthesis, RTL Simulation, RTL implementation and Exit
	csynth_design
	
	cosim_design -tool xsim -rtl verilog
	
	# Generate pcore
	export_design -format ip_catalog
} else {
	# Default is to exit after setup
	csynth_design
}

exit


