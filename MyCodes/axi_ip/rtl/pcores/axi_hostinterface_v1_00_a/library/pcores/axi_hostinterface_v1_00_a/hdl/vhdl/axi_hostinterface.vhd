-------------------------------------------------------------------------------
--! @file xilinxHostInterface.vhd
--
--! @brief toplevel of host interface for Xilinx FPGA
--
--! @details This toplevel interfaces to Xilinx specific implementation.
--
-------------------------------------------------------------------------------
--
--    (c) B&R, 2012
--    (c) Kalycito Infotech Pvt Ltd
--
--    Redistribution and use in source and binary forms, with or without
--    modification, are permitted provided that the following conditions
--    are met:
--
--    1. Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--
--    2. Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--
--    3. Neither the name of B&R nor the names of its
--       contributors may be used to endorse or promote products derived
--       from this software without prior written permission. For written
--       permission, please contact office@br-automation.com
--
--    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
--    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
--    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
--    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
--    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
--    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--    POSSIBILITY OF SUCH DAMAGE.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--! use global library
use work.global.all;

entity axi_hostinterface is
  generic
  (
    -- PCP AXI Slave Parameters
    C_S_AXI_DATA_WIDTH          : integer              := 32;
    C_S_AXI_ADDR_WIDTH          : integer              := 32;
    C_S_AXI_MIN_SIZE            : std_logic_vector     := X"0001FFFF";
    C_BASEADDR                  : std_logic_vector     := X"FFFFFFFF";
    C_HIGHADDR                  : std_logic_vector     := X"00000000";
    C_FAMILY                    : string               := "virtex6" ;
    -- Host AXI Slave Parameters
    C_S_HOST_AXI_DATA_WIDTH     : integer              := 32;
    C_S_HOST_AXI_ADDR_WIDTH     : integer              := 32;
    C_S_HOST_AXI_MIN_SIZE       : std_logic_vector     := X"0001FFFF";
    C_HOST_BASEADDR             : std_logic_vector     := X"FFFFFFFF";
    C_HOST_HIGHADDR             : std_logic_vector     := X"00000000";
    C_HOST_FAMILY               : string               := "virtex6" ;
    --Master Bridge Parameters
    C_M_AXI_ADDR_WIDTH          : integer              := 32;
    C_M_AXI_DATA_WIDTH          : integer              := 32;
    -- Host Interface
    --! Version major
    gVersionMajor               : natural := 16#FF#;
    --! Version minor
    gVersionMinor               : natural := 16#FF#;
    --! Version revision
    gVersionRevision            : natural := 16#FF#;
    --! Version count
    gVersionCount               : natural := 0;
    -- Base address mapping
    --! Base address Dynamic Buffer 0
    gBaseDynBuf0                : natural := 16#00800#;
    --! Base address Dynamic Buffer 1
    gBaseDynBuf1                : natural := 16#01000#;
    --! Base address Error Counter
    gBaseErrCntr                : natural := 16#01800#;
    --! Base address TX NMT Queue
    gBaseTxNmtQ                 : natural := 16#02800#;
    --! Base address TX Generic Queue
    gBaseTxGenQ                 : natural := 16#03800#;
    --! Base address TX SyncRequest Queue
    gBaseTxSynQ                 : natural := 16#04800#;
    --! Base address TX Virtual Ethernet Queue
    gBaseTxVetQ                 : natural := 16#05800#;
    --! Base address RX Virtual Ethernet Queue
    gBaseRxVetQ                 : natural := 16#06800#;
    --! Base address Kernel-to-User Queue
    gBaseK2UQ                   : natural := 16#07000#;
    --! Base address User-to-Kernel Queue
    gBaseU2KQ                   : natural := 16#09000#;
    --! Base address Tpdo
    gBaseTpdo                   : natural := 16#0B000#;
    --! Base address Rpdo
    gBaseRpdo                   : natural := 16#0E000#;
    --! Base address Reserved (-1 = high address of Rpdo)
    gBaseRes                    : natural := 16#14000#;
    --! Select Host Interface Type (0 = Avalon, 1 = Parallel)
    gHostIfType                 : natural := 0 ;
    --! Data width of parallel interface (16/32)
    gParallelDataWidth  : natural := 16;
    --! Address and Data bus are multiplexed (0 = FALSE, otherwise = TRUE)
    gParallelMultiplex  : natural := 0
   );
  port
  (
    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    S_AXI_PCP_ACLK                     : in  std_logic;
    S_AXI_PCP_ARESETN                  : in  std_logic;
    S_AXI_PCP_AWADDR                   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_PCP_AWVALID                  : in  std_logic;
    S_AXI_PCP_WDATA                    : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_PCP_WSTRB                    : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_PCP_WVALID                   : in  std_logic;
    S_AXI_PCP_BREADY                   : in  std_logic;
    S_AXI_PCP_ARADDR                   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_PCP_ARVALID                  : in  std_logic;
    S_AXI_PCP_RREADY                   : in  std_logic;
    S_AXI_PCP_ARREADY                  : out std_logic;
    S_AXI_PCP_RDATA                    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_PCP_RRESP                    : out std_logic_vector(1 downto 0);
    S_AXI_PCP_RVALID                   : out std_logic;
    S_AXI_PCP_WREADY                   : out std_logic;
    S_AXI_PCP_BRESP                    : out std_logic_vector(1 downto 0);
    S_AXI_PCP_BVALID                   : out std_logic;
    S_AXI_PCP_AWREADY                  : out std_logic;
    -- Host Interface AXI
    S_AXI_HOST_ACLK                     : in  std_logic;
    S_AXI_HOST_ARESETN                  : in  std_logic;
    S_AXI_HOST_AWADDR                   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_HOST_AWVALID                  : in  std_logic;
    S_AXI_HOST_WDATA                    : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_HOST_WSTRB                    : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_HOST_WVALID                   : in  std_logic;
    S_AXI_HOST_BREADY                   : in  std_logic;
    S_AXI_HOST_ARADDR                   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_HOST_ARVALID                  : in  std_logic;
    S_AXI_HOST_RREADY                   : in  std_logic;
    S_AXI_HOST_ARREADY                  : out std_logic;
    S_AXI_HOST_RDATA                    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_HOST_RRESP                    : out std_logic_vector(1 downto 0);
    S_AXI_HOST_RVALID                   : out std_logic;
    S_AXI_HOST_WREADY                   : out std_logic;
    S_AXI_HOST_BRESP                    : out std_logic_vector(1 downto 0);
    S_AXI_HOST_BVALID                   : out std_logic;
    S_AXI_HOST_AWREADY                  : out std_logic;
    -- Master Bridge Ports
    -- System Signals
    M_AXI_ACLK                         : in  std_logic                                ;
    M_AXI_ARESETN                      : in  std_logic                                ;
    M_AXI_AWADDR                       : out std_logic_vector   (C_M_AXI_ADDR_WIDTH-1 downto 0)      ;
    M_AXI_AWPROT                       : out std_logic_vector   (3-1 downto 0)                       ;
    M_AXI_AWVALID                      : out std_logic                                               ;
    M_AXI_AWREADY                      : in  std_logic                                               ;
    M_AXI_WDATA                        : out std_logic_vector   (C_M_AXI_DATA_WIDTH-1 downto 0)      ;
    M_AXI_WSTRB                        : out std_logic_vector   (C_M_AXI_DATA_WIDTH/8-1 downto 0)    ;
    M_AXI_WVALID                       : out std_logic                                               ;
    M_AXI_WREADY                       : in  std_logic                                               ;
    M_AXI_BRESP                        : in  std_logic_vector   (2-1 downto 0)                       ;
    M_AXI_BVALID                       : in  std_logic                                               ;
    M_AXI_BREADY                       : out std_logic                                               ;
    M_AXI_ARADDR                       : out std_logic_vector   (C_M_AXI_ADDR_WIDTH-1 downto 0)      ;
    M_AXI_ARPROT                       : out std_logic_vector   (3-1 downto 0)                       ;
    M_AXI_ARVALID                      : out std_logic                                               ;
    M_AXI_ARREADY                      : in  std_logic                                               ;
    M_AXI_RDATA                        : in std_logic_vector   (C_M_AXI_DATA_WIDTH-1 downto 0)      ;
    M_AXI_RRESP                        : in std_logic_vector   (2-1 downto 0)                       ;
    M_AXI_RVALID                       : in std_logic                                               ;
    M_AXI_RREADY                       : out std_logic                                              ;
    -- Host Interface Signals for Host Processor
    inr_irqSync_irq                    : in std_logic;
    ins_irqOut_irq                     : out std_logic;
    coe_ExtSync_exsync                 : in std_logic;
    coe_NodeId_nodeid                  : in std_logic_vector(7 downto 0);
    coe_PlkLed_lederr                  : out std_logic;
    coe_PlkLed_ledst                   : out std_logic ;
    -- Parallel Host Interface
    coe_parHost_chipselect             : in std_logic;
    coe_parHost_read                   : in std_logic;
    coe_parHost_write                  : in std_logic;
    coe_parHost_addressLatchEnable     : in std_logic;
    coe_parHost_acknowledge            : out std_logic;
    coe_parHost_byteenable             : in std_logic_vector(gParallelDataWidth/8-1 downto 0);
    coe_parHost_address                : in std_logic_vector(15 downto 0);

    coe_parHost_data_I                 : in std_logic_vector(gParallelDataWidth-1 downto 0);
    coe_parHost_data_O                 : out std_logic_vector(gParallelDataWidth-1 downto 0);
    coe_parHost_data_T                 : out std_logic ;

    coe_parHost_addressData_I          : in std_logic_vector(gParallelDataWidth-1 downto 0);
    coe_parHost_addressData_O          : out std_logic_vector(gParallelDataWidth-1 downto 0);
    coe_parHost_addressData_T          : out std_logic
  );

  attribute MAX_FANOUT : string;
  attribute SIGIS : string;
  attribute MAX_FANOUT of S_AXI_PCP_ACLK       : signal is "10000";
  attribute MAX_FANOUT of S_AXI_PCP_ARESETN       : signal is "10000";
  attribute SIGIS of S_AXI_PCP_ACLK       : signal is "Clk";
  attribute SIGIS of S_AXI_PCP_ARESETN       : signal is "Rst";

  attribute MAX_FANOUT of S_AXI_HOST_ACLK       : signal is "10000";
  attribute MAX_FANOUT of S_AXI_HOST_ARESETN       : signal is "10000";
  attribute SIGIS of S_AXI_HOST_ACLK       : signal is "Clk";
  attribute SIGIS of S_AXI_HOST_ARESETN       : signal is "Rst";

  attribute MAX_FANOUT of M_AXI_ACLK       : signal is "10000";
  attribute MAX_FANOUT of M_AXI_ARESETN       : signal is "10000";
  attribute SIGIS of M_AXI_ACLK       : signal is "Clk";
  attribute SIGIS of M_AXI_ARESETN       : signal is "Rst";

end entity axi_hostinterface;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of axi_hostinterface is

    constant cBridgeUseMemBlock : natural := 1;

    --TODO: Export to outside
    signal S_AXI_PCP_AWPROT        :  std_logic_vector ( 2 downto 0)                   ;
    signal S_AXI_PCP_ARPROT        :  std_logic_vector (2 downto 0)                    ;
    signal S_AXI_HOST_AWPROT        :  std_logic_vector ( 2 downto 0)                   ;
    signal S_AXI_HOST_ARPROT        :  std_logic_vector (2 downto 0)                    ;

   --Signals for warapper to PCP Host Interface
    signal  AvsPcpAddress      :  std_logic_vector    (31 downto 0)   ;
    signal  AvsPcpByteenable   :  std_logic_vector    (3 downto 0)    ;
    signal  AvsPcpRead         :  std_logic  ;
    signal  AvsPcpWrite        :  std_logic  ;
    signal  AvsPcpWritedata    :  std_logic_vector   (31 downto 0);
    signal  AvsPcpReaddata     :  std_logic_vector   (31 downto 0);
    signal  AvsPcpWaitrequest  :  std_logic   ;

    -- Avalon Master Bridge signals to AXI master
    signal  avm_hostBridge_address          : std_logic_vector(31 downto 0);
    signal  avm_hostBridge_byteenable       : std_logic_vector(3 downto 0);
    signal  avm_hostBridge_read             : std_logic;
    signal  avm_hostBridge_readdata         : std_logic_vector(31 downto 0);
    signal  avm_hostBridge_write            : std_logic;
    signal  avm_hostBridge_writedata        : std_logic_vector(31 downto 0);
    signal  avm_hostBridge_waitrequest      : std_logic;

    -- Host Interface Internal Bus
    signal  AvsHostAddress      :  std_logic_vector    (31 downto 0)   ;
    signal  AvsHostByteenable   :  std_logic_vector    (3 downto 0)    ;
    signal  AvsHostRead         :  std_logic  ;
    signal  AvsHostWrite        :  std_logic  ;
    signal  AvsHostWritedata    :  std_logic_vector   (31 downto 0);
    signal  AvsHostReaddata     :  std_logic_vector   (31 downto 0);
    signal  AvsHostWaitrequest  :  std_logic   ;

    -- Internal Host signals
    signal host_address     : std_logic_vector(16 downto 2);
    signal host_byteenable  : std_logic_vector(3 downto 0);
    signal host_Read        : std_logic;
    signal host_readdata    : std_logic_vector(31 downto 0);
    signal host_write       : std_logic;
    signal host_writedata   : std_logic_vector(31 downto 0);
    signal host_waitrequest : std_logic;

    --TODO
    signal hostif_clock     : std_logic ;
    signal hostif_reset     : std_logic ;

begin

--! The host interface
--TODO: Prepare clock & reset for Host Interface IP
hostif_clock <= S_AXI_PCP_ACLK ;
hostif_reset <= S_AXI_PCP_ARESETN ;

theHostInterface: entity work.hostInterface
generic map
    (
    gVersionMajor          => gVersionMajor,
    gVersionMinor          => gVersionMinor,
    gVersionRevision       => gVersionRevision,
    gVersionCount          => gVersionCount,
    gBridgeUseMemBlock     => cBridgeUseMemBlock,
    gBaseDynBuf0           => gBaseDynBuf0,
    gBaseDynBuf1           => gBaseDynBuf1,
    gBaseErrCntr           => gBaseErrCntr,
    gBaseTxNmtQ            => gBaseTxNmtQ,
    gBaseTxGenQ            => gBaseTxGenQ,
    gBaseTxSynQ            => gBaseTxSynQ,
    gBaseTxVetQ            => gBaseTxVetQ,
    gBaseRxVetQ            => gBaseRxVetQ,
    gBaseK2UQ              => gBaseK2UQ,
    gBaseU2KQ              => gBaseU2KQ,
    gBaseTpdo              => gBaseTpdo,
    gBaseRpdo              => gBaseRpdo,
    gBaseRes               => gBaseRes
    )
port map
    (
    iClk                   => hostif_clock,
    iRst                   => hostif_reset,
    iHostAddress           => host_address,
    iHostByteenable        => host_byteenable,
    iHostRead              => host_Read,
    oHostReaddata          => host_readdata,
    iHostWrite             => host_write,
    iHostWritedata         => host_writedata,
    oHostWaitrequest       => host_waitrequest,
    iPcpAddress            => AvsPcpAddress (10 downto 2),
    iPcpByteenable         => AvsPcpByteenable,
    iPcpRead               => AvsPcpRead,
    oPcpReaddata           => AvsPcpReaddata,
    iPcpWrite              => AvsPcpWrite,
    iPcpWritedata          => AvsPcpWritedata,
    oPcpWaitrequest        => AvsPcpWaitrequest,
    oHostBridgeAddress     => avm_hostBridge_address(29 downto 0),           --TODO: Rename Ports
    oHostBridgeByteenable  => avm_hostBridge_byteenable,
    oHostBridgeRead        => avm_hostBridge_read,
    iHostBridgeReaddata    => avm_hostBridge_readdata,
    oHostBridgeWrite       => avm_hostBridge_write,
    oHostBridgeWritedata   => avm_hostBridge_writedata,
    iHostBridgeWaitrequest => avm_hostBridge_waitrequest,
    iIrqIntSync            => inr_irqSync_irq,
    iIrqExtSync            => coe_ExtSync_exsync,
    oIrq                   => ins_irqOut_irq,
    iNodeId                => coe_NodeId_nodeid,
    oPlkLedError           => coe_PlkLed_lederr,
    oPlkLedStatus          => coe_PlkLed_ledst
    );

AXI_LITE_SLAVE_PCP: entity work.axi_lite_slave_wrapper
generic map
    (
    C_BASEADDR         => C_BASEADDR,
    C_HIGHADDR         => C_HIGHADDR,
    C_S_AXI_ADDR_WIDTH => 32,
    C_S_AXI_DATA_WIDTH => 32
    )
port map
    (
    -- System Signals
    ACLK            =>	S_AXI_PCP_ACLK,
    ARESETN         =>	S_AXI_PCP_ARESETN,
    -- Slave Interface Write Address Ports
    S_AXI_AWADDR    =>	S_AXI_PCP_AWADDR,
    S_AXI_AWPROT    =>   S_AXI_PCP_AWPROT,
    S_AXI_AWVALID   =>	S_AXI_PCP_AWVALID,
    S_AXI_AWREADY   =>	S_AXI_PCP_AWREADY,
    -- Slave Interface Write Data Ports
    S_AXI_WDATA     =>	S_AXI_PCP_WDATA,
    S_AXI_WSTRB     =>	S_AXI_PCP_WSTRB,
    S_AXI_WVALID    =>	S_AXI_PCP_WVALID,
    S_AXI_WREADY    =>	S_AXI_PCP_WREADY,
    -- Slave Interface Write Response Ports
    S_AXI_BRESP     =>	S_AXI_PCP_BRESP,
    S_AXI_BVALID    =>	S_AXI_PCP_BVALID,
    S_AXI_BREADY    =>	S_AXI_PCP_BREADY,
    -- Slave Interface Read Address Ports
    S_AXI_ARADDR    =>	S_AXI_PCP_ARADDR,
    S_AXI_ARPROT    =>	S_AXI_PCP_ARPROT,
    S_AXI_ARVALID   =>	S_AXI_PCP_ARVALID,
    S_AXI_ARREADY   =>	S_AXI_PCP_ARREADY,
    -- Slave Interface Read Data Ports
    S_AXI_RDATA     =>	S_AXI_PCP_RDATA,
    S_AXI_RRESP     =>	S_AXI_PCP_RRESP,
    S_AXI_RVALID    =>	S_AXI_PCP_RVALID,
    S_AXI_RREADY    =>	S_AXI_PCP_RREADY,
    --Avalon Interface
    oAvsAddress     =>	AvsPcpAddress ,
    oAvsByteenable  =>	AvsPcpByteenable,
    oAvsRead        =>	AvsPcpRead,
    oAvsWrite       =>	AvsPcpWrite,
    oAvsWritedata   =>	AvsPcpWritedata,
    iAvsReaddata    =>	AvsPcpReaddata,
    iAvsWaitrequest =>	AvsPcpWaitrequest
    );

AXI_LITE_MASTER_BRIDGE: entity work.axi_lite_master_wrapper
generic map
    (
    C_M_AXI_ADDR_WIDTH =>   C_M_AXI_ADDR_WIDTH ,
    C_M_AXI_DATA_WIDTH =>   C_M_AXI_DATA_WIDTH
    )
port map
    (
    -- System Signals
    M_AXI_ACLK          =>  M_AXI_ACLK  ,
    M_AXI_ARESETN       =>  M_AXI_ARESETN ,

    -- Master Interface Write Address
    M_AXI_AWADDR        =>  M_AXI_AWADDR ,
    M_AXI_AWPROT        =>  M_AXI_AWPROT ,
    M_AXI_AWVALID       =>  M_AXI_AWVALID ,
    M_AXI_AWREADY       =>  M_AXI_AWREADY ,

    -- Master Interface Write Data
    M_AXI_WDATA         =>  M_AXI_WDATA ,
    M_AXI_WSTRB         =>  M_AXI_WSTRB ,
    M_AXI_WVALID        =>  M_AXI_WVALID ,
    M_AXI_WREADY        =>  M_AXI_WREADY ,
    -- Master Interface Write Response
    M_AXI_BRESP         =>  M_AXI_BRESP ,
    M_AXI_BVALID        =>  M_AXI_BVALID    ,
    M_AXI_BREADY        =>  M_AXI_BREADY ,
    -- Master Interface Read Address
    M_AXI_ARADDR        =>  M_AXI_ARADDR ,
    M_AXI_ARPROT        =>  M_AXI_ARPROT ,
    M_AXI_ARVALID       =>  M_AXI_ARVALID ,
    M_AXI_ARREADY       =>  M_AXI_ARREADY ,
    -- Master Interface Read Data
    M_AXI_RDATA         =>  M_AXI_RDATA ,
    M_AXI_RRESP         =>  M_AXI_RRESP ,
    M_AXI_RVALID        =>  M_AXI_RVALID ,
    M_AXI_RREADY        =>  M_AXI_RREADY ,

    iAvalonRead         =>  avm_hostBridge_read ,
    iAvalonWrite        =>  avm_hostBridge_write ,
    iAvalonAddr         =>  avm_hostBridge_address ,
    iAvalonBE           =>  avm_hostBridge_byteenable ,
    oAvalonWaitReq      =>  avm_hostBridge_waitrequest,
    oAvalonReadValid    =>  open ,
    oAvalonReadData     =>  avm_hostBridge_readdata ,
    iAvalonWriteData    =>  avm_hostBridge_writedata
    );

-- Host Interface IP Internal Bus
genAxiHost : if gHostIfType = 0 generate
begin

AXI_LITE_SLAVE_HOST: entity work.axi_lite_slave_wrapper
generic map
    (
    C_BASEADDR         => C_HOST_BASEADDR,
    C_HIGHADDR         => C_HOST_HIGHADDR,
    C_S_AXI_ADDR_WIDTH => 32,
    C_S_AXI_DATA_WIDTH => 32
    )
port map
    (
    -- System Signals
    ACLK            =>  S_AXI_HOST_ACLK,
    ARESETN         =>  S_AXI_HOST_ARESETN,
    -- Slave Interface Write Address Ports
    S_AXI_AWADDR    =>  S_AXI_HOST_AWADDR,
    S_AXI_AWPROT    =>  S_AXI_HOST_AWPROT,
    S_AXI_AWVALID   =>  S_AXI_HOST_AWVALID,
    S_AXI_AWREADY   =>  S_AXI_HOST_AWREADY,
    -- Slave Interface Write Data Ports
    S_AXI_WDATA     =>  S_AXI_HOST_WDATA,
    S_AXI_WSTRB     =>  S_AXI_HOST_WSTRB,
    S_AXI_WVALID    =>  S_AXI_HOST_WVALID,
    S_AXI_WREADY    =>  S_AXI_HOST_WREADY,
    -- Slave Interface Write Response Ports
    S_AXI_BRESP     =>  S_AXI_HOST_BRESP,
    S_AXI_BVALID    =>  S_AXI_HOST_BVALID,
    S_AXI_BREADY    =>  S_AXI_HOST_BREADY,
    -- Slave Interface Read Address Ports
    S_AXI_ARADDR    =>  S_AXI_HOST_ARADDR,
    S_AXI_ARPROT    =>  S_AXI_HOST_ARPROT,
    S_AXI_ARVALID   =>  S_AXI_HOST_ARVALID,
    S_AXI_ARREADY   =>  S_AXI_HOST_ARREADY,
    -- Slave Interface Read Data Ports
    S_AXI_RDATA     =>  S_AXI_HOST_RDATA,
    S_AXI_RRESP     =>  S_AXI_HOST_RRESP,
    S_AXI_RVALID    =>  S_AXI_HOST_RVALID,
    S_AXI_RREADY    =>  S_AXI_HOST_RREADY,
    --Avalon Interface
    oAvsAddress     =>  AvsHostAddress ,
    oAvsByteenable  =>  AvsHostByteenable,
    oAvsRead        =>  AvsHostRead,
    oAvsWrite       =>  AvsHostWrite,
    oAvsWritedata   =>  AvsHostWritedata,
    iAvsReaddata    =>  AvsHostReaddata,
    iAvsWaitrequest =>  AvsHostWaitrequest
    );

  host_address    <=  AvsHostAddress (16 downto 2) ; --TODO:Recheck width
  host_byteenable <=  AvsHostByteenable           ;
  host_Read       <=  AvsHostRead                 ;
  host_write      <=  AvsHostWrite                ;
  host_writedata  <=  AvsHostWritedata            ;
  AvsHostWaitrequest <= host_waitrequest          ;
  AvsHostReaddata <=  host_readdata               ;

end generate ;

-- Paralle Interface for Host Processor
genParallel : if gHostIfType = 1 generate
    signal hostData_i           : std_logic_vector(gParallelDataWidth-1 downto 0);
    signal hostData_o           : std_logic_vector(gParallelDataWidth-1 downto 0);
    signal hostData_en          : std_logic;
    signal hostAddressData_i    : std_logic_vector(gParallelDataWidth-1 downto 0);
    signal hostAddressData_o    : std_logic_vector(gParallelDataWidth-1 downto 0);
    signal hostAddressData_en   : std_logic;
begin
    theParallelInterface : entity work.parallelInterface
        generic map
        (
        gDataWidth => gParallelDataWidth,
        gMultiplex => gParallelMultiplex
        )
        port map
        (
        iParHostChipselect          => coe_parHost_chipselect,
        iParHostRead                => coe_parHost_read,
        iParHostWrite               => coe_parHost_write,
        iParHostAddressLatchEnable  => coe_parHost_addressLatchEnable,
        oParHostAcknowledge         => coe_parHost_acknowledge,
        iParHostByteenable          => coe_parHost_byteenable,
        iParHostAddress             => coe_parHost_address,
        oParHostData                => hostData_o,
        iParHostData                => hostData_i,
        oParHostDataEnable          => hostData_en,
        oParHostAddressData         => hostAddressData_o,
        iParHostAddressData         => hostAddressData_i,
        oParHostAddressDataEnable   => hostAddressData_en,
        iClk                        => hostif_clock, --TODO
        iRst                        => hostif_reset, --TODO
        oHostAddress                => host_address,
        oHostByteenable             => host_byteenable,
        oHostRead                   => host_Read,
        iHostReaddata               => host_readdata,
        oHostWrite                  => host_write,
        oHostWritedata              => host_writedata,
        iHostWaitrequest            => host_waitrequest
        );

        -- Added for Xilinx Design
        hostData_i <= coe_parHost_data_I ;
        coe_parHost_data_O <= hostData_o ;
        coe_parHost_data_T <= hostData_en ;
        -- Added for Xilinx Design
        hostAddressData_i <= coe_parHost_addressData_I ;
        coe_parHost_addressData_O <= hostAddressData_o ;
        coe_parHost_addressData_T <= hostAddressData_en ;

end generate;

end IMP;
