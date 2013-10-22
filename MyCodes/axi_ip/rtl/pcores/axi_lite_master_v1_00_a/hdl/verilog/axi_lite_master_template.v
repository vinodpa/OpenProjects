///////////////////////////////////////////////////////////////////////////////
//
// AXI4/Lite Master
//
////////////////////////////////////////////////////////////////////////////
//
// Structure:
//   axi_lite_master
//
////////////////////////////////////////////////////////////////////////////

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

endmodule
