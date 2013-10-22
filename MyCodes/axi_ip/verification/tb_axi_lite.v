

module tb_axi_lite ();

// TEST PARAMS
parameter NO_REG_READ_WRITE = 8;
parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 32;
parameter SLAVE_BASE_ADDR = 32'h88000000 ;
parameter SLAVE_HIGH_ADDR = 32'h880001FF ;

//SIGNALS & WIRES
reg     	M_AXI_ACLK ;
reg      M_AXI_ARESETN ;


wire [31:0]   M_AXI_AWADDR  ;
wire [2:0]    M_AXI_AWPROT  ;
wire          M_AXI_AWVALID ;
wire          M_AXI_AWREADY ;

// Master Interface Write Data
wire [31:0]   M_AXI_WDATA   ;
wire [3:0]    M_AXI_WSTRB   ;
wire          M_AXI_WVALID  ;
wire          M_AXI_WREADY  ;

// Master Interface Write Response
wire [1:0]    M_AXI_BRESP   ;
wire          M_AXI_BVALID  ;
wire          M_AXI_BREADY  ;

// Master Interface Read Address
wire [31:0]   M_AXI_ARADDR  ;
wire [2:0]    M_AXI_ARPROT  ;
wire          M_AXI_ARVALID ;
wire          M_AXI_ARREADY ;

// Master Interface Read Data
wire [31:0]   M_AXI_RDATA   ;
wire [1:0]    M_AXI_RRESP   ;
wire          M_AXI_RVALID  ;
wire          M_AXI_RREADY  ;

reg          start_input_gpio ;



axi_lite_master #
   (
     .C_M_AXI_ADDR_WIDTH (ADDR_WIDTH),
     .C_M_AXI_DATA_WIDTH (DATA_WIDTH),
     .C_NUM_COMMANDS     (NO_REG_READ_WRITE),
     .READ_WRITE_ADDR    (SLAVE_BASE_ADDR)
    )
    MASTER
   (
    // System Signals
    .M_AXI_ACLK     (M_AXI_ACLK),
    .M_AXI_ARESETN  (M_AXI_ARESETN),

    // Master Interface Write Address
    .M_AXI_AWADDR   (M_AXI_AWADDR),
    .M_AXI_AWPROT   (M_AXI_AWPROT),
    .M_AXI_AWVALID  (M_AXI_AWVALID),
    .M_AXI_AWREADY  (M_AXI_AWREADY),

    // Master Interface Write Data
    .M_AXI_WDATA    (M_AXI_WDATA),
    .M_AXI_WSTRB    (M_AXI_WSTRB),
    .M_AXI_WVALID   (M_AXI_WVALID),
    .M_AXI_WREADY   (M_AXI_WREADY),

    // Master Interface Write Response
    .M_AXI_BRESP    (M_AXI_BRESP),
    .M_AXI_BVALID   (M_AXI_BVALID),
    .M_AXI_BREADY   (M_AXI_BREADY),

    // Master Interface Read Address
    .M_AXI_ARADDR   (M_AXI_ARADDR),
    .M_AXI_ARPROT   (M_AXI_ARPROT),
    .M_AXI_ARVALID  (M_AXI_ARVALID),
    .M_AXI_ARREADY  (M_AXI_ARREADY),

    // Master Interface Read Data
    .M_AXI_RDATA    (M_AXI_RDATA),
    .M_AXI_RRESP    (M_AXI_RRESP),
    .M_AXI_RVALID   (M_AXI_RVALID),
    .M_AXI_RREADY   (M_AXI_RREADY),

    //Example Output
    .DONE_SUCCESS   (),
    .start_input_gpio  (start_input_gpio),

   //Test Ports
    .test_awvalid  (),
    .test_awaddr   (),
    .test_wdata    (),
    .test_wvalid   (),
    .test_bready   (),
    .test_bvalid   (),
    .test_rready   (),
    .test_araddr   (),
    .test_arvalid  (),
    .test_rdata    (),
    .test_rvalid   ()
    );

axi_lite_slave #
  (
   .C_S_AXI_BASE_ADDR         (SLAVE_BASE_ADDR),
   .C_S_AXI_HIGH_ADDR         (SLAVE_HIGH_ADDR),
  // .C_S_AXI_MIN_SIZE   (32'h000001ff),
   .C_S_AXI_ADDR_WIDTH (ADDR_WIDTH),
   .C_S_AXI_DATA_WIDTH (DATA_WIDTH)
 //  .C_NUM_REG          (4)
   )
   SLAVE
  (
   // System Signals
   .ACLK          (M_AXI_ACLK),
   .ARESETN       (M_AXI_ARESETN),
   // Slave Interface Write Address Ports
   .S_AXI_AWADDR    (M_AXI_AWADDR),
   .S_AXI_AWPROT    (M_AXI_AWPROT),
   .S_AXI_AWVALID   (M_AXI_AWVALID),
   .S_AXI_AWREADY   (M_AXI_AWREADY),

   // Slave Interface Write Data Ports
   .S_AXI_WDATA     (M_AXI_WDATA),
   .S_AXI_WSTRB     (M_AXI_WSTRB),
   .S_AXI_WVALID    (M_AXI_WVALID),
   .S_AXI_WREADY    (M_AXI_WREADY),

   // Slave Interface Write Response Ports
   .S_AXI_BRESP     (M_AXI_BRESP),
   .S_AXI_BVALID    (M_AXI_BVALID),
   .S_AXI_BREADY    (M_AXI_BREADY),

   // Slave Interface Read Address Ports
   .S_AXI_ARADDR  	 (M_AXI_ARADDR),
   .S_AXI_ARPROT    (M_AXI_ARPROT),
   .S_AXI_ARVALID   (M_AXI_ARVALID),
   .S_AXI_ARREADY   (M_AXI_ARREADY),

   // Slave Interface Read Data Ports
   .S_AXI_RDATA     (M_AXI_RDATA),
   .S_AXI_RRESP     (M_AXI_RRESP),
   .S_AXI_RVALID    (M_AXI_RVALID),
   .S_AXI_RREADY    (M_AXI_RREADY)
  );

  initial
  begin
  $dumpfile("mydump.vcd");
  $dumpvars;//(0,tb_axi_lite);
  $dumpon ;//Enable val change dumping
  //$dumpoff Disable val change dumping
  end

 initial
  begin
    M_AXI_ACLK = 1'b0 ;
    M_AXI_ARESETN = 1'b0 ;
    start_input_gpio = 1'b0;
    #500 M_AXI_ARESETN = 1'b1 ;
    start_input_gpio = 1'b1 ;
    #30000 $stop;
  end

 always #50 M_AXI_ACLK = ~ M_AXI_ACLK ;

endmodule
