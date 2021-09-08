// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================
 `timescale 1ns/1ps


`define AUTOTB_DUT      dfr_inference
`define AUTOTB_DUT_INST AESL_inst_dfr_inference
`define AUTOTB_TOP      apatb_dfr_inference_top
`define AUTOTB_LAT_RESULT_FILE "dfr_inference.result.lat.rb"
`define AUTOTB_PER_RESULT_TRANS_FILE "dfr_inference.performance.result.transaction.xml"
`define AUTOTB_TOP_INST AESL_inst_apatb_dfr_inference_top
`define AUTOTB_MAX_ALLOW_LATENCY  15000000
`define AUTOTB_CLOCK_PERIOD_DIV2 50.00

`define AESL_DEPTH_inputs 1
`define AESL_DEPTH_weights 1
`define AESL_DEPTH_outputs 1
`define AUTOTB_TVIN_inputs  "../tv/cdatafile/c.dfr_inference.autotvin_inputs.dat"
`define AUTOTB_TVIN_weights  "../tv/cdatafile/c.dfr_inference.autotvin_weights.dat"
`define AUTOTB_TVIN_inputs_out_wrapc  "../tv/rtldatafile/rtl.dfr_inference.autotvin_inputs.dat"
`define AUTOTB_TVIN_weights_out_wrapc  "../tv/rtldatafile/rtl.dfr_inference.autotvin_weights.dat"
`define AUTOTB_TVOUT_outputs  "../tv/cdatafile/c.dfr_inference.autotvout_outputs.dat"
`define AUTOTB_TVOUT_outputs_out_wrapc  "../tv/rtldatafile/rtl.dfr_inference.autotvout_outputs.dat"
module `AUTOTB_TOP;

parameter AUTOTB_TRANSACTION_NUM = 1;
parameter PROGRESS_TIMEOUT = 10000000;
parameter LATENCY_ESTIMATION = 120205228;
parameter LENGTH_inputs = 510200;
parameter LENGTH_weights = 100;
parameter LENGTH_outputs = 5082;

task read_token;
    input integer fp;
    output reg [199 : 0] token;
    integer ret;
    begin
        token = "";
        ret = 0;
        ret = $fscanf(fp,"%s",token);
    end
endtask

reg AESL_clock;
reg rst;
reg dut_rst;
reg start;
reg ce;
reg tb_continue;
wire AESL_start;
wire AESL_reset;
wire AESL_ce;
wire AESL_ready;
wire AESL_idle;
wire AESL_continue;
wire AESL_done;
reg AESL_done_delay = 0;
reg AESL_done_delay2 = 0;
reg AESL_ready_delay = 0;
wire ready;
wire ready_wire;
wire [3 : 0] control_AWADDR;
wire  control_AWVALID;
wire  control_AWREADY;
wire  control_WVALID;
wire  control_WREADY;
wire [31 : 0] control_WDATA;
wire [3 : 0] control_WSTRB;
wire [3 : 0] control_ARADDR;
wire  control_ARVALID;
wire  control_ARREADY;
wire  control_RVALID;
wire  control_RREADY;
wire [31 : 0] control_RDATA;
wire [1 : 0] control_RRESP;
wire  control_BVALID;
wire  control_BREADY;
wire [1 : 0] control_BRESP;
wire  control_INTERRUPT;
wire  inputs_AWVALID;
wire  inputs_AWREADY;
wire [63 : 0] inputs_AWADDR;
wire [0 : 0] inputs_AWID;
wire [7 : 0] inputs_AWLEN;
wire [2 : 0] inputs_AWSIZE;
wire [1 : 0] inputs_AWBURST;
wire [1 : 0] inputs_AWLOCK;
wire [3 : 0] inputs_AWCACHE;
wire [2 : 0] inputs_AWPROT;
wire [3 : 0] inputs_AWQOS;
wire [3 : 0] inputs_AWREGION;
wire [0 : 0] inputs_AWUSER;
wire  inputs_WVALID;
wire  inputs_WREADY;
wire [31 : 0] inputs_WDATA;
wire [3 : 0] inputs_WSTRB;
wire  inputs_WLAST;
wire [0 : 0] inputs_WID;
wire [0 : 0] inputs_WUSER;
wire  inputs_ARVALID;
wire  inputs_ARREADY;
wire [63 : 0] inputs_ARADDR;
wire [0 : 0] inputs_ARID;
wire [7 : 0] inputs_ARLEN;
wire [2 : 0] inputs_ARSIZE;
wire [1 : 0] inputs_ARBURST;
wire [1 : 0] inputs_ARLOCK;
wire [3 : 0] inputs_ARCACHE;
wire [2 : 0] inputs_ARPROT;
wire [3 : 0] inputs_ARQOS;
wire [3 : 0] inputs_ARREGION;
wire [0 : 0] inputs_ARUSER;
wire  inputs_RVALID;
wire  inputs_RREADY;
wire [31 : 0] inputs_RDATA;
wire  inputs_RLAST;
wire [0 : 0] inputs_RID;
wire [0 : 0] inputs_RUSER;
wire [1 : 0] inputs_RRESP;
wire  inputs_BVALID;
wire  inputs_BREADY;
wire [1 : 0] inputs_BRESP;
wire [0 : 0] inputs_BID;
wire [0 : 0] inputs_BUSER;
wire  weights_AWVALID;
wire  weights_AWREADY;
wire [63 : 0] weights_AWADDR;
wire [0 : 0] weights_AWID;
wire [7 : 0] weights_AWLEN;
wire [2 : 0] weights_AWSIZE;
wire [1 : 0] weights_AWBURST;
wire [1 : 0] weights_AWLOCK;
wire [3 : 0] weights_AWCACHE;
wire [2 : 0] weights_AWPROT;
wire [3 : 0] weights_AWQOS;
wire [3 : 0] weights_AWREGION;
wire [0 : 0] weights_AWUSER;
wire  weights_WVALID;
wire  weights_WREADY;
wire [31 : 0] weights_WDATA;
wire [3 : 0] weights_WSTRB;
wire  weights_WLAST;
wire [0 : 0] weights_WID;
wire [0 : 0] weights_WUSER;
wire  weights_ARVALID;
wire  weights_ARREADY;
wire [63 : 0] weights_ARADDR;
wire [0 : 0] weights_ARID;
wire [7 : 0] weights_ARLEN;
wire [2 : 0] weights_ARSIZE;
wire [1 : 0] weights_ARBURST;
wire [1 : 0] weights_ARLOCK;
wire [3 : 0] weights_ARCACHE;
wire [2 : 0] weights_ARPROT;
wire [3 : 0] weights_ARQOS;
wire [3 : 0] weights_ARREGION;
wire [0 : 0] weights_ARUSER;
wire  weights_RVALID;
wire  weights_RREADY;
wire [31 : 0] weights_RDATA;
wire  weights_RLAST;
wire [0 : 0] weights_RID;
wire [0 : 0] weights_RUSER;
wire [1 : 0] weights_RRESP;
wire  weights_BVALID;
wire  weights_BREADY;
wire [1 : 0] weights_BRESP;
wire [0 : 0] weights_BID;
wire [0 : 0] weights_BUSER;
wire  outputs_AWVALID;
wire  outputs_AWREADY;
wire [63 : 0] outputs_AWADDR;
wire [0 : 0] outputs_AWID;
wire [7 : 0] outputs_AWLEN;
wire [2 : 0] outputs_AWSIZE;
wire [1 : 0] outputs_AWBURST;
wire [1 : 0] outputs_AWLOCK;
wire [3 : 0] outputs_AWCACHE;
wire [2 : 0] outputs_AWPROT;
wire [3 : 0] outputs_AWQOS;
wire [3 : 0] outputs_AWREGION;
wire [0 : 0] outputs_AWUSER;
wire  outputs_WVALID;
wire  outputs_WREADY;
wire [63 : 0] outputs_WDATA;
wire [7 : 0] outputs_WSTRB;
wire  outputs_WLAST;
wire [0 : 0] outputs_WID;
wire [0 : 0] outputs_WUSER;
wire  outputs_ARVALID;
wire  outputs_ARREADY;
wire [63 : 0] outputs_ARADDR;
wire [0 : 0] outputs_ARID;
wire [7 : 0] outputs_ARLEN;
wire [2 : 0] outputs_ARSIZE;
wire [1 : 0] outputs_ARBURST;
wire [1 : 0] outputs_ARLOCK;
wire [3 : 0] outputs_ARCACHE;
wire [2 : 0] outputs_ARPROT;
wire [3 : 0] outputs_ARQOS;
wire [3 : 0] outputs_ARREGION;
wire [0 : 0] outputs_ARUSER;
wire  outputs_RVALID;
wire  outputs_RREADY;
wire [63 : 0] outputs_RDATA;
wire  outputs_RLAST;
wire [0 : 0] outputs_RID;
wire [0 : 0] outputs_RUSER;
wire [1 : 0] outputs_RRESP;
wire  outputs_BVALID;
wire  outputs_BREADY;
wire [1 : 0] outputs_BRESP;
wire [0 : 0] outputs_BID;
wire [0 : 0] outputs_BUSER;
integer done_cnt = 0;
integer AESL_ready_cnt = 0;
integer ready_cnt = 0;
reg ready_initial;
reg ready_initial_n;
reg ready_last_n;
reg ready_delay_last_n;
reg done_delay_last_n;
reg interface_done = 0;
wire AESL_slave_start;
reg AESL_slave_start_lock = 0;
wire AESL_slave_write_start_in;
wire AESL_slave_write_start_finish;
reg AESL_slave_ready;
wire AESL_slave_output_done;
wire AESL_slave_done;
reg ready_rise = 0;
reg start_rise = 0;
reg slave_start_status = 0;
reg slave_done_status = 0;
reg ap_done_lock = 0;

wire ap_clk;
wire ap_rst_n;
wire ap_rst_n_n;

`AUTOTB_DUT `AUTOTB_DUT_INST(
    .s_axi_control_AWADDR(control_AWADDR),
    .s_axi_control_AWVALID(control_AWVALID),
    .s_axi_control_AWREADY(control_AWREADY),
    .s_axi_control_WVALID(control_WVALID),
    .s_axi_control_WREADY(control_WREADY),
    .s_axi_control_WDATA(control_WDATA),
    .s_axi_control_WSTRB(control_WSTRB),
    .s_axi_control_ARADDR(control_ARADDR),
    .s_axi_control_ARVALID(control_ARVALID),
    .s_axi_control_ARREADY(control_ARREADY),
    .s_axi_control_RVALID(control_RVALID),
    .s_axi_control_RREADY(control_RREADY),
    .s_axi_control_RDATA(control_RDATA),
    .s_axi_control_RRESP(control_RRESP),
    .s_axi_control_BVALID(control_BVALID),
    .s_axi_control_BREADY(control_BREADY),
    .s_axi_control_BRESP(control_BRESP),
    .interrupt(control_INTERRUPT),
    .ap_clk(ap_clk),
    .ap_rst_n(ap_rst_n),
    .m_axi_inputs_AWVALID(inputs_AWVALID),
    .m_axi_inputs_AWREADY(inputs_AWREADY),
    .m_axi_inputs_AWADDR(inputs_AWADDR),
    .m_axi_inputs_AWID(inputs_AWID),
    .m_axi_inputs_AWLEN(inputs_AWLEN),
    .m_axi_inputs_AWSIZE(inputs_AWSIZE),
    .m_axi_inputs_AWBURST(inputs_AWBURST),
    .m_axi_inputs_AWLOCK(inputs_AWLOCK),
    .m_axi_inputs_AWCACHE(inputs_AWCACHE),
    .m_axi_inputs_AWPROT(inputs_AWPROT),
    .m_axi_inputs_AWQOS(inputs_AWQOS),
    .m_axi_inputs_AWREGION(inputs_AWREGION),
    .m_axi_inputs_AWUSER(inputs_AWUSER),
    .m_axi_inputs_WVALID(inputs_WVALID),
    .m_axi_inputs_WREADY(inputs_WREADY),
    .m_axi_inputs_WDATA(inputs_WDATA),
    .m_axi_inputs_WSTRB(inputs_WSTRB),
    .m_axi_inputs_WLAST(inputs_WLAST),
    .m_axi_inputs_WID(inputs_WID),
    .m_axi_inputs_WUSER(inputs_WUSER),
    .m_axi_inputs_ARVALID(inputs_ARVALID),
    .m_axi_inputs_ARREADY(inputs_ARREADY),
    .m_axi_inputs_ARADDR(inputs_ARADDR),
    .m_axi_inputs_ARID(inputs_ARID),
    .m_axi_inputs_ARLEN(inputs_ARLEN),
    .m_axi_inputs_ARSIZE(inputs_ARSIZE),
    .m_axi_inputs_ARBURST(inputs_ARBURST),
    .m_axi_inputs_ARLOCK(inputs_ARLOCK),
    .m_axi_inputs_ARCACHE(inputs_ARCACHE),
    .m_axi_inputs_ARPROT(inputs_ARPROT),
    .m_axi_inputs_ARQOS(inputs_ARQOS),
    .m_axi_inputs_ARREGION(inputs_ARREGION),
    .m_axi_inputs_ARUSER(inputs_ARUSER),
    .m_axi_inputs_RVALID(inputs_RVALID),
    .m_axi_inputs_RREADY(inputs_RREADY),
    .m_axi_inputs_RDATA(inputs_RDATA),
    .m_axi_inputs_RLAST(inputs_RLAST),
    .m_axi_inputs_RID(inputs_RID),
    .m_axi_inputs_RUSER(inputs_RUSER),
    .m_axi_inputs_RRESP(inputs_RRESP),
    .m_axi_inputs_BVALID(inputs_BVALID),
    .m_axi_inputs_BREADY(inputs_BREADY),
    .m_axi_inputs_BRESP(inputs_BRESP),
    .m_axi_inputs_BID(inputs_BID),
    .m_axi_inputs_BUSER(inputs_BUSER),
    .m_axi_weights_AWVALID(weights_AWVALID),
    .m_axi_weights_AWREADY(weights_AWREADY),
    .m_axi_weights_AWADDR(weights_AWADDR),
    .m_axi_weights_AWID(weights_AWID),
    .m_axi_weights_AWLEN(weights_AWLEN),
    .m_axi_weights_AWSIZE(weights_AWSIZE),
    .m_axi_weights_AWBURST(weights_AWBURST),
    .m_axi_weights_AWLOCK(weights_AWLOCK),
    .m_axi_weights_AWCACHE(weights_AWCACHE),
    .m_axi_weights_AWPROT(weights_AWPROT),
    .m_axi_weights_AWQOS(weights_AWQOS),
    .m_axi_weights_AWREGION(weights_AWREGION),
    .m_axi_weights_AWUSER(weights_AWUSER),
    .m_axi_weights_WVALID(weights_WVALID),
    .m_axi_weights_WREADY(weights_WREADY),
    .m_axi_weights_WDATA(weights_WDATA),
    .m_axi_weights_WSTRB(weights_WSTRB),
    .m_axi_weights_WLAST(weights_WLAST),
    .m_axi_weights_WID(weights_WID),
    .m_axi_weights_WUSER(weights_WUSER),
    .m_axi_weights_ARVALID(weights_ARVALID),
    .m_axi_weights_ARREADY(weights_ARREADY),
    .m_axi_weights_ARADDR(weights_ARADDR),
    .m_axi_weights_ARID(weights_ARID),
    .m_axi_weights_ARLEN(weights_ARLEN),
    .m_axi_weights_ARSIZE(weights_ARSIZE),
    .m_axi_weights_ARBURST(weights_ARBURST),
    .m_axi_weights_ARLOCK(weights_ARLOCK),
    .m_axi_weights_ARCACHE(weights_ARCACHE),
    .m_axi_weights_ARPROT(weights_ARPROT),
    .m_axi_weights_ARQOS(weights_ARQOS),
    .m_axi_weights_ARREGION(weights_ARREGION),
    .m_axi_weights_ARUSER(weights_ARUSER),
    .m_axi_weights_RVALID(weights_RVALID),
    .m_axi_weights_RREADY(weights_RREADY),
    .m_axi_weights_RDATA(weights_RDATA),
    .m_axi_weights_RLAST(weights_RLAST),
    .m_axi_weights_RID(weights_RID),
    .m_axi_weights_RUSER(weights_RUSER),
    .m_axi_weights_RRESP(weights_RRESP),
    .m_axi_weights_BVALID(weights_BVALID),
    .m_axi_weights_BREADY(weights_BREADY),
    .m_axi_weights_BRESP(weights_BRESP),
    .m_axi_weights_BID(weights_BID),
    .m_axi_weights_BUSER(weights_BUSER),
    .m_axi_outputs_AWVALID(outputs_AWVALID),
    .m_axi_outputs_AWREADY(outputs_AWREADY),
    .m_axi_outputs_AWADDR(outputs_AWADDR),
    .m_axi_outputs_AWID(outputs_AWID),
    .m_axi_outputs_AWLEN(outputs_AWLEN),
    .m_axi_outputs_AWSIZE(outputs_AWSIZE),
    .m_axi_outputs_AWBURST(outputs_AWBURST),
    .m_axi_outputs_AWLOCK(outputs_AWLOCK),
    .m_axi_outputs_AWCACHE(outputs_AWCACHE),
    .m_axi_outputs_AWPROT(outputs_AWPROT),
    .m_axi_outputs_AWQOS(outputs_AWQOS),
    .m_axi_outputs_AWREGION(outputs_AWREGION),
    .m_axi_outputs_AWUSER(outputs_AWUSER),
    .m_axi_outputs_WVALID(outputs_WVALID),
    .m_axi_outputs_WREADY(outputs_WREADY),
    .m_axi_outputs_WDATA(outputs_WDATA),
    .m_axi_outputs_WSTRB(outputs_WSTRB),
    .m_axi_outputs_WLAST(outputs_WLAST),
    .m_axi_outputs_WID(outputs_WID),
    .m_axi_outputs_WUSER(outputs_WUSER),
    .m_axi_outputs_ARVALID(outputs_ARVALID),
    .m_axi_outputs_ARREADY(outputs_ARREADY),
    .m_axi_outputs_ARADDR(outputs_ARADDR),
    .m_axi_outputs_ARID(outputs_ARID),
    .m_axi_outputs_ARLEN(outputs_ARLEN),
    .m_axi_outputs_ARSIZE(outputs_ARSIZE),
    .m_axi_outputs_ARBURST(outputs_ARBURST),
    .m_axi_outputs_ARLOCK(outputs_ARLOCK),
    .m_axi_outputs_ARCACHE(outputs_ARCACHE),
    .m_axi_outputs_ARPROT(outputs_ARPROT),
    .m_axi_outputs_ARQOS(outputs_ARQOS),
    .m_axi_outputs_ARREGION(outputs_ARREGION),
    .m_axi_outputs_ARUSER(outputs_ARUSER),
    .m_axi_outputs_RVALID(outputs_RVALID),
    .m_axi_outputs_RREADY(outputs_RREADY),
    .m_axi_outputs_RDATA(outputs_RDATA),
    .m_axi_outputs_RLAST(outputs_RLAST),
    .m_axi_outputs_RID(outputs_RID),
    .m_axi_outputs_RUSER(outputs_RUSER),
    .m_axi_outputs_RRESP(outputs_RRESP),
    .m_axi_outputs_BVALID(outputs_BVALID),
    .m_axi_outputs_BREADY(outputs_BREADY),
    .m_axi_outputs_BRESP(outputs_BRESP),
    .m_axi_outputs_BID(outputs_BID),
    .m_axi_outputs_BUSER(outputs_BUSER));

// Assignment for control signal
assign ap_clk = AESL_clock;
assign ap_rst_n = dut_rst;
assign ap_rst_n_n = ~dut_rst;
assign AESL_reset = rst;
assign AESL_start = start;
assign AESL_ce = ce;
assign AESL_continue = tb_continue;
  assign AESL_slave_write_start_in = slave_start_status ;
  assign AESL_slave_start = AESL_slave_write_start_finish;
  assign AESL_done = slave_done_status ;

always @(posedge AESL_clock)
begin
    if(AESL_reset === 0)
    begin
        slave_start_status <= 1;
    end
    else begin
        if (AESL_start == 1 ) begin
            start_rise = 1;
        end
        if (start_rise == 1 && AESL_done == 1 ) begin
            slave_start_status <= 1;
        end
        if (AESL_slave_write_start_in == 1 && AESL_done == 0) begin 
            slave_start_status <= 0;
            start_rise = 0;
        end
    end
end

always @(posedge AESL_clock)
begin
    if(AESL_reset === 0)
    begin
        AESL_slave_ready <= 0;
        ready_rise = 0;
    end
    else begin
        if (AESL_ready == 1 ) begin
            ready_rise = 1;
        end
        if (ready_rise == 1 && AESL_done_delay == 1 ) begin
            AESL_slave_ready <= 1;
        end
        if (AESL_slave_ready == 1) begin 
            AESL_slave_ready <= 0;
            ready_rise = 0;
        end
    end
end

always @ (posedge AESL_clock)
begin
    if (AESL_done == 1) begin
        slave_done_status <= 0;
    end
    else if (AESL_slave_output_done == 1 ) begin
        slave_done_status <= 1;
    end
end



wire    AESL_axi_master_inputs_ready;
wire    AESL_axi_master_inputs_done;
AESL_axi_master_inputs AESL_AXI_MASTER_inputs(
    .clk   (AESL_clock),
    .reset (AESL_reset),
    .TRAN_inputs_AWVALID (inputs_AWVALID),
    .TRAN_inputs_AWREADY (inputs_AWREADY),
    .TRAN_inputs_AWADDR (inputs_AWADDR),
    .TRAN_inputs_AWID (inputs_AWID),
    .TRAN_inputs_AWLEN (inputs_AWLEN),
    .TRAN_inputs_AWSIZE (inputs_AWSIZE),
    .TRAN_inputs_AWBURST (inputs_AWBURST),
    .TRAN_inputs_AWLOCK (inputs_AWLOCK),
    .TRAN_inputs_AWCACHE (inputs_AWCACHE),
    .TRAN_inputs_AWPROT (inputs_AWPROT),
    .TRAN_inputs_AWQOS (inputs_AWQOS),
    .TRAN_inputs_AWREGION (inputs_AWREGION),
    .TRAN_inputs_AWUSER (inputs_AWUSER),
    .TRAN_inputs_WVALID (inputs_WVALID),
    .TRAN_inputs_WREADY (inputs_WREADY),
    .TRAN_inputs_WDATA (inputs_WDATA),
    .TRAN_inputs_WSTRB (inputs_WSTRB),
    .TRAN_inputs_WLAST (inputs_WLAST),
    .TRAN_inputs_WID (inputs_WID),
    .TRAN_inputs_WUSER (inputs_WUSER),
    .TRAN_inputs_ARVALID (inputs_ARVALID),
    .TRAN_inputs_ARREADY (inputs_ARREADY),
    .TRAN_inputs_ARADDR (inputs_ARADDR),
    .TRAN_inputs_ARID (inputs_ARID),
    .TRAN_inputs_ARLEN (inputs_ARLEN),
    .TRAN_inputs_ARSIZE (inputs_ARSIZE),
    .TRAN_inputs_ARBURST (inputs_ARBURST),
    .TRAN_inputs_ARLOCK (inputs_ARLOCK),
    .TRAN_inputs_ARCACHE (inputs_ARCACHE),
    .TRAN_inputs_ARPROT (inputs_ARPROT),
    .TRAN_inputs_ARQOS (inputs_ARQOS),
    .TRAN_inputs_ARREGION (inputs_ARREGION),
    .TRAN_inputs_ARUSER (inputs_ARUSER),
    .TRAN_inputs_RVALID (inputs_RVALID),
    .TRAN_inputs_RREADY (inputs_RREADY),
    .TRAN_inputs_RDATA (inputs_RDATA),
    .TRAN_inputs_RLAST (inputs_RLAST),
    .TRAN_inputs_RID (inputs_RID),
    .TRAN_inputs_RUSER (inputs_RUSER),
    .TRAN_inputs_RRESP (inputs_RRESP),
    .TRAN_inputs_BVALID (inputs_BVALID),
    .TRAN_inputs_BREADY (inputs_BREADY),
    .TRAN_inputs_BRESP (inputs_BRESP),
    .TRAN_inputs_BID (inputs_BID),
    .TRAN_inputs_BUSER (inputs_BUSER),
    .ready (AESL_axi_master_inputs_ready),
    .done  (AESL_axi_master_inputs_done)
);
assign    AESL_axi_master_inputs_ready    =   ready;
assign    AESL_axi_master_inputs_done    =   AESL_done_delay;
wire    AESL_axi_master_weights_ready;
wire    AESL_axi_master_weights_done;
AESL_axi_master_weights AESL_AXI_MASTER_weights(
    .clk   (AESL_clock),
    .reset (AESL_reset),
    .TRAN_weights_AWVALID (weights_AWVALID),
    .TRAN_weights_AWREADY (weights_AWREADY),
    .TRAN_weights_AWADDR (weights_AWADDR),
    .TRAN_weights_AWID (weights_AWID),
    .TRAN_weights_AWLEN (weights_AWLEN),
    .TRAN_weights_AWSIZE (weights_AWSIZE),
    .TRAN_weights_AWBURST (weights_AWBURST),
    .TRAN_weights_AWLOCK (weights_AWLOCK),
    .TRAN_weights_AWCACHE (weights_AWCACHE),
    .TRAN_weights_AWPROT (weights_AWPROT),
    .TRAN_weights_AWQOS (weights_AWQOS),
    .TRAN_weights_AWREGION (weights_AWREGION),
    .TRAN_weights_AWUSER (weights_AWUSER),
    .TRAN_weights_WVALID (weights_WVALID),
    .TRAN_weights_WREADY (weights_WREADY),
    .TRAN_weights_WDATA (weights_WDATA),
    .TRAN_weights_WSTRB (weights_WSTRB),
    .TRAN_weights_WLAST (weights_WLAST),
    .TRAN_weights_WID (weights_WID),
    .TRAN_weights_WUSER (weights_WUSER),
    .TRAN_weights_ARVALID (weights_ARVALID),
    .TRAN_weights_ARREADY (weights_ARREADY),
    .TRAN_weights_ARADDR (weights_ARADDR),
    .TRAN_weights_ARID (weights_ARID),
    .TRAN_weights_ARLEN (weights_ARLEN),
    .TRAN_weights_ARSIZE (weights_ARSIZE),
    .TRAN_weights_ARBURST (weights_ARBURST),
    .TRAN_weights_ARLOCK (weights_ARLOCK),
    .TRAN_weights_ARCACHE (weights_ARCACHE),
    .TRAN_weights_ARPROT (weights_ARPROT),
    .TRAN_weights_ARQOS (weights_ARQOS),
    .TRAN_weights_ARREGION (weights_ARREGION),
    .TRAN_weights_ARUSER (weights_ARUSER),
    .TRAN_weights_RVALID (weights_RVALID),
    .TRAN_weights_RREADY (weights_RREADY),
    .TRAN_weights_RDATA (weights_RDATA),
    .TRAN_weights_RLAST (weights_RLAST),
    .TRAN_weights_RID (weights_RID),
    .TRAN_weights_RUSER (weights_RUSER),
    .TRAN_weights_RRESP (weights_RRESP),
    .TRAN_weights_BVALID (weights_BVALID),
    .TRAN_weights_BREADY (weights_BREADY),
    .TRAN_weights_BRESP (weights_BRESP),
    .TRAN_weights_BID (weights_BID),
    .TRAN_weights_BUSER (weights_BUSER),
    .ready (AESL_axi_master_weights_ready),
    .done  (AESL_axi_master_weights_done)
);
assign    AESL_axi_master_weights_ready    =   ready;
assign    AESL_axi_master_weights_done    =   AESL_done_delay;
wire    AESL_axi_master_outputs_ready;
wire    AESL_axi_master_outputs_done;
AESL_axi_master_outputs AESL_AXI_MASTER_outputs(
    .clk   (AESL_clock),
    .reset (AESL_reset),
    .TRAN_outputs_AWVALID (outputs_AWVALID),
    .TRAN_outputs_AWREADY (outputs_AWREADY),
    .TRAN_outputs_AWADDR (outputs_AWADDR),
    .TRAN_outputs_AWID (outputs_AWID),
    .TRAN_outputs_AWLEN (outputs_AWLEN),
    .TRAN_outputs_AWSIZE (outputs_AWSIZE),
    .TRAN_outputs_AWBURST (outputs_AWBURST),
    .TRAN_outputs_AWLOCK (outputs_AWLOCK),
    .TRAN_outputs_AWCACHE (outputs_AWCACHE),
    .TRAN_outputs_AWPROT (outputs_AWPROT),
    .TRAN_outputs_AWQOS (outputs_AWQOS),
    .TRAN_outputs_AWREGION (outputs_AWREGION),
    .TRAN_outputs_AWUSER (outputs_AWUSER),
    .TRAN_outputs_WVALID (outputs_WVALID),
    .TRAN_outputs_WREADY (outputs_WREADY),
    .TRAN_outputs_WDATA (outputs_WDATA),
    .TRAN_outputs_WSTRB (outputs_WSTRB),
    .TRAN_outputs_WLAST (outputs_WLAST),
    .TRAN_outputs_WID (outputs_WID),
    .TRAN_outputs_WUSER (outputs_WUSER),
    .TRAN_outputs_ARVALID (outputs_ARVALID),
    .TRAN_outputs_ARREADY (outputs_ARREADY),
    .TRAN_outputs_ARADDR (outputs_ARADDR),
    .TRAN_outputs_ARID (outputs_ARID),
    .TRAN_outputs_ARLEN (outputs_ARLEN),
    .TRAN_outputs_ARSIZE (outputs_ARSIZE),
    .TRAN_outputs_ARBURST (outputs_ARBURST),
    .TRAN_outputs_ARLOCK (outputs_ARLOCK),
    .TRAN_outputs_ARCACHE (outputs_ARCACHE),
    .TRAN_outputs_ARPROT (outputs_ARPROT),
    .TRAN_outputs_ARQOS (outputs_ARQOS),
    .TRAN_outputs_ARREGION (outputs_ARREGION),
    .TRAN_outputs_ARUSER (outputs_ARUSER),
    .TRAN_outputs_RVALID (outputs_RVALID),
    .TRAN_outputs_RREADY (outputs_RREADY),
    .TRAN_outputs_RDATA (outputs_RDATA),
    .TRAN_outputs_RLAST (outputs_RLAST),
    .TRAN_outputs_RID (outputs_RID),
    .TRAN_outputs_RUSER (outputs_RUSER),
    .TRAN_outputs_RRESP (outputs_RRESP),
    .TRAN_outputs_BVALID (outputs_BVALID),
    .TRAN_outputs_BREADY (outputs_BREADY),
    .TRAN_outputs_BRESP (outputs_BRESP),
    .TRAN_outputs_BID (outputs_BID),
    .TRAN_outputs_BUSER (outputs_BUSER),
    .ready (AESL_axi_master_outputs_ready),
    .done  (AESL_axi_master_outputs_done)
);
assign    AESL_axi_master_outputs_ready    =   ready;
assign    AESL_axi_master_outputs_done    =   AESL_done_delay;

AESL_axi_slave_control AESL_AXI_SLAVE_control(
    .clk   (AESL_clock),
    .reset (AESL_reset),
    .TRAN_s_axi_control_AWADDR (control_AWADDR),
    .TRAN_s_axi_control_AWVALID (control_AWVALID),
    .TRAN_s_axi_control_AWREADY (control_AWREADY),
    .TRAN_s_axi_control_WVALID (control_WVALID),
    .TRAN_s_axi_control_WREADY (control_WREADY),
    .TRAN_s_axi_control_WDATA (control_WDATA),
    .TRAN_s_axi_control_WSTRB (control_WSTRB),
    .TRAN_s_axi_control_ARADDR (control_ARADDR),
    .TRAN_s_axi_control_ARVALID (control_ARVALID),
    .TRAN_s_axi_control_ARREADY (control_ARREADY),
    .TRAN_s_axi_control_RVALID (control_RVALID),
    .TRAN_s_axi_control_RREADY (control_RREADY),
    .TRAN_s_axi_control_RDATA (control_RDATA),
    .TRAN_s_axi_control_RRESP (control_RRESP),
    .TRAN_s_axi_control_BVALID (control_BVALID),
    .TRAN_s_axi_control_BREADY (control_BREADY),
    .TRAN_s_axi_control_BRESP (control_BRESP),
    .TRAN_control_interrupt (control_INTERRUPT),
    .TRAN_control_ready_out (AESL_ready),
    .TRAN_control_ready_in (AESL_slave_ready),
    .TRAN_control_done_out (AESL_slave_output_done),
    .TRAN_control_idle_out (AESL_idle),
    .TRAN_control_write_start_in     (AESL_slave_write_start_in),
    .TRAN_control_write_start_finish (AESL_slave_write_start_finish),
    .TRAN_control_transaction_done_in (AESL_done_delay),
    .TRAN_control_start_in  (AESL_slave_start)
);

initial begin : generate_AESL_ready_cnt_proc
    AESL_ready_cnt = 0;
    wait(AESL_reset === 1);
    while(AESL_ready_cnt != AUTOTB_TRANSACTION_NUM) begin
        while(AESL_ready !== 1) begin
            @(posedge AESL_clock);
            # 0.4;
        end
        @(negedge AESL_clock);
        AESL_ready_cnt = AESL_ready_cnt + 1;
        @(posedge AESL_clock);
        # 0.4;
    end
end

    event next_trigger_ready_cnt;
    
    initial begin : gen_ready_cnt
        ready_cnt = 0;
        wait (AESL_reset === 1);
        forever begin
            @ (posedge AESL_clock);
            if (ready == 1) begin
                if (ready_cnt < AUTOTB_TRANSACTION_NUM) begin
                    ready_cnt = ready_cnt + 1;
                end
            end
            -> next_trigger_ready_cnt;
        end
    end
    
    wire all_finish = (done_cnt == AUTOTB_TRANSACTION_NUM);
    
    // done_cnt
    always @ (posedge AESL_clock) begin
        if (~AESL_reset) begin
            done_cnt <= 0;
        end else begin
            if (AESL_done == 1) begin
                if (done_cnt < AUTOTB_TRANSACTION_NUM) begin
                    done_cnt <= done_cnt + 1;
                end
            end
        end
    end
    
    initial begin : finish_simulation
        wait (all_finish == 1);
        // last transaction is saved at negedge right after last done
        @ (posedge AESL_clock);
        @ (posedge AESL_clock);
        @ (posedge AESL_clock);
        @ (posedge AESL_clock);
        $finish;
    end
    
initial begin
    AESL_clock = 0;
    forever #`AUTOTB_CLOCK_PERIOD_DIV2 AESL_clock = ~AESL_clock;
end


reg end_inputs;
reg [31:0] size_inputs;
reg [31:0] size_inputs_backup;
reg end_weights;
reg [31:0] size_weights;
reg [31:0] size_weights_backup;
reg end_outputs;
reg [31:0] size_outputs;
reg [31:0] size_outputs_backup;

initial begin : initial_process
    integer proc_rand;
    rst = 0;
    # 100;
    repeat(0+3) @ (posedge AESL_clock);
    rst = 1;
end
initial begin : initial_process_for_dut_rst
    integer proc_rand;
    dut_rst = 0;
    # 100;
    repeat(3) @ (posedge AESL_clock);
    dut_rst = 1;
end
initial begin : start_process
    integer proc_rand;
    reg [31:0] start_cnt;
    ce = 1;
    start = 0;
    start_cnt = 0;
    wait (AESL_reset === 1);
    @ (posedge AESL_clock);
    #0 start = 1;
    start_cnt = start_cnt + 1;
    forever begin
        if (start_cnt >= AUTOTB_TRANSACTION_NUM + 1) begin
            #0 start = 0;
        end
        @ (posedge AESL_clock);
        if (AESL_ready) begin
            start_cnt = start_cnt + 1;
        end
    end
end

always @(AESL_done)
begin
    tb_continue = AESL_done;
end

initial begin : ready_initial_process
    ready_initial = 0;
    wait (AESL_start === 1);
    ready_initial = 1;
    @(posedge AESL_clock);
    ready_initial = 0;
end

always @(posedge AESL_clock)
begin
    if(AESL_reset === 0)
      AESL_ready_delay = 0;
  else
      AESL_ready_delay = AESL_ready;
end
initial begin : ready_last_n_process
  ready_last_n = 1;
  wait(ready_cnt == AUTOTB_TRANSACTION_NUM)
  @(posedge AESL_clock);
  ready_last_n <= 0;
end

always @(posedge AESL_clock)
begin
    if(AESL_reset === 0)
      ready_delay_last_n = 0;
  else
      ready_delay_last_n <= ready_last_n;
end
assign ready = (ready_initial | AESL_ready_delay);
assign ready_wire = ready_initial | AESL_ready_delay;
initial begin : done_delay_last_n_process
  done_delay_last_n = 1;
  while(done_cnt < AUTOTB_TRANSACTION_NUM)
      @(posedge AESL_clock);
  # 0.1;
  done_delay_last_n = 0;
end

always @(posedge AESL_clock)
begin
    if(AESL_reset === 0)
  begin
      AESL_done_delay <= 0;
      AESL_done_delay2 <= 0;
  end
  else begin
      AESL_done_delay <= AESL_done & done_delay_last_n;
      AESL_done_delay2 <= AESL_done_delay;
  end
end
always @(posedge AESL_clock)
begin
    if(AESL_reset === 0)
      interface_done = 0;
  else begin
      # 0.01;
      if(ready === 1 && ready_cnt > 0 && ready_cnt < AUTOTB_TRANSACTION_NUM)
          interface_done = 1;
      else if(AESL_done_delay === 1 && done_cnt == AUTOTB_TRANSACTION_NUM)
          interface_done = 1;
      else
          interface_done = 0;
  end
end

reg dump_tvout_finish_outputs;

initial begin : dump_tvout_runtime_sign_outputs
    integer fp;
    dump_tvout_finish_outputs = 0;
    fp = $fopen(`AUTOTB_TVOUT_outputs_out_wrapc, "w");
    if (fp == 0) begin
        $display("Failed to open file \"%s\"!", `AUTOTB_TVOUT_outputs_out_wrapc);
        $display("ERROR: Simulation using HLS TB failed.");
        $finish;
    end
    $fdisplay(fp,"[[[runtime]]]");
    $fclose(fp);
    wait (done_cnt == AUTOTB_TRANSACTION_NUM);
    // last transaction is saved at negedge right after last done
    @ (posedge AESL_clock);
    @ (posedge AESL_clock);
    @ (posedge AESL_clock);
    fp = $fopen(`AUTOTB_TVOUT_outputs_out_wrapc, "a");
    if (fp == 0) begin
        $display("Failed to open file \"%s\"!", `AUTOTB_TVOUT_outputs_out_wrapc);
        $display("ERROR: Simulation using HLS TB failed.");
        $finish;
    end
    $fdisplay(fp,"[[[/runtime]]]");
    $fclose(fp);
    dump_tvout_finish_outputs = 1;
end


////////////////////////////////////////////
// progress and performance
////////////////////////////////////////////

task wait_start();
    while (~AESL_start) begin
        @ (posedge AESL_clock);
    end
endtask

reg [31:0] clk_cnt = 0;
reg AESL_ready_p1;
reg AESL_start_p1;

always @ (posedge AESL_clock) begin
    if (AESL_reset == 0) begin
        clk_cnt <= 32'h0;
        AESL_ready_p1 <= 1'b0;
        AESL_start_p1 <= 1'b0;
    end
    else begin
        clk_cnt <= clk_cnt + 1;
        AESL_ready_p1 <= AESL_ready;
        AESL_start_p1 <= AESL_start;
    end
end

reg [31:0] start_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] start_cnt;
reg [31:0] ready_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] ap_ready_cnt;
reg [31:0] finish_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] finish_cnt;
reg [31:0] lat_total;
event report_progress;

always @(posedge AESL_clock)
begin
    if (finish_cnt == AUTOTB_TRANSACTION_NUM - 1 && AESL_done == 1'b1)
        lat_total = clk_cnt - start_timestamp[0];
end

initial begin
    start_cnt = 0;
    finish_cnt = 0;
    ap_ready_cnt = 0;
    wait (AESL_reset == 1);
    wait_start();
    start_timestamp[start_cnt] = clk_cnt;
    start_cnt = start_cnt + 1;
    if (AESL_done) begin
        finish_timestamp[finish_cnt] = clk_cnt;
        finish_cnt = finish_cnt + 1;
    end
    -> report_progress;
    forever begin
        @ (posedge AESL_clock);
        if (start_cnt < AUTOTB_TRANSACTION_NUM) begin
            if ((AESL_start && AESL_ready_p1)||(AESL_start && ~AESL_start_p1)) begin
                start_timestamp[start_cnt] = clk_cnt;
                start_cnt = start_cnt + 1;
            end
        end
        if (ap_ready_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_start_p1 && AESL_ready_p1) begin
                ready_timestamp[ap_ready_cnt] = clk_cnt;
                ap_ready_cnt = ap_ready_cnt + 1;
            end
        end
        if (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_done) begin
                finish_timestamp[finish_cnt] = clk_cnt;
                finish_cnt = finish_cnt + 1;
            end
        end
        -> report_progress;
    end
end

reg [31:0] progress_timeout;

initial begin : simulation_progress
    real intra_progress;
    wait (AESL_reset == 1);
    progress_timeout = PROGRESS_TIMEOUT;
    $display("////////////////////////////////////////////////////////////////////////////////////");
    $display("// Inter-Transaction Progress: Completed Transaction / Total Transaction");
    $display("// Intra-Transaction Progress: Measured Latency / Latency Estimation * 100%%");
    $display("//");
    $display("// RTL Simulation : \"Inter-Transaction Progress\" [\"Intra-Transaction Progress\"] @ \"Simulation Time\"");
    $display("////////////////////////////////////////////////////////////////////////////////////");
    print_progress();
    while (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
        @ (report_progress);
        if (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_done) begin
                print_progress();
                progress_timeout = PROGRESS_TIMEOUT;
            end else begin
                if (progress_timeout == 0) begin
                    print_progress();
                    progress_timeout = PROGRESS_TIMEOUT;
                end else begin
                    progress_timeout = progress_timeout - 1;
                end
            end
        end
    end
    print_progress();
    $display("////////////////////////////////////////////////////////////////////////////////////");
    calculate_performance();
end

task get_intra_progress(output real intra_progress);
    begin
        if (start_cnt > finish_cnt) begin
            intra_progress = clk_cnt - start_timestamp[finish_cnt];
        end else if(finish_cnt > 0) begin
            intra_progress = LATENCY_ESTIMATION;
        end else begin
            intra_progress = 0;
        end
        intra_progress = intra_progress / LATENCY_ESTIMATION;
    end
endtask

task print_progress();
    real intra_progress;
    begin
        if (LATENCY_ESTIMATION > 0) begin
            get_intra_progress(intra_progress);
            $display("// RTL Simulation : %0d / %0d [%2.2f%%] @ \"%0t\"", finish_cnt, AUTOTB_TRANSACTION_NUM, intra_progress * 100, $time);
        end else begin
            $display("// RTL Simulation : %0d / %0d [n/a] @ \"%0t\"", finish_cnt, AUTOTB_TRANSACTION_NUM, $time);
        end
    end
endtask

task calculate_performance();
    integer i;
    integer fp;
    reg [31:0] latency [0:AUTOTB_TRANSACTION_NUM - 1];
    reg [31:0] latency_min;
    reg [31:0] latency_max;
    reg [31:0] latency_total;
    reg [31:0] latency_average;
    reg [31:0] interval [0:AUTOTB_TRANSACTION_NUM - 2];
    reg [31:0] interval_min;
    reg [31:0] interval_max;
    reg [31:0] interval_total;
    reg [31:0] interval_average;
    reg [31:0] total_execute_time;
    begin
        latency_min = -1;
        latency_max = 0;
        latency_total = 0;
        interval_min = -1;
        interval_max = 0;
        interval_total = 0;
        total_execute_time = lat_total;

        for (i = 0; i < AUTOTB_TRANSACTION_NUM; i = i + 1) begin
            // calculate latency
            latency[i] = finish_timestamp[i] - start_timestamp[i];
            if (latency[i] > latency_max) latency_max = latency[i];
            if (latency[i] < latency_min) latency_min = latency[i];
            latency_total = latency_total + latency[i];
            // calculate interval
            if (AUTOTB_TRANSACTION_NUM == 1) begin
                interval[i] = 0;
                interval_max = 0;
                interval_min = 0;
                interval_total = 0;
            end else if (i < AUTOTB_TRANSACTION_NUM - 1) begin
                interval[i] = start_timestamp[i + 1] - start_timestamp[i];
                if (interval[i] > interval_max) interval_max = interval[i];
                if (interval[i] < interval_min) interval_min = interval[i];
                interval_total = interval_total + interval[i];
            end
        end

        latency_average = latency_total / AUTOTB_TRANSACTION_NUM;
        if (AUTOTB_TRANSACTION_NUM == 1) begin
            interval_average = 0;
        end else begin
            interval_average = interval_total / (AUTOTB_TRANSACTION_NUM - 1);
        end

        fp = $fopen(`AUTOTB_LAT_RESULT_FILE, "w");

        $fdisplay(fp, "$MAX_LATENCY = \"%0d\"", latency_max);
        $fdisplay(fp, "$MIN_LATENCY = \"%0d\"", latency_min);
        $fdisplay(fp, "$AVER_LATENCY = \"%0d\"", latency_average);
        $fdisplay(fp, "$MAX_THROUGHPUT = \"%0d\"", interval_max);
        $fdisplay(fp, "$MIN_THROUGHPUT = \"%0d\"", interval_min);
        $fdisplay(fp, "$AVER_THROUGHPUT = \"%0d\"", interval_average);
        $fdisplay(fp, "$TOTAL_EXECUTE_TIME = \"%0d\"", total_execute_time);

        $fclose(fp);

        fp = $fopen(`AUTOTB_PER_RESULT_TRANS_FILE, "w");

        $fdisplay(fp, "%20s%16s%16s", "", "latency", "interval");
        if (AUTOTB_TRANSACTION_NUM == 1) begin
            i = 0;
            $fdisplay(fp, "transaction%8d:%16d%16d", i, latency[i], interval[i]);
        end else begin
            for (i = 0; i < AUTOTB_TRANSACTION_NUM; i = i + 1) begin
                if (i < AUTOTB_TRANSACTION_NUM - 1) begin
                    $fdisplay(fp, "transaction%8d:%16d%16d", i, latency[i], interval[i]);
                end else begin
                    $fdisplay(fp, "transaction%8d:%16d               x", i, latency[i]);
                end
            end
        end

        $fclose(fp);
    end
endtask


////////////////////////////////////////////
// Dependence Check
////////////////////////////////////////////

`ifndef POST_SYN

`endif
///////////////////////////////////////////////////////
// dataflow status monitor
///////////////////////////////////////////////////////
dataflow_monitor U_dataflow_monitor(
    .clock(AESL_clock),
    .reset(~rst),
    .finish(all_finish));

`include "fifo_para.vh"

endmodule
