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

module axi_lite_slave_wrapper #
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
   input  wire                         S_AXI_RREADY,

   //Avalon Interface Signals
    output wire [31:0]                  oAvsPcpAddress,
    output wire [3:0]                   oAvsPcpByteenable,
    output wire                         oAvsPcpRead,
    output wire                         oAvsPcpWrite,
    output wire [31:0]                  oAvsPcpWritedata,
    input  wire [31:0]                  iAvsPcpReaddata,
    input  wire                         iAvsPcpWaitrequest

  );

// Integrate Avalon Slave with Design
parameter   IDLE    = 2'b00    ;
parameter   DELAY    = 2'b01    ;
parameter   READ    = 2'b10    ;
parameter   WRITE   = 2'b11    ;
//Avalon Interface designs
wire [31:0]      address;
wire             chip_sel ;
wire [3:0]       byte_enable ;

reg [1:0]       pState  ;
reg [1:0]       nState  ;

reg             pBvalid     ;
reg             pAwready    ;
reg             pArready    ;
reg             pWready     ;
reg             pRvalid     ;

reg             nBvalid     ;
reg             nAwready    ;
reg             nArready    ;
reg             nWready     ;
reg             nRvalid     ;


//Port Assignments
assign oAvsPcpAddress      = address        ;
assign oAvsPcpByteenable   = byte_enable    ;
assign oAvsPcpRead         = S_AXI_ARVALID   ;
assign oAvsPcpWrite        = S_AXI_WVALID   ;
assign oAvsPcpWritedata    = S_AXI_WDATA    ;
//assign iAvsPcpWaitrequest
assign S_AXI_RDATA      =   iAvsPcpReaddata ;

assign chip_sel = (C_BASEADDR <=  S_AXI_AWADDR <= C_HIGHADDR) ? 1'b1 :
                  (C_BASEADDR <=  S_AXI_ARADDR <= C_HIGHADDR) ? 1'b1: 1'b0;

//TODO: Mux Addresss

assign  address =  (chip_sel & S_AXI_ARVALID ) ? S_AXI_ARADDR :
                   (chip_sel & S_AXI_AWVALID ) ? S_AXI_AWADDR : 32'hZ ;

//TODO: Byte Enable : Axi Lite supports all data accesses use the full width of the data bus
//                   — AXI4-Lite supports a data bus width of 32-bit or 64-bit. SPEC B1- Definition of AXI Lite
//Supports 4byte read/write

assign byte_enable  = S_AXI_WSTRB ;

assign S_AXI_BVALID     =   pBvalid     ;
assign S_AXI_AWREADY    =   pAwready    ;
assign S_AXI_ARREADY    =   pArready    ;
assign S_AXI_WREADY     =   pWready     ;
assign S_AXI_RVALID     =   pRvalid     ;
assign S_AXI_BRESP      =   2'b00       ;   //always OK;)
assign S_AXI_RRESP      =   2'b00       ;   //always ok;)


//AXI Write/Read Data Control signls FSM

//Registerd Logic for FSM
always @ (posedge ACLK)
begin
    if( ARESETN == 1'b0 )
    begin
        pState     <= IDLE ;
        pBvalid    <= 1'b0 ;
        pAwready   <= 1'b0 ;
        pArready   <= 1'b0 ;
        pWready    <= 1'b0 ;
        pRvalid    <= 1'b0 ;
    end
    else
    begin
        pState     <= nState ;
        pBvalid    <= nBvalid;
        pAwready   <= nAwready ;
        pArready   <= nArready ;
        pWready    <= nWready ;
        pRvalid    <= nRvalid ;
    end
end


//Step1: Wait for Address Valid --> Go to Read/Write (Step 2 or 3)
//Step2: Wait for ReadReady --> ReadValid & ReadAddressReady assert
//Step3: Wait for Wdata Valis --> Assert Wready & Awready & Bvalid with Bresp

//Combinational Logic for FSM
always @ (*)
begin

    case (pState)
        IDLE :
            begin
             nBvalid    <= 1'b0 ;
             nAwready   <= 1'b0 ;
             nArready   <= 1'b0 ;
             nWready    <= 1'b0 ;
             nRvalid    <= 1'b0 ;

             if(chip_sel == 1'b1 )
             begin
                if(S_AXI_AWVALID)
                nState <= WRITE ;
                else if (S_AXI_ARVALID)
                nState  <= READ ;
                else
                nState  <= IDLE ;
             end
             else
                nState <= IDLE ;
            end
        DELAY :
            begin
                nBvalid    <= 1'b0 ;
                nAwready   <= 1'b0 ;
                nArready   <= 1'b0 ;
                nWready    <= 1'b0 ;
                nRvalid    <= 1'b0 ;
                nState <= IDLE ;
            end
        READ :
            begin
             nBvalid    <= 1'b0 ;
             nAwready   <= 1'b0 ;
             nWready    <= 1'b0 ;

             //if( S_AXI_RREADY == 1'b1 )
             //begin
             nArready   <= 1'b1 ;
             nRvalid    <= 1'b1 ;
             nState     <= DELAY ;
             //end
             //else
             //begin
             //nArready   <= 1'b0 ;
             //nRvalid    <= 1'b0 ;
             //nState     <= READ ;
             //end
            end
        WRITE:
            begin
             nArready   <= 1'b0 ;
             nRvalid    <= 1'b0 ;

             if(S_AXI_WVALID == 1'b1 )
             begin
                nAwready   <= 1'b1 ;
                nBvalid    <= 1'b1 ; //TODO: Handle Response Independently
                nWready    <= 1'b1 ;
                nState     <= DELAY ;
             end
             else
             begin
                nAwready   <= 1'b0 ;
                nBvalid    <= 1'b0 ; //TODO: Handle Response Independently
                nWready    <= 1'b0 ;
                nState     <= WRITE ;
             end
            end
    endcase

end

//avalon_slave #
//    (
//    //TODO: add Parameters Here
//    .BASEADDRESS        (32'h0000_0000),
//    .ADD_DATA_WIDTH     (32)
//    )
//    AVALON_SLAVE
//    (
//     .iClk                  (   ACLK    ),
//     .nReset                (   ARESETN ),
//     .avs_pcp_address       (   address [10:0]) ,
//     .avs_pcp_byteenable    (   byte_enable),
//     .avs_pcp_read          (   S_AXI_RREADY    ),
//     .avs_pcp_readdata      (   S_AXI_RDATA     ), //TODO:Check Direct Assign is fine or not
//     .avs_pcp_write         (   S_AXI_WVALID    ),
//     .avs_pcp_writedata     (   S_AXI_WDATA     ), //TODO:Check Direct Assign is fine or not
//     .avs_pcp_waitrequest   () //TODO: No need of wait request ?
//    );


endmodule
