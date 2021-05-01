# xsct createDFRCoreSystemPlatform.tcl
# start a minicom terminal on the uart port using: sudo minicom -D /dev/ttyACM0


# Remove previous files
exec rm -rf .metadata
exec rm -rf .Xil
exec rm -rf dfr_core_system_test_app 
exec rm -rf dfr_core_system_test_app_system
exec rm -rf dfr_core_system_platform
exec rm -rf .analytics 
exec rm -rf IDE.log 

# Set Workspace
setws .

# Create and Build Platform
platform create -name {dfr_core_system_platform}\
-hw {../vivado/dfr_core_system_project/dfr_core_system_wrapper.xsa}\
-proc {ps7_cortexa9_0} -os {standalone} -fsbl-target {psu_cortexa53_0} -out {.}

platform write
platform generate -domains 
platform active {dfr_core_system_platform}
platform generate

# Create and Build App
app create -name dfr_core_system_test_app -proc {ps7_cortexa9_0} -os {standalone} -template {Hello World}
# app create -name dfr_core_system_test_app -proc {ps7_cortexa9_0} -os {standalone}
importsources -name dfr_core_system_test_app -path ./src/
app build -name dfr_core_system_test_app

# Run on Hardware
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent Zed 210248A39829" && level==0 && jtag_device_ctx=="jsn-Zed-210248A39829-23727093-0"}
fpga -file ./dfr_core_system_test_app/_ide/bitstream/dfr_core_system_wrapper.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw ./dfr_core_system_platform/export/dfr_core_system_platform/hw/dfr_core_system_wrapper.xsa -mem-ranges [list {0x40000000 0xbfffffff}] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source ./dfr_core_system_test_app/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow ./dfr_core_system_test_app/Debug/dfr_core_system_test_app.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A9*#0"}
con


exit