# usage: vivado -mode tcl -source createBridgeProject.tcl

# rm *.jou
# rm *.log
# rm .Xil

set_param general.maxThreads 8

create_project asic_function_project ./asic_function_project -part xc7z020clg484-1 -force

set_property board_part em.avnet.com:zed:part0:1.4 [current_project]

add_files {
    ../rtl/src/register.sv 
    ../rtl/src/counter.sv 
    ../rtl/src/pmod_dac_block.sv
    ../rtl/src/asic_function_interface.sv 
    ../rtl/src/asic_function_interface_top.sv
    ../rtl/src/asic_function_interface_top_axi_regs.sv
    ../rtl/tb/asic_function_interface_top_tb.sv
    }


move_files -fileset sim_1 [get_files  ../rtl/tb/asic_function_interface_top_tb.sv]

add_files -fileset sim_1 -norecurse ../rtl/tb/xadc_inputs_asic_function.txt

set_property top asic_function_interface_top_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# XADC IP
create_ip -name xadc_wiz -vendor xilinx.com -library ip -version 3.3 -module_name xadc_wiz_0
set_property -dict [list CONFIG.SIM_FILE_NAME {xadc_inputs_asic_function} CONFIG.DCLK_FREQUENCY {10} CONFIG.ADC_CONVERSION_RATE {193} CONFIG.INTERFACE_SELECTION {ENABLE_DRP} CONFIG.TIMING_MODE {Event} CONFIG.OT_ALARM {false} CONFIG.USER_TEMP_ALARM {false} CONFIG.VCCINT_ALARM {false} CONFIG.VCCAUX_ALARM {false} CONFIG.ENABLE_VCCPINT_ALARM {false} CONFIG.ENABLE_VCCPAUX_ALARM {false} CONFIG.ENABLE_VCCDDRO_ALARM {false} CONFIG.SINGLE_CHANNEL_SELECTION {VP_VN} CONFIG.ADC_OFFSET_CALIBRATION {true} CONFIG.SENSOR_OFFSET_CALIBRATION {true}] [get_ips xadc_wiz_0]
set_property -dict [list CONFIG.SINGLE_CHANNEL_SELECTION {VP_VN} CONFIG.CHANNEL_AVERAGING {256}] [get_ips xadc_wiz_0]
generate_target all [get_files  /home/oshears/Documents/vt/research/code/verilog/neuromorphic_asic_bridge/vivado/neuromorphic_asic_bridge_project/neuromorphic_asic_bridge_project.srcs/sources_1/ip/xadc_wiz_0/xadc_wiz_0.xci]
catch { config_ip_cache -export [get_ips -all xadc_wiz_0] }
export_ip_user_files -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/neuromorphic_asic_bridge/vivado/neuromorphic_asic_bridge_project/neuromorphic_asic_bridge_project.srcs/sources_1/ip/xadc_wiz_0/xadc_wiz_0.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/asic_function_project/asic_function_project.srcs/sources_1/ip/xadc_wiz_0/xadc_wiz_0.xci]
launch_runs xadc_wiz_0_synth_1 -jobs 16
export_simulation -of_objects [get_files /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/asic_function_project/asic_function_project.srcs/sources_1/ip/xadc_wiz_0/xadc_wiz_0.xci] -directory /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/asic_function_project/asic_function_project.ip_user_files/sim_scripts -ip_user_files_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/asic_function_project/asic_function_project.ip_user_files -ipstatic_source_dir /home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/asic_function_project/asic_function_project.ip_user_files/ipstatic -lib_map_path [list {modelsim=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/asic_function_project/asic_function_project.cache/compile_simlib/modelsim} {questa=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/asic_function_project/asic_function_project.cache/compile_simlib/questa} {ies=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/asic_function_project/asic_function_project.cache/compile_simlib/ies} {xcelium=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/asic_function_project/asic_function_project.cache/compile_simlib/xcelium} {vcs=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/asic_function_project/asic_function_project.cache/compile_simlib/vcs} {riviera=/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vivado/asic_function_project/asic_function_project.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet
wait_on_run xadc_wiz_0_synth_1

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

exit