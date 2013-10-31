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

reg     [2:0]       StateCurrent ;
reg     [2:0]       StateNext ;
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

parameter A =2'b00;
parameter B =2'b01;
parameter C =2'b10;
reg [1:0] nstate,pstate;

parameter A1 =2'b00;
parameter B1 =2'b01;
parameter C1 =2'b10;
reg [1:0] n1state,p1state;

parameter A2 =2'b00;
parameter B2 =2'b01;
parameter C2 =2'b10;
reg [1:0] n2state,p2state;

parameter A3 =2'b00;
parameter B3 =2'b01;
parameter C3 =2'b10;
reg [1:0] n3state,p3state;

parameter A4 =2'b00;
parameter B4 =2'b01;
parameter C4 =2'b10;
reg [1:0] n4state,p4state;


// AXI Signals

assign M_AXI_RRESP  = 2'b00     ; //TODO: Add other response also
assign M_AXI_AWPROT = 3'b000    ;
assign M_AXI_ARPROT = 3'b000    ;

assign M_AXI_AWADDR = (avalonWrite == 1'b1)? avalonAddr :32'hZZZZZZZZ ;
assign M_AXI_ARADDR = (avalonRead == 1'b1)? avalonAddr :32'hZZZZZZZZ ;
assign M_AXI_WDATA  = avalonWriteData ;
assign M_AXI_WSTRB  = avalonBE  ;


//AXI Write Operations
//assign M_AXI_WVALID    = Wvalid  ;
//assign M_AXI_AWVALID   = Awvalid ;
//assign M_AXI_BREADY    = Bready  ;

assign M_AXI_WVALID    = wWvalid  ;
assign M_AXI_AWVALID   = wAwvalid ;
assign M_AXI_BREADY    = wBready  ;


//AXI Read Operations
//assign M_AXI_ARVALID   = Arvalid ;
assign M_AXI_ARVALID   = wArvalid;
//assign M_AXI_RREADY    = Rready  ;
assign M_AXI_RREADY    = wRready ;
//Address & Data Valid AWVALID & WVALID
// TODO: Combinational Feedback on systems , Not a good Idea ?
//AWValid Handling
assign wAwvalid = (p2state == B2) ? 1'b1 : 1'b0;


always @ (posedge M_AXI_ACLK)
begin
    if(M_AXI_ARESETN == 1'b0)
    begin
    p2state <= A2;
    end
    else
    begin
    p2state <= n2state ;
    end
end
always @ (*)
begin
    case (p2state)
    A2:
    begin
        if (avalonWrite  == 1'b1) n2state <= B2;
        else n2state <= A2;
    end
    B2:
    begin
        if (M_AXI_AWREADY  == 1'b1) n2state <= C2;
        else n2state <= B2;
    end
    C2:
    begin
        n2state <= A2;
    end
    default:
    begin
    end
    endcase
end
//WValid Handling
assign wWvalid = (p3state == B3) ? 1'b1 : 1'b0;


always @ (posedge M_AXI_ACLK)
begin
    if(M_AXI_ARESETN == 1'b0)
    begin
    p3state <= A3;
    end
    else
    begin
    p3state <= n3state ;
    end
end
always @ (*)
begin
    case (p3state)
    A3:
    begin
        if (avalonWrite  == 1'b1) n3state <= B3;
        else n3state <= A3;
    end
    B3:
    begin
        if (M_AXI_WREADY  == 1'b1) n3state <= C3;
        else n3state <= B3;
    end
    C3:
    begin
        n3state <= A3;
    end
    default:
    begin
    end
    endcase
end
//Write Response Handling
assign wBready = (p4state == B4) ? 1'b1 : 1'b0;

always @ (posedge M_AXI_ACLK)
begin
    if(M_AXI_ARESETN == 1'b0)
    begin
    p4state <= A4;
    end
    else
    begin
    p4state <= n4state ;
    end
end
always @ (*)
begin
    case (p4state)
    A4:
    begin
        if (avalonWrite  == 1'b1) n4state <= B4;
        else n4state <= A4;
    end
    B4:
    begin
        if (M_AXI_BVALID  == 1'b1) n4state <= C4;
        else n4state <= B4;
    end
    C4:
    begin
        n4state <= A4;
    end
    default:
    begin
    end
    endcase
end
/*
always @ (posedge M_AXI_ACLK)
begin
    if(M_AXI_ARESETN == 1'b0)
    begin
        Bready <= 1'b0  ;
    end
    else if (M_AXI_BVALID == 1'b1)
    begin
        Bready <= 1'b0  ;
    end
    else if (avalonWrite == 1'b1)
    begin
        Bready <= 1'b1  ;
    end
    else
    begin
        Bready <= Bready  ;
    end
end
*/
// AXI Read Signal Handling
//ARValid handling
/*
*******************************************************
*/
//TODO: ????
assign wArvalid = (pstate == B) ? 1'b1 : 1'b0;


always @ (posedge M_AXI_ACLK)
begin
    if(M_AXI_ARESETN == 1'b0)
    begin
    pstate <= A;
    end
    else
    begin
    pstate <= nstate ;
    end
end
always @ (*)
begin
    case (pstate)
    A:
    begin
        if (avalonRead  == 1'b1) nstate <= B;
        else nstate <= A;
    end
    B:
    begin
        if (M_AXI_ARREADY  == 1'b1) nstate <= C;
        else nstate <= B;
    end
    C:
    begin
        nstate <= A;
    end
    default:
    begin
    end
    endcase
end

/*
*******************************************************
*/
/*
always @ (posedge M_AXI_ACLK)
begin
    if(M_AXI_ARESETN == 1'b0)
    begin
        //Rready  <= 1'b0 ;
        Arvalid <= 1'b0 ;
    end
    //else if ((M_AXI_ARREADY && M_AXI_RVALID) == 1'b1)
    else if (M_AXI_ARREADY  == 1'b1)
    begin
        //Rready  <= 1'b0 ;
        Arvalid <= 1'b0 ;
    end
    else if (avalonRead == 1'b1)
    begin
        //Rready  <= 1'b1 ;
        Arvalid <= 1'b1 ;
    end
    else
    begin
        //Rready  <= Rready  ;
        Arvalid <= Arvalid  ;
    end
end
*/
/*
*******************************************************
*/
//TODO: ????
//RReady Handling
//assign wRready = (M_AXI_RVALID == 1'b1) ? 1'b0 :
//                 (avalonRead == 1'b1) ? 1'b1 :1'b0 ;
assign wRready = (pstate == B1) ? 1'b1 : 1'b0;


always @ (posedge M_AXI_ACLK)
begin
    if(M_AXI_ARESETN == 1'b0)
    begin
    p1state <= A1;
    end
    else
    begin
    p1state <= n1state ;
    end
end
always @ (*)
begin
    case (p1state)
    A1:
    begin
        if (avalonRead  == 1'b1) n1state <= B1;
        else n1state <= A1;
    end
    B1:
    begin
        if (M_AXI_RVALID  == 1'b1) n1state <= C1;
        else n1state <= B1;
    end
    C1:
    begin
        n1state <= A1;
    end
    default:
    begin
    end
    endcase
end

/*
always @ (posedge M_AXI_ACLK)
begin
    if(M_AXI_ARESETN == 1'b0)
    begin
        rRready <= 1'b0;
    end
    else
    begin
        rRready <= wRready;
    end
end
/*
*******************************************************
*/
/*
always @ (posedge M_AXI_ACLK)
begin
    if(M_AXI_ARESETN == 1'b0)
    begin
        Rready  <= 1'b0 ;
        //Arvalid <= 1'b0 ;
    end
    //else if ((M_AXI_ARREADY && M_AXI_RVALID) == 1'b1)
    else if (M_AXI_RVALID == 1'b1)
    begin
        Rready  <= 1'b0 ;
        //Arvalid <= 1'b0 ;
    end
    else if (avalonRead == 1'b1)
    begin
        Rready  <= 1'b1 ;
        //Arvalid <= 1'b1 ;
    end
    else
    begin
        Rready  <= Rready   ;
        //Arvalid <= Arvalid ;
    end
end
*/
/*
********************************************************************************
*/
assign start_transfer   =   (avalonRead || avalonWrite) ;
//assign done_transfer    =   (M_AXI_AWREADY && M_AXI_WREADY && M_AXI_BVALID) ||
//                            (M_AXI_ARREADY && M_AXI_RVALID) ;
assign done_transfer    =   M_AXI_BVALID || M_AXI_RVALID ;
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
