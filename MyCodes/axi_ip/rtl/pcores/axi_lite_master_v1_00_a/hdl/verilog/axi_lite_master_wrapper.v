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

module axi_lite_master_wrapper #
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

    input   wire           avalonRead  ,
    input   wire           avalonWrite ,
    input   wire    [31:0] avalonAddr  ,
    input   wire    [3:0]  avalonBE    ,
    input   wire           avalonBeginTransfer ,
    output  wire           avalonWaitReq   , //TODO: Check this part
    output  wire           avalonReadValid ,
    output  wire    [31:0] avalonReadData  ,
    input   wire    [31:0] avalonWriteData
    );


parameter IDLE          = 3'b000 ;
parameter ADDR          = 3'b001 ;
parameter WRITE_RES     = 3'b010 ;
parameter READ_DATA     = 3'b011 ;
parameter READ_RESP     = 3'b100 ;

reg     [2:0]       CurrentState ;
reg     [2:0]       NextState ;
//Write Address Channel
reg                             Awvalid ;
wire                             wAwvalid ;
//wire                            Awready        ;
//Write Data Channel
reg                             Wvalid;
wire                             wWvalid;
//wire                            WReady ;
//Write Response Channel
reg                             Bready ;
wire                            wBready ;
//wire                            BValid ;
//Read Address Channel
reg                             Arvalid     ;
wire                             wArvalid     ;
//reg                             pArvalid     ;
//reg                             nArvalid     ;
//wire                            Arready     ;
//Read Data Channel
reg                              Rready     ;
wire                             wRready     ;
//reg                             rRready     ;
//wire                             Rvalid     ;

// Handle Avalon Master
wire start_transfer ;
wire done_transfer ;

wire    wRReady ;
reg     rd_done   ;

parameter INIT  = 3'b000;
parameter AWVALID   = 3'b001;
parameter WVALID    = 3'b010;
parameter BREADY    = 3'b011;
parameter ARVALID   = 3'b100;
parameter RREADY    = 3'b101;
parameter WRITE_DONE      = 3'b110;
parameter READ_DONE      = 3'b111;

// AXI Signals

//assign M_AXI_RRESP  = 2'b00     ; //TODO: Add other response also
assign M_AXI_AWPROT = 3'b000    ;
assign M_AXI_ARPROT = 3'b000    ;

assign M_AXI_AWADDR = (avalonWrite == 1'b1)? avalonAddr :32'hZZZZZZZZ ;
assign M_AXI_ARADDR = (avalonRead == 1'b1)? avalonAddr :32'hZZZZZZZZ ;
assign M_AXI_WDATA  = avalonWriteData ;
assign M_AXI_WSTRB  = avalonBE  ;


assign M_AXI_AWVALID   = (avalonWrite == 1'b1)? 1'b1 :
                         (CurrentState == AWVALID) ? 1'b1: 1'b0;

assign M_AXI_WVALID    = (avalonWrite == 1'b1)? 1'b1 :
                         (CurrentState == AWVALID)? 1'b1:
                         (CurrentState == WVALID)? 1'b1 :1'b0;

assign M_AXI_BREADY    = (CurrentState == WRITE_DONE) ? 1'b1: 1'b0; //TODO: 1 Clock dealy

assign M_AXI_ARVALID   = (avalonRead == 1'b1)? 1'b1 :
                         (CurrentState ==  ARVALID) ? 1'b1: 1'b0 ;
assign M_AXI_RREADY    = (CurrentState == READ_DONE) ? 1'b1: 1'b0;


assign wRReady = (CurrentState == READ_DONE) ? 1'b1: 1'b0;


assign start_transfer   =   ((avalonRead & ~wRReady) || avalonWrite) ;
//assign done_transfer    =   (M_AXI_AWREADY && M_AXI_WREADY && M_AXI_BVALID) ||
//                            (M_AXI_ARREADY && M_AXI_RVALID) ;
assign done_transfer    =   M_AXI_WREADY || (M_AXI_RVALID & wRReady) || rd_done ;
//
// Read Data Valid
assign avalonReadValid   =  M_AXI_RVALID ;
//Read Data
assign avalonReadData   =   M_AXI_RDATA ;
//Wait Request
// Combinational Feedback through a flop //TODO: Check wethert its create dead loops

assign avalonWaitReq =  (done_transfer == 1'b1) ? 1'b0 :
                        (start_transfer == 1'b1)? 1'b1 :1'b0 ;


//
always @ (posedge M_AXI_ACLK)
begin
    if( M_AXI_ARESETN == 1'b0)
    begin
        rd_done <= 1'b0 ;
    end
    else
    begin
        rd_done <= (M_AXI_RVALID & wRReady) ;
    end
end
// AXI master FSM
always @ (posedge M_AXI_ACLK)
begin
    if(M_AXI_ARESETN == 1'b0)
    begin
    CurrentState <= INIT;
    end
    else
    begin
    CurrentState <= NextState ;
    end
end

always @ (*)
begin
    NextState <= CurrentState ;

    case (CurrentState)
    INIT:
    begin
        if(avalonRead == 1'b1)
            NextState <= ARVALID ;
        else if (avalonWrite == 1'b1)
            NextState <= AWVALID ;
        else
            NextState <= INIT ;
    end
    AWVALID:
    begin
        if(M_AXI_AWREADY  == 1'b1)
            if(M_AXI_WREADY  == 1'b1)
                if(M_AXI_BVALID  == 1'b1)
                    NextState <= WRITE_DONE ;
                else
                    NextState <= BREADY ;
            else
                NextState <= WVALID ;
        else
            NextState <= AWVALID ;
    end
    WVALID:
    begin
        if(M_AXI_WREADY  == 1'b1)
            if(M_AXI_BVALID  == 1'b1)
                NextState <= WRITE_DONE ;
            else
                NextState <= BREADY ;
        else
            NextState <= WVALID ;
    end
    BREADY:
    begin
        if(M_AXI_BVALID  == 1'b1)
            NextState <= WRITE_DONE ;
        else
            NextState <= BREADY ;
    end
    ARVALID:
    begin
        if(M_AXI_ARREADY == 1'b1)
            if(M_AXI_RVALID == 1'b1)
                NextState <= READ_DONE ;
            else
                NextState <= RREADY ;
        else
            NextState <= ARVALID ;
    end
    RREADY:
    begin
        if(M_AXI_RVALID == 1'b1)
            NextState <= READ_DONE ;
        else
            NextState <= RREADY ;
    end
    WRITE_DONE:
    begin
        NextState <= INIT ;
    end
    READ_DONE:
    begin
        NextState <= INIT ;
    end
    endcase
end

endmodule
