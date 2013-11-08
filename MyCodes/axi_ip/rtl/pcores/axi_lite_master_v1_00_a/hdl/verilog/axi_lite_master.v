///////////////////////////////////////////////////////////////////////////////
//
// AXI4-Lite Master
//
//////////////////////////////////////////////////////////////
/*
 AXI4-Lite Master Example

 The purpose of this design is to provide a simple AXI4-Lite example.

*/
`timescale 1ns/1ps

module axi_lite_master #
   (
    parameter integer C_M_AXI_ADDR_WIDTH = 32,
    parameter integer C_M_AXI_DATA_WIDTH = 32
    )
   (
    // System Signals
    input wire M_AXI_ACLK,
    input wire M_AXI_ARESETN,

    // Master Interface Write Address
    output wire [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_AWADDR,
    output wire [3-1:0] M_AXI_AWPROT,
    output wire M_AXI_AWVALID,
    input wire M_AXI_AWREADY,

    // Master Interface Write Data
    output wire [C_M_AXI_DATA_WIDTH-1:0] M_AXI_WDATA,
    output wire [C_M_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
    output wire M_AXI_WVALID,
    input wire M_AXI_WREADY,

    // Master Interface Write Response
    input wire [2-1:0] M_AXI_BRESP,
    input wire M_AXI_BVALID,
    output wire M_AXI_BREADY,

    // Master Interface Read Address
    output wire [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_ARADDR,
    output wire [3-1:0] M_AXI_ARPROT,
    output wire M_AXI_ARVALID,
    input wire M_AXI_ARREADY,

    // Master Interface Read Data
    input wire [C_M_AXI_DATA_WIDTH-1:0] M_AXI_RDATA,
    input wire [2-1:0] M_AXI_RRESP,
    input wire M_AXI_RVALID,
    output wire M_AXI_RREADY,
    //test ports
    output wire test_RValid,
    output wire test_RReady,
    output wire test_Arvalid,
    output wire test_Arready,
    output wire test_Bready,
    output wire test_Bvalid,
    output wire test_Wvalid,
    output wire test_Wready,
    output wire test_Awvalid,
    output wire test_Awready,
    output wire test_wait,
    output wire test_read,
    output wire test_write,
    output wire [31:0] test_awaddr,
    output wire [31:0] test_wdata,
    output wire [31:0] test_araddr,
    output wire [31:0] test_rdata,
    output wire [1:0]   test_avm_state,
    input  wire         read_write
    );

    //Avalon Signals
wire                        avalonRead  ;
wire                        avalonWrite ;
wire    [31:0]              avalonAddr  ;
wire    [3:0]               avalonBE    ;
wire                        avalonBeginTransfer ;
wire                         avalonWaitReq   ; //TODO: Check this part
wire                        avalonReadValid ;
wire    [31:0]              avalonReadData  ;
wire    [31:0]              avalonWriteData ;


assign test_RValid  =   M_AXI_RVALID    ;
assign test_RReady  =   M_AXI_RREADY    ;
assign test_Arvalid =   M_AXI_ARVALID   ;
assign test_Arready =   M_AXI_ARREADY   ;
assign test_Bready  =   M_AXI_BVALID    ;
assign test_Bvalid  =   M_AXI_BREADY    ;
assign test_Wvalid  =   M_AXI_WVALID    ;
assign test_Wready  =   M_AXI_WREADY    ;
assign test_Awvalid =   M_AXI_AWVALID   ;
assign test_Awready =   M_AXI_AWREADY   ;
assign test_wait    =   avalonWaitReq   ;
assign test_read    =   avalonRead      ;
assign test_write   =   avalonWrite     ;
assign test_awaddr  =   M_AXI_AWADDR    ;
assign test_wdata   =   M_AXI_WDATA     ;
assign test_araddr  =   M_AXI_ARADDR    ;
assign test_rdata   =   M_AXI_RDATA     ;

axi_lite_master_wrapper #
//axi_master_wrapper #
   (
    .C_M_AXI_ADDR_WIDTH (C_M_AXI_ADDR_WIDTH),
    .C_M_AXI_DATA_WIDTH (C_M_AXI_DATA_WIDTH)
    )
   MASTER_WRAPPER
   (
    // System Signals
    .M_AXI_ACLK         (M_AXI_ACLK),
    .M_AXI_ARESETN      (M_AXI_ARESETN),

    // Master Interface Write Address
    .M_AXI_AWADDR       (M_AXI_AWADDR),
    .M_AXI_AWPROT       (M_AXI_AWPROT),
    .M_AXI_AWVALID      (M_AXI_AWVALID),
    .M_AXI_AWREADY      (M_AXI_AWREADY),

    // Master Interface Write Data
    .M_AXI_WDATA        (M_AXI_WDATA),
    .M_AXI_WSTRB        (M_AXI_WSTRB),
    .M_AXI_WVALID       (M_AXI_WVALID),
    .M_AXI_WREADY       (M_AXI_WREADY),

    // Master Interface Write Response
    .M_AXI_BRESP        (M_AXI_BRESP),
    .M_AXI_BVALID       (M_AXI_BVALID),
    .M_AXI_BREADY       (M_AXI_BREADY),

    // Master Interface Read Address
    .M_AXI_ARADDR       (M_AXI_ARADDR),
    .M_AXI_ARPROT       (M_AXI_ARPROT),
    .M_AXI_ARVALID      (M_AXI_ARVALID),
    .M_AXI_ARREADY      (M_AXI_ARREADY),

    // Master Interface Read Data
    .M_AXI_RDATA        (M_AXI_RDATA),
    .M_AXI_RRESP        (M_AXI_RRESP),
    .M_AXI_RVALID       (M_AXI_RVALID),
    .M_AXI_RREADY       (M_AXI_RREADY),

    .avalonRead         (avalonRead),
    .avalonWrite        (avalonWrite),
    .avalonAddr         (avalonAddr),
    .avalonBE           (avalonBE),
    .avalonBeginTransfer (avalonBeginTransfer),
    .avalonWaitReq      (avalonWaitReq), //TODO: Check this part
    .avalonReadValid    (avalonReadValid),
    .avalonReadData     (avalonReadData),
    .avalonWriteData    (avalonWriteData)
    );
//Avalon Bus master Interface
avalon_master #(
    .ADDR_WIDTH (32),
    .WIDTH_WIDTH (32),
    .READ_WRITE_ADDR (32'hC7000000),
    .NO_READ_WRITE   (16)
 )
 AVALON_MASTER(
    .iClk       (M_AXI_ACLK),
    .iResetn    (M_AXI_ARESETN),
    .avalonRead (avalonRead),
    .avalonWrite (avalonWrite),
    .avalonAddr (avalonAddr),
    .avalonBE (avalonBE),
    .avalonBeginTransfer (avalonBeginTransfer),
    .avalonWaitReq (avalonWaitReq),
    .avalonReadValid (avalonReadValid),
    .avalonReadData (avalonReadData),
    .avalonWriteData (avalonWriteData),
    .test_avm_state  (test_avm_state),
    .read_write(read_write)
 );

endmodule
