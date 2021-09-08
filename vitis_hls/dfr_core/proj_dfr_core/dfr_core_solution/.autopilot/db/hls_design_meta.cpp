#include "hls_design_meta.h"
const Port_Property HLS_Design_Meta::port_props[]={
	Port_Property("ap_clk", 1, hls_in, -1, "", "", 1),
	Port_Property("ap_rst_n", 1, hls_in, -1, "", "", 1),
	Port_Property("m_axi_inputs_AWVALID", 1, hls_out, 0, "m_axi", "VALID", 1),
	Port_Property("m_axi_inputs_AWREADY", 1, hls_in, 0, "m_axi", "READY", 1),
	Port_Property("m_axi_inputs_AWADDR", 64, hls_out, 0, "m_axi", "ADDR", 1),
	Port_Property("m_axi_inputs_AWID", 1, hls_out, 0, "m_axi", "ID", 1),
	Port_Property("m_axi_inputs_AWLEN", 8, hls_out, 0, "m_axi", "LEN", 1),
	Port_Property("m_axi_inputs_AWSIZE", 3, hls_out, 0, "m_axi", "SIZE", 1),
	Port_Property("m_axi_inputs_AWBURST", 2, hls_out, 0, "m_axi", "BURST", 1),
	Port_Property("m_axi_inputs_AWLOCK", 2, hls_out, 0, "m_axi", "LOCK", 1),
	Port_Property("m_axi_inputs_AWCACHE", 4, hls_out, 0, "m_axi", "CACHE", 1),
	Port_Property("m_axi_inputs_AWPROT", 3, hls_out, 0, "m_axi", "PROT", 1),
	Port_Property("m_axi_inputs_AWQOS", 4, hls_out, 0, "m_axi", "QOS", 1),
	Port_Property("m_axi_inputs_AWREGION", 4, hls_out, 0, "m_axi", "REGION", 1),
	Port_Property("m_axi_inputs_AWUSER", 1, hls_out, 0, "m_axi", "USER", 1),
	Port_Property("m_axi_inputs_WVALID", 1, hls_out, 0, "m_axi", "VALID", 1),
	Port_Property("m_axi_inputs_WREADY", 1, hls_in, 0, "m_axi", "READY", 1),
	Port_Property("m_axi_inputs_WDATA", 32, hls_out, 0, "m_axi", "DATA", 1),
	Port_Property("m_axi_inputs_WSTRB", 4, hls_out, 0, "m_axi", "STRB", 1),
	Port_Property("m_axi_inputs_WLAST", 1, hls_out, 0, "m_axi", "LAST", 1),
	Port_Property("m_axi_inputs_WID", 1, hls_out, 0, "m_axi", "ID", 1),
	Port_Property("m_axi_inputs_WUSER", 1, hls_out, 0, "m_axi", "USER", 1),
	Port_Property("m_axi_inputs_ARVALID", 1, hls_out, 0, "m_axi", "VALID", 1),
	Port_Property("m_axi_inputs_ARREADY", 1, hls_in, 0, "m_axi", "READY", 1),
	Port_Property("m_axi_inputs_ARADDR", 64, hls_out, 0, "m_axi", "ADDR", 1),
	Port_Property("m_axi_inputs_ARID", 1, hls_out, 0, "m_axi", "ID", 1),
	Port_Property("m_axi_inputs_ARLEN", 8, hls_out, 0, "m_axi", "LEN", 1),
	Port_Property("m_axi_inputs_ARSIZE", 3, hls_out, 0, "m_axi", "SIZE", 1),
	Port_Property("m_axi_inputs_ARBURST", 2, hls_out, 0, "m_axi", "BURST", 1),
	Port_Property("m_axi_inputs_ARLOCK", 2, hls_out, 0, "m_axi", "LOCK", 1),
	Port_Property("m_axi_inputs_ARCACHE", 4, hls_out, 0, "m_axi", "CACHE", 1),
	Port_Property("m_axi_inputs_ARPROT", 3, hls_out, 0, "m_axi", "PROT", 1),
	Port_Property("m_axi_inputs_ARQOS", 4, hls_out, 0, "m_axi", "QOS", 1),
	Port_Property("m_axi_inputs_ARREGION", 4, hls_out, 0, "m_axi", "REGION", 1),
	Port_Property("m_axi_inputs_ARUSER", 1, hls_out, 0, "m_axi", "USER", 1),
	Port_Property("m_axi_inputs_RVALID", 1, hls_in, 0, "m_axi", "VALID", 1),
	Port_Property("m_axi_inputs_RREADY", 1, hls_out, 0, "m_axi", "READY", 1),
	Port_Property("m_axi_inputs_RDATA", 32, hls_in, 0, "m_axi", "DATA", 1),
	Port_Property("m_axi_inputs_RLAST", 1, hls_in, 0, "m_axi", "LAST", 1),
	Port_Property("m_axi_inputs_RID", 1, hls_in, 0, "m_axi", "ID", 1),
	Port_Property("m_axi_inputs_RUSER", 1, hls_in, 0, "m_axi", "USER", 1),
	Port_Property("m_axi_inputs_RRESP", 2, hls_in, 0, "m_axi", "RESP", 1),
	Port_Property("m_axi_inputs_BVALID", 1, hls_in, 0, "m_axi", "VALID", 1),
	Port_Property("m_axi_inputs_BREADY", 1, hls_out, 0, "m_axi", "READY", 1),
	Port_Property("m_axi_inputs_BRESP", 2, hls_in, 0, "m_axi", "RESP", 1),
	Port_Property("m_axi_inputs_BID", 1, hls_in, 0, "m_axi", "ID", 1),
	Port_Property("m_axi_inputs_BUSER", 1, hls_in, 0, "m_axi", "USER", 1),
	Port_Property("m_axi_weights_AWVALID", 1, hls_out, 1, "m_axi", "VALID", 1),
	Port_Property("m_axi_weights_AWREADY", 1, hls_in, 1, "m_axi", "READY", 1),
	Port_Property("m_axi_weights_AWADDR", 64, hls_out, 1, "m_axi", "ADDR", 1),
	Port_Property("m_axi_weights_AWID", 1, hls_out, 1, "m_axi", "ID", 1),
	Port_Property("m_axi_weights_AWLEN", 8, hls_out, 1, "m_axi", "LEN", 1),
	Port_Property("m_axi_weights_AWSIZE", 3, hls_out, 1, "m_axi", "SIZE", 1),
	Port_Property("m_axi_weights_AWBURST", 2, hls_out, 1, "m_axi", "BURST", 1),
	Port_Property("m_axi_weights_AWLOCK", 2, hls_out, 1, "m_axi", "LOCK", 1),
	Port_Property("m_axi_weights_AWCACHE", 4, hls_out, 1, "m_axi", "CACHE", 1),
	Port_Property("m_axi_weights_AWPROT", 3, hls_out, 1, "m_axi", "PROT", 1),
	Port_Property("m_axi_weights_AWQOS", 4, hls_out, 1, "m_axi", "QOS", 1),
	Port_Property("m_axi_weights_AWREGION", 4, hls_out, 1, "m_axi", "REGION", 1),
	Port_Property("m_axi_weights_AWUSER", 1, hls_out, 1, "m_axi", "USER", 1),
	Port_Property("m_axi_weights_WVALID", 1, hls_out, 1, "m_axi", "VALID", 1),
	Port_Property("m_axi_weights_WREADY", 1, hls_in, 1, "m_axi", "READY", 1),
	Port_Property("m_axi_weights_WDATA", 32, hls_out, 1, "m_axi", "DATA", 1),
	Port_Property("m_axi_weights_WSTRB", 4, hls_out, 1, "m_axi", "STRB", 1),
	Port_Property("m_axi_weights_WLAST", 1, hls_out, 1, "m_axi", "LAST", 1),
	Port_Property("m_axi_weights_WID", 1, hls_out, 1, "m_axi", "ID", 1),
	Port_Property("m_axi_weights_WUSER", 1, hls_out, 1, "m_axi", "USER", 1),
	Port_Property("m_axi_weights_ARVALID", 1, hls_out, 1, "m_axi", "VALID", 1),
	Port_Property("m_axi_weights_ARREADY", 1, hls_in, 1, "m_axi", "READY", 1),
	Port_Property("m_axi_weights_ARADDR", 64, hls_out, 1, "m_axi", "ADDR", 1),
	Port_Property("m_axi_weights_ARID", 1, hls_out, 1, "m_axi", "ID", 1),
	Port_Property("m_axi_weights_ARLEN", 8, hls_out, 1, "m_axi", "LEN", 1),
	Port_Property("m_axi_weights_ARSIZE", 3, hls_out, 1, "m_axi", "SIZE", 1),
	Port_Property("m_axi_weights_ARBURST", 2, hls_out, 1, "m_axi", "BURST", 1),
	Port_Property("m_axi_weights_ARLOCK", 2, hls_out, 1, "m_axi", "LOCK", 1),
	Port_Property("m_axi_weights_ARCACHE", 4, hls_out, 1, "m_axi", "CACHE", 1),
	Port_Property("m_axi_weights_ARPROT", 3, hls_out, 1, "m_axi", "PROT", 1),
	Port_Property("m_axi_weights_ARQOS", 4, hls_out, 1, "m_axi", "QOS", 1),
	Port_Property("m_axi_weights_ARREGION", 4, hls_out, 1, "m_axi", "REGION", 1),
	Port_Property("m_axi_weights_ARUSER", 1, hls_out, 1, "m_axi", "USER", 1),
	Port_Property("m_axi_weights_RVALID", 1, hls_in, 1, "m_axi", "VALID", 1),
	Port_Property("m_axi_weights_RREADY", 1, hls_out, 1, "m_axi", "READY", 1),
	Port_Property("m_axi_weights_RDATA", 32, hls_in, 1, "m_axi", "DATA", 1),
	Port_Property("m_axi_weights_RLAST", 1, hls_in, 1, "m_axi", "LAST", 1),
	Port_Property("m_axi_weights_RID", 1, hls_in, 1, "m_axi", "ID", 1),
	Port_Property("m_axi_weights_RUSER", 1, hls_in, 1, "m_axi", "USER", 1),
	Port_Property("m_axi_weights_RRESP", 2, hls_in, 1, "m_axi", "RESP", 1),
	Port_Property("m_axi_weights_BVALID", 1, hls_in, 1, "m_axi", "VALID", 1),
	Port_Property("m_axi_weights_BREADY", 1, hls_out, 1, "m_axi", "READY", 1),
	Port_Property("m_axi_weights_BRESP", 2, hls_in, 1, "m_axi", "RESP", 1),
	Port_Property("m_axi_weights_BID", 1, hls_in, 1, "m_axi", "ID", 1),
	Port_Property("m_axi_weights_BUSER", 1, hls_in, 1, "m_axi", "USER", 1),
	Port_Property("m_axi_outputs_AWVALID", 1, hls_out, 2, "m_axi", "VALID", 1),
	Port_Property("m_axi_outputs_AWREADY", 1, hls_in, 2, "m_axi", "READY", 1),
	Port_Property("m_axi_outputs_AWADDR", 64, hls_out, 2, "m_axi", "ADDR", 1),
	Port_Property("m_axi_outputs_AWID", 1, hls_out, 2, "m_axi", "ID", 1),
	Port_Property("m_axi_outputs_AWLEN", 8, hls_out, 2, "m_axi", "LEN", 1),
	Port_Property("m_axi_outputs_AWSIZE", 3, hls_out, 2, "m_axi", "SIZE", 1),
	Port_Property("m_axi_outputs_AWBURST", 2, hls_out, 2, "m_axi", "BURST", 1),
	Port_Property("m_axi_outputs_AWLOCK", 2, hls_out, 2, "m_axi", "LOCK", 1),
	Port_Property("m_axi_outputs_AWCACHE", 4, hls_out, 2, "m_axi", "CACHE", 1),
	Port_Property("m_axi_outputs_AWPROT", 3, hls_out, 2, "m_axi", "PROT", 1),
	Port_Property("m_axi_outputs_AWQOS", 4, hls_out, 2, "m_axi", "QOS", 1),
	Port_Property("m_axi_outputs_AWREGION", 4, hls_out, 2, "m_axi", "REGION", 1),
	Port_Property("m_axi_outputs_AWUSER", 1, hls_out, 2, "m_axi", "USER", 1),
	Port_Property("m_axi_outputs_WVALID", 1, hls_out, 2, "m_axi", "VALID", 1),
	Port_Property("m_axi_outputs_WREADY", 1, hls_in, 2, "m_axi", "READY", 1),
	Port_Property("m_axi_outputs_WDATA", 64, hls_out, 2, "m_axi", "DATA", 1),
	Port_Property("m_axi_outputs_WSTRB", 8, hls_out, 2, "m_axi", "STRB", 1),
	Port_Property("m_axi_outputs_WLAST", 1, hls_out, 2, "m_axi", "LAST", 1),
	Port_Property("m_axi_outputs_WID", 1, hls_out, 2, "m_axi", "ID", 1),
	Port_Property("m_axi_outputs_WUSER", 1, hls_out, 2, "m_axi", "USER", 1),
	Port_Property("m_axi_outputs_ARVALID", 1, hls_out, 2, "m_axi", "VALID", 1),
	Port_Property("m_axi_outputs_ARREADY", 1, hls_in, 2, "m_axi", "READY", 1),
	Port_Property("m_axi_outputs_ARADDR", 64, hls_out, 2, "m_axi", "ADDR", 1),
	Port_Property("m_axi_outputs_ARID", 1, hls_out, 2, "m_axi", "ID", 1),
	Port_Property("m_axi_outputs_ARLEN", 8, hls_out, 2, "m_axi", "LEN", 1),
	Port_Property("m_axi_outputs_ARSIZE", 3, hls_out, 2, "m_axi", "SIZE", 1),
	Port_Property("m_axi_outputs_ARBURST", 2, hls_out, 2, "m_axi", "BURST", 1),
	Port_Property("m_axi_outputs_ARLOCK", 2, hls_out, 2, "m_axi", "LOCK", 1),
	Port_Property("m_axi_outputs_ARCACHE", 4, hls_out, 2, "m_axi", "CACHE", 1),
	Port_Property("m_axi_outputs_ARPROT", 3, hls_out, 2, "m_axi", "PROT", 1),
	Port_Property("m_axi_outputs_ARQOS", 4, hls_out, 2, "m_axi", "QOS", 1),
	Port_Property("m_axi_outputs_ARREGION", 4, hls_out, 2, "m_axi", "REGION", 1),
	Port_Property("m_axi_outputs_ARUSER", 1, hls_out, 2, "m_axi", "USER", 1),
	Port_Property("m_axi_outputs_RVALID", 1, hls_in, 2, "m_axi", "VALID", 1),
	Port_Property("m_axi_outputs_RREADY", 1, hls_out, 2, "m_axi", "READY", 1),
	Port_Property("m_axi_outputs_RDATA", 64, hls_in, 2, "m_axi", "DATA", 1),
	Port_Property("m_axi_outputs_RLAST", 1, hls_in, 2, "m_axi", "LAST", 1),
	Port_Property("m_axi_outputs_RID", 1, hls_in, 2, "m_axi", "ID", 1),
	Port_Property("m_axi_outputs_RUSER", 1, hls_in, 2, "m_axi", "USER", 1),
	Port_Property("m_axi_outputs_RRESP", 2, hls_in, 2, "m_axi", "RESP", 1),
	Port_Property("m_axi_outputs_BVALID", 1, hls_in, 2, "m_axi", "VALID", 1),
	Port_Property("m_axi_outputs_BREADY", 1, hls_out, 2, "m_axi", "READY", 1),
	Port_Property("m_axi_outputs_BRESP", 2, hls_in, 2, "m_axi", "RESP", 1),
	Port_Property("m_axi_outputs_BID", 1, hls_in, 2, "m_axi", "ID", 1),
	Port_Property("m_axi_outputs_BUSER", 1, hls_in, 2, "m_axi", "USER", 1),
	Port_Property("s_axi_control_AWVALID", 1, hls_in, -1, "", "", 1),
	Port_Property("s_axi_control_AWREADY", 1, hls_out, -1, "", "", 1),
	Port_Property("s_axi_control_AWADDR", 4, hls_in, -1, "", "", 1),
	Port_Property("s_axi_control_WVALID", 1, hls_in, -1, "", "", 1),
	Port_Property("s_axi_control_WREADY", 1, hls_out, -1, "", "", 1),
	Port_Property("s_axi_control_WDATA", 32, hls_in, -1, "", "", 1),
	Port_Property("s_axi_control_WSTRB", 4, hls_in, -1, "", "", 1),
	Port_Property("s_axi_control_ARVALID", 1, hls_in, -1, "", "", 1),
	Port_Property("s_axi_control_ARREADY", 1, hls_out, -1, "", "", 1),
	Port_Property("s_axi_control_ARADDR", 4, hls_in, -1, "", "", 1),
	Port_Property("s_axi_control_RVALID", 1, hls_out, -1, "", "", 1),
	Port_Property("s_axi_control_RREADY", 1, hls_in, -1, "", "", 1),
	Port_Property("s_axi_control_RDATA", 32, hls_out, -1, "", "", 1),
	Port_Property("s_axi_control_RRESP", 2, hls_out, -1, "", "", 1),
	Port_Property("s_axi_control_BVALID", 1, hls_out, -1, "", "", 1),
	Port_Property("s_axi_control_BREADY", 1, hls_in, -1, "", "", 1),
	Port_Property("s_axi_control_BRESP", 2, hls_out, -1, "", "", 1),
	Port_Property("interrupt", 1, hls_out, -1, "", "", 1),
};
const char* HLS_Design_Meta::dut_name = "dfr_inference";
