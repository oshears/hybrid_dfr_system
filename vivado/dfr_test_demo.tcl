# DFR Task
create_hw_axi_txn num_init_sample_reg_write  [get_hw_axis hw_axi_1]  -address 00000008 -data 00000000 -type write -force
create_hw_axi_txn num_train_sample_reg_write  [get_hw_axis hw_axi_1]  -address 0000000C -data 00000000 -type write -force
create_hw_axi_txn num_test_sample_reg_write  [get_hw_axis hw_axi_1]  -address 00000010 -data 00000001 -type write -force
create_hw_axi_txn num_samples_per_reg_write  [get_hw_axis hw_axi_1]  -address 00000014 -data 00000064 -type write -force
create_hw_axi_txn num_init_steps_reg_write  [get_hw_axis hw_axi_1]  -address 00000018 -data 00000000 -type write -force
create_hw_axi_txn num_train_steps_reg_write  [get_hw_axis hw_axi_1]  -address 0000001C -data 00000000 -type write -force
create_hw_axi_txn num_test_steps_reg_write  [get_hw_axis hw_axi_1]  -address 00000020 -data 00000064 -type write -force
create_hw_axi_txn input_mem_write_0  [get_hw_axis hw_axi_1]  -address 01000000 -data 00000001 -type write -force
create_hw_axi_txn ctrl_reg_write  [get_hw_axis hw_axi_1]  -address 00000000 -data 00000001 -type write -force
create_hw_axi_txn reservoir_out_mem_read_0   [get_hw_axis hw_axi_1]  -address 02000000 -type read -force

reset_hw_axi [get_hw_axis]
run_hw_axi num_init_sample_reg_write
run_hw_axi num_train_sample_reg_write
run_hw_axi num_test_sample_reg_write
run_hw_axi num_samples_per_reg_write
run_hw_axi num_init_steps_reg_write
run_hw_axi num_train_steps_reg_write
run_hw_axi num_test_steps_reg_write
run_hw_axi input_mem_write_0
run_hw_axi ctrl_reg_write
run_hw_axi reservoir_out_mem_read_0

