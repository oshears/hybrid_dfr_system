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
    ../rtl/src/mackey_glass_block.sv 
    ../rtl/src/axi_cfg_regs.sv 
    ../rtl/src/dfr_core_top.sv 
    ../rtl/tb/dfr_core_top_tb.sv
    }


move_files -fileset sim_1 [get_files  ../rtl/tb/dfr_core_top_tb.sv]

set_property top dfr_core_top_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

launch_simulation

add_wave {{/dfr_core_top_tb/uut}} 
# add_wave {{/reservoir_tb/uut/\virtual_node_inst[0].reservoir_node /dout}}
# add_wave {{/reservoir_tb/uut/\virtual_node_inst[1].reservoir_node /dout}}
# add_wave {{/reservoir_tb/uut/\virtual_node_inst[2].reservoir_node /dout}}
# add_wave {{/reservoir_tb/uut/\virtual_node_inst[3].reservoir_node /dout}}
# add_wave {{/reservoir_tb/uut/\virtual_node_inst[4].reservoir_node /dout}}
# add_wave {{/reservoir_tb/uut/\virtual_node_inst[5].reservoir_node /dout}}
# add_wave {{/reservoir_tb/uut/\virtual_node_inst[6].reservoir_node /dout}}
# add_wave {{/reservoir_tb/uut/\virtual_node_inst[7].reservoir_node /dout}}
# add_wave {{/reservoir_tb/uut/\virtual_node_inst[8].reservoir_node /dout}}
# add_wave {{/reservoir_tb/uut/\virtual_node_inst[9].reservoir_node /dout}}
# open_wave_config reservoir_tb_behav.wcfg