//-----------------------------------------------------------------------------
//-- (c) Copyright 2010 Xilinx, Inc. All rights reserved.
//--
//-- This file contains confidential and proprietary information
//-- of Xilinx, Inc. and is protected under U.S. and
//-- international copyright and other intellectual property
//-- laws.
//--
//-- DISCLAIMER
//-- This disclaimer is not a license and does not grant any
//-- rights to the materials distributed herewith. Except as
//-- otherwise provided in a valid license issued to you by
//-- Xilinx, and to the maximum extent permitted by applicable
//-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//-- (2) Xilinx shall not be liable (whether in contract or tort,
//-- including negligence, or under any other theory of
//-- liability) for any loss or damage of any kind or nature
//-- related to, arising under or in connection with these
//-- materials, including for any direct, or any indirect,
//-- special, incidental, or consequential loss or damage
//-- (including loss of data, profits, goodwill, or any type of
//-- loss or damage suffered as a result of any action brought
//-- by a third party) even if such damage or loss was
//-- reasonably foreseeable or Xilinx had been advised of the
//-- possibility of the same.
//--
//-- CRITICAL APPLICATIONS
//-- Xilinx products are not designed or intended to be fail-
//-- safe, or for use in any application requiring fail-safe
//-- performance, such as life-support or safety devices or
//-- systems, Class III medical devices, nuclear facilities,
//-- applications related to the deployment of airbags, or any
//-- other applications that could lead to death, personal
//-- injury, or severe property or environmental damage
//-- (individually and collectively, "Critical
//-- Applications"). Customer assumes the sole risk and
//-- liability of any use of Xilinx products in Critical
//-- Applications, subject only to applicable laws and
//-- regulations governing limitations on product liability.
//--
//-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//-- PART OF THIS FILE AT ALL TIMES.
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
   parameter integer C_S_AXI_BASE_ADDR            = 32'h0000_0000,
   parameter integer C_S_AXI_HIGH_ADDR            = 32'h0000_FFFF,
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

    reg        [C_S_AXI_DATA_WIDTH-1 : 0]           slv_reg0;
    reg        [C_S_AXI_DATA_WIDTH-1 : 0]           slv_reg1;
    reg        [C_S_AXI_DATA_WIDTH-1 : 0]           slv_reg2;
    reg        [C_S_AXI_DATA_WIDTH-1 : 0]           slv_reg3;
    reg        [C_S_AXI_DATA_WIDTH-1 : 0]           slv_reg0_addr = C_S_AXI_BASE_ADDR;
    reg        [C_S_AXI_DATA_WIDTH-1 : 0]           slv_reg1_addr = C_S_AXI_BASE_ADDR + 4;
    reg        [C_S_AXI_DATA_WIDTH-1 : 0]           slv_reg2_addr = C_S_AXI_BASE_ADDR + 8;
    reg        [C_S_AXI_DATA_WIDTH-1 : 0]           slv_reg3_addr = C_S_AXI_BASE_ADDR + 12;
	reg [31:0] read_address ;
	reg	   arready ;
	reg [1:0]   rresp;
	reg	    rvalid;
	reg [31:0] rdata;

	//reg [31:0] write_address = S_AXI_AWADDR ;
	reg	   awready ;
	reg [1:0]   bresp;
	//reg	    wvalid;
	//reg [31:0] wdata =  S_AXI_WDATA;;
	reg  wready;
	reg  bvalid;
	//reg  arvalid;
	assign S_AXI_AWREADY = awready ;
	assign S_AXI_ARREADY = arready ;
	assign S_AXI_RRESP = rresp;
	assign S_AXI_RVALID = rvalid;
	assign S_AXI_RDATA = rdata;
	assign S_AXI_WREADY = wready;
	assign S_AXI_BVALID = bvalid;
	//assign S_AXI_ARVALID = arvalid;

	assign S_AXI_BRESP = bresp;
	//assign S_AXI_WVALID = wvalid;

	//Write Address channel
	always @ (posedge ACLK)
	begin

	  if (ARESETN == 1'b0)
	  begin
		awready <= 1'b1;
		//write_address 	<= write_address;
	  end
	  else if(S_AXI_AWVALID==1'b1)
	  begin
	  if(( C_S_AXI_BASE_ADDR >  S_AXI_AWADDR > C_S_AXI_HIGH_ADDR ))
		begin
		awready <= 1'b0;
		//write_address 	<= S_AXI_AWADDR;
		end
		else
		begin
		awready <= 1'b1;
		//write_address 	<= write_address;
		end

	  end
	end
	//Write Data Channel
	always @ (posedge ACLK)
	begin

	  if (ARESETN == 1'b0)
		begin
		wready <= 1'b0;
		bresp <= 2'b00; //OKAY
		bvalid <= 1'b0;
		end
	  else if(S_AXI_WVALID==1'b1 && S_AXI_BREADY == 1'b1)
	  begin
		if(( C_S_AXI_BASE_ADDR >  S_AXI_AWADDR > C_S_AXI_HIGH_ADDR ))
		begin
		case ( S_AXI_AWADDR)
		slv_reg0_addr:
		slv_reg0 <=  S_AXI_WDATA;
		slv_reg1_addr:
		slv_reg1 <=  S_AXI_WDATA;
		slv_reg2_addr:
		slv_reg2 <=  S_AXI_WDATA;
		slv_reg3_addr:
		slv_reg3 <=  S_AXI_WDATA;
		default
		begin
		bresp <= 2'b11; //SLAVE ERROR(SLVERR)
		end
		endcase
				wready <= 1'b1;
		bresp <= 2'b00; //OKAY
		bvalid <= 1'b1;
		end
		else
		begin
		wready <= 1'b0;
		bresp <= 2'b00; //OKAY
		bvalid <= 1'b0;
		end
	  end
	  else
	  begin
	  wready <= 1'b0;
	  bresp <= 2'b00; //OKAY
	  bvalid <= 1'b0;
	  end
	end
	//Read Address Channel
	always @ (posedge ACLK)
	begin
		if(S_AXI_ARVALID== 1'b1)
		begin
			read_address 	<= S_AXI_ARADDR;
			arready  	<= 1'b0 ;
		end
		else
		begin
			read_address <= read_address ;
			arready  	<= 1'b1 ;
		end
		
	end
	//Read Data Channel
	always @ (posedge ACLK)
	begin
	  if(S_AXI_RREADY == 1'b1 && S_AXI_ARPROT==3'b000)
	  begin
		if(( C_S_AXI_BASE_ADDR > read_address > C_S_AXI_HIGH_ADDR ))
		begin
		rvalid <= 1'b1;
		rresp <= 2'b00; //OKAY
		end
		else
		begin
		rvalid <= 1'b0;
		rresp <= 2'b00; //OKAY
		end

		case (read_address)
		slv_reg0_addr:
		rdata <= slv_reg0;
		slv_reg1_addr:
		rdata <= slv_reg1;
		slv_reg2_addr:
		rdata <= slv_reg2;
		slv_reg3_addr:
		rdata <= slv_reg3;
		default
		begin
		rdata <= 32'hAAAA_BBBB;
		end
		endcase
	  end
	  else
	  begin
		rvalid <= 1'b0;
		rresp <= 2'b00; //OKAY
	  end
	end

endmodule
