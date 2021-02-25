# usage: vivado -mode tcl -source createBridgeProject.tcl

# rm *.jou
# rm *.log
# rm .Xil

set_param general.maxThreads 8

create_project mac_project ./mac_project -part xc7z020clg484-1 -force

set_property board_part em.avnet.com:zed:part0:1.4 [current_project]

add_files {
    ../rtl/tb/mac_tb.sv
    ../rtl/src/mac.sv 
    }


move_files -fileset sim_1 [get_files  ../rtl/tb/mac_tb.sv]

set_property top mac_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

launch_simulation
