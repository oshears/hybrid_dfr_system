# usage: vivado -mode tcl -source createBridgeProject.tcl

# rm *.jou
# rm *.log
# rm .Xil

set_param general.maxThreads 8

create_project dfr_core_project ./dfr_core_project -part xc7z020clg484-1 -force

set_property board_part em.avnet.com:zed:part0:1.4 [current_project]

add_files {
    ../rtl/src/register.sv 
    ../rtl/src/ram.sv 
    ../rtl/src/counter.sv 
    ../rtl/src/reservoir.sv 
    ../rtl/src/reservoir_asic.sv 
    ../rtl/src/mackey_glass_block_16bit.sv 
    ../rtl/src/mackey_glass_block_32bit.sv 
    ../rtl/src/axi_cfg_regs.sv 
    ../rtl/src/matrix_multiplier_v2.sv 
    ../rtl/src/pmod_dac_block.sv
    ../rtl/src/asic_function_interface.sv
    ../rtl/src/dfr_core_controller.sv 
    ../rtl/src/dfr_core_top.sv 
    ../rtl/src/dfr_core_hybrid_top.sv 
    ../rtl/src/asic_function_interface_top.sv
    ../rtl/src/asic_function_interface_top_axi_regs.sv
    ../rtl/tb/dfr_core_top_tb.sv
    ../rtl/tb/dfr_core_hybrid_top_tb.sv
    ../rtl/tb/dfr_core_top_narma10_tb.sv
    ../rtl/tb/dfr_core_hybrid_top_narma10_tb.sv
    ../rtl/tb/asic_function_interface_tb.sv
    ../rtl/tb/asic_function_interface_top_tb.sv
    }


move_files -fileset sim_1 [get_files  ../rtl/tb/dfr_core_top_tb.sv]
move_files -fileset sim_1 [get_files  ../rtl/tb/dfr_core_hybrid_top_tb.sv]
move_files -fileset sim_1 [get_files  ../rtl/tb/dfr_core_top_narma10_tb.sv]
move_files -fileset sim_1 [get_files  ../rtl/tb/asic_function_interface_tb.sv]
move_files -fileset sim_1 [get_files  ../rtl/tb/asic_function_interface_top_tb.sv]
move_files -fileset sim_1 [get_files  ../rtl/tb/dfr_core_hybrid_top_narma10_tb.sv]

add_files -fileset sim_1 -norecurse ../rtl/tb/xadc_inputs_asic_function.txt

# set_property top dfr_core_top_tb [get_filesets sim_1]
# set_property top dfr_core_hybrid_top_tb [get_filesets sim_1]
set_property top dfr_core_top_narma10_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# XADC IP
create_ip -name xadc_wiz -vendor xilinx.com -library ip -version 3.3 -module_name xadc_wiz_0
# set_property -dict [list CONFIG.DCLK_FREQUENCY {10} CONFIG.ADC_CONVERSION_RATE {193}] [get_ips xadc_wiz_0]
# set_property -dict [list CONFIG.ENABLE_CALIBRATION_AVERAGING {false} CONFIG.ADC_OFFSET_CALIBRATION {false} CONFIG.ADC_OFFSET_AND_GAIN_CALIBRATION {false} CONFIG.SENSOR_OFFSET_CALIBRATION {false} CONFIG.SENSOR_OFFSET_AND_GAIN_CALIBRATION {false}] [get_ips xadc_wiz_0]
set_property -dict [list CONFIG.SIM_FILE_NAME {xadc_inputs_asic_function} CONFIG.DCLK_FREQUENCY {10} CONFIG.ADC_CONVERSION_RATE {193} CONFIG.INTERFACE_SELECTION {ENABLE_DRP} CONFIG.TIMING_MODE {Event} CONFIG.OT_ALARM {false} CONFIG.USER_TEMP_ALARM {false} CONFIG.VCCINT_ALARM {false} CONFIG.VCCAUX_ALARM {false} CONFIG.ENABLE_VCCPINT_ALARM {false} CONFIG.ENABLE_VCCPAUX_ALARM {false} CONFIG.ENABLE_VCCDDRO_ALARM {false} CONFIG.SINGLE_CHANNEL_SELECTION {VP_VN} CONFIG.ADC_OFFSET_CALIBRATION {true} CONFIG.SENSOR_OFFSET_CALIBRATION {true}] [get_ips xadc_wiz_0]
generate_target all [get_files  /home/oshears/Documents/vt/research/code/verilog/neuromorphic_asic_bridge/vivado/neuromorphic_asic_bridge_project/neuromorphic_asic_bridge_project.srcs/sources_1/ip/xadc_wiz_0/xadc_wiz_0.xci]
catch { config_ip_cache -export [get_ips -all xadc_wiz_0] }
export_ip_user_files -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/neuromorphic_asic_bridge/vivado/neuromorphic_asic_bridge_project/neuromorphic_asic_bridge_project.srcs/sources_1/ip/xadc_wiz_0/xadc_wiz_0.xci] -no_script -sync -force -quiet
# reset_run xadc_wiz_0_synth_1
# launch_runs xadc_wiz_0_synth_1 -jobs 16
export_simulation -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/neuromorphic_asic_bridge/vivado/neuromorphic_asic_bridge_project/neuromorphic_asic_bridge_project.srcs/sources_1/ip/xadc_wiz_0/xadc_wiz_0.xci] -directory /home/oshears/Documents/vt/research/code/verilog/neuromorphic_asic_bridge/vivado/neuromorphic_asic_bridge_project/neuromorphic_asic_bridge_project.ip_user_files/sim_scripts -ip_user_files_dir /home/oshears/Documents/vt/research/code/verilog/neuromorphic_asic_bridge/vivado/neuromorphic_asic_bridge_project/neuromorphic_asic_bridge_project.ip_user_files -ipstatic_source_dir /home/oshears/Documents/vt/research/code/verilog/neuromorphic_asic_bridge/vivado/neuromorphic_asic_bridge_project/neuromorphic_asic_bridge_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=/home/oshears/Documents/vt/research/code/verilog/neuromorphic_asic_bridge/vivado/neuromorphic_asic_bridge_project/neuromorphic_asic_bridge_project.cache/compile_simlib/modelsim} {questa=/home/oshears/Documents/vt/research/code/verilog/neuromorphic_asic_bridge/vivado/neuromorphic_asic_bridge_project/neuromorphic_asic_bridge_project.cache/compile_simlib/questa} {ies=/home/oshears/Documents/vt/research/code/verilog/neuromorphic_asic_bridge/vivado/neuromorphic_asic_bridge_project/neuromorphic_asic_bridge_project.cache/compile_simlib/ies} {xcelium=/home/oshears/Documents/vt/research/code/verilog/neuromorphic_asic_bridge/vivado/neuromorphic_asic_bridge_project/neuromorphic_asic_bridge_project.cache/compile_simlib/xcelium} {vcs=/home/oshears/Documents/vt/research/code/verilog/neuromorphic_asic_bridge/vivado/neuromorphic_asic_bridge_project/neuromorphic_asic_bridge_project.cache/compile_simlib/vcs} {riviera=/home/oshears/Documents/vt/research/code/verilog/neuromorphic_asic_bridge/vivado/neuromorphic_asic_bridge_project/neuromorphic_asic_bridge_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
create_fileset -blockset xadc_wiz_0
set_property top xadc_wiz_0 [get_fileset xadc_wiz_0]
move_files -fileset [get_fileset xadc_wiz_0] [get_files -of_objects [get_fileset sources_1] /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/xadc_wiz_0/xadc_wiz_0.xci]
launch_run xadc_wiz_0_synth_1
wait_on_run xadc_wiz_0_synth_1

# BRAM 16k Dual Port IP
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_16k_dual_port
set_property -dict [list CONFIG.Component_Name {bram_16k_dual_port} CONFIG.Memory_Type {Simple_Dual_Port_RAM} CONFIG.Write_Width_A {32} CONFIG.Write_Depth_A {16384} CONFIG.Read_Width_A {32} CONFIG.Operating_Mode_A {NO_CHANGE} CONFIG.Enable_A {Always_Enabled} CONFIG.Write_Width_B {32} CONFIG.Read_Width_B {32} CONFIG.Enable_B {Always_Enabled} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Register_PortB_Output_of_Memory_Primitives {true} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Write_Rate {0} CONFIG.Port_B_Enable_Rate {100}] [get_ips bram_16k_dual_port]
set_property -dict [list CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Enable_B {Always_Enabled} CONFIG.Register_PortA_Output_of_Memory_Primitives {true} CONFIG.Port_B_Write_Rate {50}] [get_ips bram_16k_dual_port]
set_property -dict [list CONFIG.Assume_Synchronous_Clk {true}] [get_ips bram_16k_dual_port]
generate_target {instantiation_template} [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/bram_16k_dual_port/bram_16k_dual_port.xci]
update_compile_order -fileset sources_1
generate_target all [get_files  /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/bram_16k_dual_port/bram_16k_dual_port.xci]
catch { config_ip_cache -export [get_ips -all bram_16k_dual_port] }
export_ip_user_files -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/bram_16k_dual_port/bram_16k_dual_port.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/bram_16k_dual_port/bram_16k_dual_port.xci]
launch_runs bram_16k_dual_port_synth_1 -jobs 16
export_simulation -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/bram_16k_dual_port/bram_16k_dual_port.xci] -directory /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files/sim_scripts -ip_user_files_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files -ipstatic_source_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/modelsim} {questa=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/questa} {ies=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/ies} {xcelium=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/xcelium} {vcs=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/vcs} {riviera=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

# BRAM 128 Dual Port
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name bram_128_dual_port
set_property -dict [list CONFIG.Component_Name {bram_128_dual_port} CONFIG.Memory_Type {Simple_Dual_Port_RAM} CONFIG.Write_Width_A {32} CONFIG.Write_Depth_A {128} CONFIG.Read_Width_A {32} CONFIG.Operating_Mode_A {NO_CHANGE} CONFIG.Enable_A {Always_Enabled} CONFIG.Write_Width_B {32} CONFIG.Read_Width_B {32} CONFIG.Enable_B {Always_Enabled} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Register_PortB_Output_of_Memory_Primitives {true} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100}] [get_ips bram_128_dual_port]
set_property -dict [list CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Enable_B {Always_Enabled} CONFIG.Register_PortA_Output_of_Memory_Primitives {true} CONFIG.Port_B_Write_Rate {50}] [get_ips bram_128_dual_port]
set_property -dict [list CONFIG.Assume_Synchronous_Clk {true}] [get_ips bram_128_dual_port]
generate_target {instantiation_template} [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/bram_128_dual_port/bram_128_dual_port.xci]
generate_target all [get_files  /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/bram_128_dual_port/bram_128_dual_port.xci]
catch { config_ip_cache -export [get_ips -all bram_128_dual_port] }
export_ip_user_files -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/bram_128_dual_port/bram_128_dual_port.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/bram_128_dual_port/bram_128_dual_port.xci]
launch_runs bram_128_dual_port_synth_1 -jobs 16
export_simulation -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/bram_128_dual_port/bram_128_dual_port.xci] -directory /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files/sim_scripts -ip_user_files_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files -ipstatic_source_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/modelsim} {questa=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/questa} {ies=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/ies} {xcelium=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/xcelium} {vcs=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/vcs} {riviera=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

# AXI BRAM Controller 16k
# create_ip -name axi_bram_ctrl -vendor xilinx.com -library ip -version 4.1 -module_name axi_bram_ctrl_16k
# set_property -dict [list CONFIG.PROTOCOL {AXI4LITE} CONFIG.SUPPORTS_NARROW_BURST {0} CONFIG.SINGLE_PORT_BRAM {1} CONFIG.ECC_TYPE {0} CONFIG.Component_Name {axi_bram_ctrl_16k} CONFIG.BMG_INSTANCE {EXTERNAL} CONFIG.MEM_DEPTH {16384}] [get_ips axi_bram_ctrl_16k]
# generate_target {instantiation_template} [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/axi_bram_ctrl_16k/axi_bram_ctrl_16k.xci]
# generate_target all [get_files  /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/axi_bram_ctrl_16k/axi_bram_ctrl_16k.xci]
# catch { config_ip_cache -export [get_ips -all axi_bram_ctrl_16k] }
# export_ip_user_files -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/axi_bram_ctrl_16k/axi_bram_ctrl_16k.xci] -no_script -sync -force -quiet
# create_ip_run [get_files -of_objects [get_fileset sources_1] /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/axi_bram_ctrl_16k/axi_bram_ctrl_16k.xci]
# launch_runs axi_bram_ctrl_16k_synth_1 -jobs 16
# export_simulation -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/axi_bram_ctrl_16k/axi_bram_ctrl_16k.xci] -directory /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files/sim_scripts -ip_user_files_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files -ipstatic_source_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/modelsim} {questa=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/questa} {ies=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/ies} {xcelium=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/xcelium} {vcs=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/vcs} {riviera=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

# AXI BRAM Controller 1024
# create_ip -name axi_bram_ctrl -vendor xilinx.com -library ip -version 4.1 -module_name axi_bram_ctrl_1024
# set_property -dict [list CONFIG.PROTOCOL {AXI4LITE} CONFIG.SUPPORTS_NARROW_BURST {0} CONFIG.SINGLE_PORT_BRAM {1} CONFIG.ECC_TYPE {0} CONFIG.Component_Name {axi_bram_ctrl_1024} CONFIG.MEM_DEPTH {1024}] [get_ips axi_bram_ctrl_1024]
# generate_target {instantiation_template} [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/axi_bram_ctrl_1024/axi_bram_ctrl_1024.xci]
# update_compile_order -fileset sources_1
# generate_target all [get_files  /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/axi_bram_ctrl_1024/axi_bram_ctrl_1024.xci]
# catch { config_ip_cache -export [get_ips -all axi_bram_ctrl_1024] }
# export_ip_user_files -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/axi_bram_ctrl_1024/axi_bram_ctrl_1024.xci] -no_script -sync -force -quiet
# create_ip_run [get_files -of_objects [get_fileset sources_1] /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/axi_bram_ctrl_1024/axi_bram_ctrl_1024.xci]
# launch_runs axi_bram_ctrl_1024_synth_1 -jobs 16
# export_simulation -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/axi_bram_ctrl_1024/axi_bram_ctrl_1024.xci] -directory /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files/sim_scripts -ip_user_files_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files -ipstatic_source_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/modelsim} {questa=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/questa} {ies=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/ies} {xcelium=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/xcelium} {vcs=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/vcs} {riviera=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

# Multiplier IP
create_ip -name mult_gen -vendor xilinx.com -library ip -version 12.0 -module_name multiplier
set_property -dict [list CONFIG.Component_Name {multiplier} CONFIG.PortAWidth {32} CONFIG.PortBWidth {32} CONFIG.OutputWidthHigh {63}] [get_ips multiplier]
set_property -dict [list CONFIG.Multiplier_Construction {Use_Mults}] [get_ips multiplier]
generate_target {instantiation_template} [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/multiplier/multiplier.xci]
generate_target all [get_files  /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/multiplier/multiplier.xci]
catch { config_ip_cache -export [get_ips -all multiplier] }
export_ip_user_files -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/multiplier/multiplier.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/multiplier/multiplier.xci]
launch_runs multiplier_synth_1 -jobs 16
export_simulation -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/multiplier/multiplier.xci] -directory /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files/sim_scripts -ip_user_files_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files -ipstatic_source_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/modelsim} {questa=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/questa} {ies=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/ies} {xcelium=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/xcelium} {vcs=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/vcs} {riviera=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet


# ASIC Activation Function ROM
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name asic_activation_function_ram
set_property -dict [list CONFIG.Component_Name {asic_activation_function_ram} CONFIG.Write_Width_A {12} CONFIG.Write_Depth_A {65536} CONFIG.Read_Width_A {12} CONFIG.Enable_A {Always_Enabled} CONFIG.Write_Width_B {12} CONFIG.Read_Width_B {12} CONFIG.Load_Init_File {true} CONFIG.Coe_File {/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/rtl/src/asic_mackey_glass_mem.coe} CONFIG.Fill_Remaining_Memory_Locations {true}] [get_ips asic_activation_function_ram]
set_property -dict [list CONFIG.Memory_Type {Single_Port_ROM} CONFIG.Fill_Remaining_Memory_Locations {false} CONFIG.Port_A_Write_Rate {0}] [get_ips asic_activation_function_ram]
generate_target {instantiation_template} [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/asic_activation_function_ram/asic_activation_function_ram.xci]
generate_target all [get_files  /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/asic_activation_function_ram/asic_activation_function_ram.xci]
catch { config_ip_cache -export [get_ips -all asic_activation_function_ram] }
export_ip_user_files -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/asic_activation_function_ram/asic_activation_function_ram.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/asic_activation_function_ram/asic_activation_function_ram.xci]
launch_runs asic_activation_function_ram_synth_1 -jobs 16
export_simulation -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.srcs/sources_1/ip/asic_activation_function_ram/asic_activation_function_ram.xci] -directory /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files/sim_scripts -ip_user_files_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files -ipstatic_source_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/modelsim} {questa=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/questa} {ies=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/ies} {xcelium=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/xcelium} {vcs=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/vcs} {riviera=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/dfr_core_project/dfr_core_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet


update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

launch_simulation

# package ASIC Interface Top IP
set_property top asic_function_interface_top [get_filesets sources_1]
update_compile_order -fileset sources_1
ipx::package_project -root_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/ -vendor user.org -library user -taxonomy /UserIP -force
set_property taxonomy {/Embedded_Processing/AXI_Peripheral/Low_Speed_Peripheral /UserIP} [ipx::current_core]
set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property  ip_repo_paths  /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/ [current_project]
update_ip_catalog

# package FPGA DFR Core Top IP
# set_property top dfr_core_top [get_filesets sources_1]
# update_compile_order -fileset sources_1
# ipx::package_project -root_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/ -vendor user.org -library user -taxonomy /UserIP -force
# set_property taxonomy {/Embedded_Processing/AXI_Peripheral/Low_Speed_Peripheral /UserIP} [ipx::current_core]
# set_property core_revision 1 [ipx::current_core]
# ipx::create_xgui_files [ipx::current_core]
# ipx::update_checksums [ipx::current_core]
# ipx::check_integrity [ipx::current_core]
# ipx::save_core [ipx::current_core]
# set_property  ip_repo_paths  /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/ [current_project]
# update_ip_catalog

# package Hybrid DFR Core Top IP
# set_property top dfr_core_hybrid_top [get_filesets sources_1]
# update_compile_order -fileset sources_1
# ipx::package_project -root_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/ -vendor user.org -library user -taxonomy /UserIP -force
# set_property taxonomy {/Embedded_Processing/AXI_Peripheral/Low_Speed_Peripheral /UserIP} [ipx::current_core]
# set_property core_revision 1 [ipx::current_core]
# ipx::create_xgui_files [ipx::current_core]
# ipx::update_checksums [ipx::current_core]
# ipx::check_integrity [ipx::current_core]
# ipx::save_core [ipx::current_core]
# set_property  ip_repo_paths  /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/ [current_project]
# update_ip_catalog

exit