//-----------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------
//
// AXI Lite Slave
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   axi_lite_slave
//
//--------------------------------------------------------------------------

`timescale 1ns/1ps

module axi_lite_slave #
  (
   parameter integer C_BASEADDR            = 32'h0000_0000,
   parameter integer C_HIGHADDR            = 32'h0000_FFFF,
   parameter integer C_S_AXI_ADDR_WIDTH            = 32,
   parameter integer C_S_AXI_DATA_WIDTH            = 32
   )
  (
   // System Signals
   input wire ACLK,
   input wire ARESETN,

   // Slave Interface Write Address Ports
   input  wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
   input  wire [3-1:0]                  S_AXI_AWPROT,
   input  wire                          S_AXI_AWVALID,
   output wire                          S_AXI_AWREADY,

   // Slave Interface Write Data Ports
   input  wire [C_S_AXI_DATA_WIDTH-1:0]   S_AXI_WDATA,
   input  wire [C_S_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
   input  wire                          S_AXI_WVALID,
   output wire                          S_AXI_WREADY,

   // Slave Interface Write Response Ports
   output wire [2-1:0]                 S_AXI_BRESP,
   output wire                         S_AXI_BVALID,
   input  wire                         S_AXI_BREADY,

   // Slave Interface Read Address Ports
   input  wire [C_S_AXI_ADDR_WIDTH-1:0]   S_AXI_ARADDR,
   input  wire [3-1:0]                  S_AXI_ARPROT,
   input  wire                          S_AXI_ARVALID,
   output wire                          S_AXI_ARREADY,

   // Slave Interface Read Data Ports
   output wire [C_S_AXI_DATA_WIDTH-1:0]  S_AXI_RDATA,
   output wire [2-1:0]                 S_AXI_RRESP,
   output wire                         S_AXI_RVALID,
   input  wire                         S_AXI_RREADY

  );



//Interconnect
wire [31:0]   AvsPcpAddress     ;
wire [3:0]    AvsPcpByteenable  ;
wire          AvsPcpRead        ;
wire          AvsPcpWrite       ;
wire [31:0]   AvsPcpWritedata   ;
wire [31:0]   AvsPcpReaddata    ;
wire          AvsPcpWaitrequest ;

axi_lite_slave_wrapper #
  (
   .C_BASEADDR          (C_BASEADDR),
   .C_HIGHADDR          (C_HIGHADDR),
   .C_S_AXI_ADDR_WIDTH  (C_S_AXI_ADDR_WIDTH),
   .C_S_AXI_DATA_WIDTH  (C_S_AXI_DATA_WIDTH)
   )
  WRAPPER
  (
   // System Signals
   .ACLK                (ACLK),
   .ARESETN             (ARESETN),

   // Slave Interface Write Address Ports
   .S_AXI_AWADDR        (S_AXI_AWADDR),
   .S_AXI_AWPROT        (S_AXI_AWPROT),
   .S_AXI_AWVALID       (S_AXI_AWVALID),
   .S_AXI_AWREADY       (S_AXI_AWREADY),

   // Slave Interface Write Data Ports
   .S_AXI_WDATA         (S_AXI_WDATA),
   .S_AXI_WSTRB         (S_AXI_WSTRB),
   .S_AXI_WVALID        (S_AXI_WVALID),
   .S_AXI_WREADY        (S_AXI_WREADY),

   // Slave Interface Write Response Ports
   .S_AXI_BRESP         (S_AXI_BRESP),
   .S_AXI_BVALID        (S_AXI_BVALID),
   .S_AXI_BREADY        (S_AXI_BREADY),

   // Slave Interface Read Address Ports
   .S_AXI_ARADDR        (S_AXI_ARADDR),
   .S_AXI_ARPROT        (S_AXI_ARPROT),
   .S_AXI_ARVALID       (S_AXI_ARVALID),
   .S_AXI_ARREADY       (S_AXI_ARREADY),

   // Slave Interface Read Data Ports
   .S_AXI_RDATA         (S_AXI_RDATA),
   .S_AXI_RRESP         (S_AXI_RRESP),
   .S_AXI_RVALID        (S_AXI_RVALID),
   .S_AXI_RREADY        (S_AXI_RREADY),

   //Avalon Interface signals
   .oAvsPcpAddress      (AvsPcpAddress      ),
   .oAvsPcpByteenable   (AvsPcpByteenable   ),
   .oAvsPcpRead         (AvsPcpRead         ),
   .oAvsPcpWrite        (AvsPcpWrite        ),
   .oAvsPcpWritedata    (AvsPcpWritedata    ),
   .iAvsPcpReaddata     (AvsPcpReaddata     ),
   .iAvsPcpWaitrequest  (AvsPcpWaitrequest  )

  );


avalon_slave #
    (
    //TODO: add Parameters Here
    .BASEADDRESS        (C_BASEADDR),
    .ADD_DATA_WIDTH     (32)
    )
    AVALON_SLAVE
    (
     .iClk                  (   ACLK                ),
     .nReset                (   ARESETN             ),
     .avs_pcp_address       (   AvsPcpAddress[10:0] ) ,
     .avs_pcp_byteenable    (   AvsPcpByteenable    ),
     .avs_pcp_read          (   AvsPcpRead          ),
     .avs_pcp_readdata      (   AvsPcpReaddata      ), //TODO:Check Direct Assign is fine or not
     .avs_pcp_write         (   AvsPcpWrite         ),
     .avs_pcp_writedata     (   AvsPcpWritedata     ), //TODO:Check Direct Assign is fine or not
     .avs_pcp_waitrequest   (   AvsPcpWaitrequest   ) //TODO: No need of wait request ?
    );

endmodule
