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
    output wire M_AXI_RREADY
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


axi_lite_master_wrapper #
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
    .M_AXI_BREADY       (M_AXI_BREADY,

    // Master Interface Read Address
    .M_AXI_ARADDR       (M_AXI_ARADDR),
    .M_AXI_ARPROT       (M_AXI_ARPROT,
    .M_AXI_ARVALID      (M_AXI_ARVALID),
    .M_AXI_ARREADY      (M_AXI_ARREADY,

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
    .avalonWriteData (avalonWriteData)
 );

endmodule
