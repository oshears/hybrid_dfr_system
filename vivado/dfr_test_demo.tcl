reset_hw_axi [get_hw_axis]
create_hw_axi_txn txn_1 [get_hw_axis hw_axi_1] -address 00000000 -data {DEADBEE0} -len 1 -size 32 -type write
create_hw_axi_txn txn_2 [get_hw_axis hw_axi_1] -address 00000000 -len 1 -size 32 -type read
run_hw_axi txn_1 txn_2 -queue
#poke_hw_axi [get_hw_axi_txns txn1]
#peek_hw_axi [get_hw_axi_txns txn1]


# AXI LITE
reset_hw_axi [get_hw_axis]
create_hw_axi_txn txn_0 [get_hw_axis hw_axi_1] -address 00000000 -data 00000000 -type write
create_hw_axi_txn txn_1 [get_hw_axis hw_axi_1] -address 00000000 -data DEADBEE0 -type write
create_hw_axi_txn txn_2 [get_hw_axis hw_axi_1] -address 00000000 -type read
create_hw_axi_txn txn_3 [get_hw_axis hw_axi_1] -address 40000000 -data DEADBEEF -type write
create_hw_axi_txn txn_4 [get_hw_axis hw_axi_1] -address 40000000 -type read
create_hw_axi_txn txn_5 [get_hw_axis hw_axi_1] -address 01000000 -data DEADBEEF -type write
create_hw_axi_txn txn_6 [get_hw_axis hw_axi_1] -address 01000000 -type read
# create_hw_axi_txn txn_3 [get_hw_axis hw_axi_1] -address 00000004 -data ABCD0123 -type write
# create_hw_axi_txn txn_4 [get_hw_axis hw_axi_1] -address 00000004 -type read
run_hw_axi txn_1 
run_hw_axi txn_2
#poke_hw_axi [get_hw_axi_txns txn1]
#peek_hw_axi [get_hw_axi_txns txn1]

reset_hw_axi [get_hw_axis]
create_hw_axi_txn ctrl_reg_clr [get_hw_axis hw_axi_1] -address 00000000 -data 12340000 -type write -force
create_hw_axi_txn ctrl_reg_test [get_hw_axis hw_axi_1] -address 00000000 -data DEADBEE0 -type write -force
create_hw_axi_txn ctrl_reg_read [get_hw_axis hw_axi_1] -address 00000000 -type read -force
run_hw_axi ctrl_reg_clr
run_hw_axi ctrl_reg_read
run_hw_axi ctrl_reg_test
run_hw_axi ctrl_reg_read

reset_hw_axi [get_hw_axis]
create_hw_axi_txn ctrl_reg_clr [get_hw_axis hw_axi_1] -address 0x40000000 -data 12340000 -type write -force
create_hw_axi_txn ctrl_reg_test [get_hw_axis hw_axi_1] -address 0x40000000 -data DEADBEE0 -type write -force
create_hw_axi_txn ctrl_reg_read [get_hw_axis hw_axi_1] -address 0x40000000 -type read -force
run_hw_axi ctrl_reg_clr
run_hw_axi ctrl_reg_read
run_hw_axi ctrl_reg_test
run_hw_axi ctrl_reg_read
