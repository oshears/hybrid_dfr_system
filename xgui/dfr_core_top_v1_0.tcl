# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_S_AXI_ACLK_FREQ_HZ" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RESERVOIR_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RESERVOIR_HISTORY_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "VIRTUAL_NODES" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_S_AXI_ACLK_FREQ_HZ { PARAM_VALUE.C_S_AXI_ACLK_FREQ_HZ } {
	# Procedure called to update C_S_AXI_ACLK_FREQ_HZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ACLK_FREQ_HZ { PARAM_VALUE.C_S_AXI_ACLK_FREQ_HZ } {
	# Procedure called to validate C_S_AXI_ACLK_FREQ_HZ
	return true
}

proc update_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_ADDR_WIDTH { PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to update C_S_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S_AXI_DATA_WIDTH { PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.RESERVOIR_DATA_WIDTH { PARAM_VALUE.RESERVOIR_DATA_WIDTH } {
	# Procedure called to update RESERVOIR_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RESERVOIR_DATA_WIDTH { PARAM_VALUE.RESERVOIR_DATA_WIDTH } {
	# Procedure called to validate RESERVOIR_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.RESERVOIR_HISTORY_ADDR_WIDTH { PARAM_VALUE.RESERVOIR_HISTORY_ADDR_WIDTH } {
	# Procedure called to update RESERVOIR_HISTORY_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RESERVOIR_HISTORY_ADDR_WIDTH { PARAM_VALUE.RESERVOIR_HISTORY_ADDR_WIDTH } {
	# Procedure called to validate RESERVOIR_HISTORY_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.VIRTUAL_NODES { PARAM_VALUE.VIRTUAL_NODES } {
	# Procedure called to update VIRTUAL_NODES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VIRTUAL_NODES { PARAM_VALUE.VIRTUAL_NODES } {
	# Procedure called to validate VIRTUAL_NODES
	return true
}


proc update_MODELPARAM_VALUE.C_S_AXI_ACLK_FREQ_HZ { MODELPARAM_VALUE.C_S_AXI_ACLK_FREQ_HZ PARAM_VALUE.C_S_AXI_ACLK_FREQ_HZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ACLK_FREQ_HZ}] ${MODELPARAM_VALUE.C_S_AXI_ACLK_FREQ_HZ}
}

proc update_MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH PARAM_VALUE.C_S_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH PARAM_VALUE.C_S_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.VIRTUAL_NODES { MODELPARAM_VALUE.VIRTUAL_NODES PARAM_VALUE.VIRTUAL_NODES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VIRTUAL_NODES}] ${MODELPARAM_VALUE.VIRTUAL_NODES}
}

proc update_MODELPARAM_VALUE.RESERVOIR_DATA_WIDTH { MODELPARAM_VALUE.RESERVOIR_DATA_WIDTH PARAM_VALUE.RESERVOIR_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RESERVOIR_DATA_WIDTH}] ${MODELPARAM_VALUE.RESERVOIR_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.RESERVOIR_HISTORY_ADDR_WIDTH { MODELPARAM_VALUE.RESERVOIR_HISTORY_ADDR_WIDTH PARAM_VALUE.RESERVOIR_HISTORY_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RESERVOIR_HISTORY_ADDR_WIDTH}] ${MODELPARAM_VALUE.RESERVOIR_HISTORY_ADDR_WIDTH}
}

