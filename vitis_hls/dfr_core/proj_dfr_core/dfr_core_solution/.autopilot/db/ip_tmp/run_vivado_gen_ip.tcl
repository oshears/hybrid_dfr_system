create_project prj -part xc7z020-clg484-1 -force
set_property target_language verilog [current_project]
set vivado_ver [version -short]
set COE_DIR "../../syn/verilog"
source "/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vitis_hls/dfr_core/proj_dfr_core/dfr_core_solution/syn/verilog/dfr_inference_ap_dmul_0_max_dsp_64_ip.tcl"
source "/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vitis_hls/dfr_core/proj_dfr_core/dfr_core_solution/syn/verilog/dfr_inference_ap_sitodp_0_no_dsp_32_ip.tcl"
source "/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/vitis_hls/dfr_core/proj_dfr_core/dfr_core_solution/syn/verilog/dfr_inference_ap_dadd_0_full_dsp_64_ip.tcl"
