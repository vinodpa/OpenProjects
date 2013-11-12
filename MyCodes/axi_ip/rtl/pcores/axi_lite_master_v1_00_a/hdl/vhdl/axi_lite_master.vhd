-------------------------------------------------------------------------------
--
-- AXI4-Lite Master
--
-- VHDL-Standard:   VHDL'93
----------------------------------------------------------------------------
--
-- Structure:
--   axi_lite_master
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

--library unisim;
--use unisim.vcomponents.all;

entity axi_lite_master is
  generic(
    C_M_AXI_ADDR_WIDTH      : integer := 32;
    C_M_AXI_DATA_WIDTH      : integer := 32
    );
  port(
    -- System Signals
    M_AXI_ACLK    : in std_logic;
    M_AXI_ARESETN : in std_logic;

    -- Master Interface Write Address
    M_AXI_AWADDR  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    M_AXI_AWPROT  : out std_logic_vector(3-1 downto 0);
    M_AXI_AWVALID : out std_logic;
    M_AXI_AWREADY : in  std_logic;

    -- Master Interface Write Data
    M_AXI_WDATA  : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    M_AXI_WSTRB  : out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
    M_AXI_WVALID : out std_logic;
    M_AXI_WREADY : in  std_logic;

    -- Master Interface Write Response
    M_AXI_BRESP  : in  std_logic_vector(2-1 downto 0);
    M_AXI_BVALID : in  std_logic;
    M_AXI_BREADY : out std_logic;

    -- Master Interface Read Address

    M_AXI_ARADDR  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    M_AXI_ARPROT  : out std_logic_vector(3-1 downto 0);
    M_AXI_ARVALID : out std_logic;
    M_AXI_ARREADY : in  std_logic;

    -- Master Interface Read Data
    M_AXI_RDATA  : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    M_AXI_RRESP  : in  std_logic_vector(2-1 downto 0);
    M_AXI_RVALID : in  std_logic;
    M_AXI_RREADY : out std_logic;

    --test ports
    test_RValid : out std_logic;
    test_RReady : out std_logic;
    test_Arvalid : out std_logic;
    test_Arready: out std_logic;
    test_Bready: out std_logic;
    test_Bvalid : out std_logic;
    test_Wvalid : out std_logic;
    test_Wready : out std_logic;
    test_Awvalid : out std_logic;
    test_Awready : out std_logic;
    test_wait : out std_logic;
    test_read : out std_logic;
    test_write : out std_logic;
    test_awaddr : out std_logic_vector (31 downto 0);
    test_wdata  : out std_logic_vector (31 downto 0);
    test_araddr : out std_logic_vector (31 downto 0);
    test_rdata  : out std_logic_vector (31 downto 0);
    test_avm_state : out std_logic_vector (1 downto 0);
    read_write : in std_logic
    );

end axi_lite_master;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_lite_master is

signal avalonRead  : std_logic;
signal avalonWrite : std_logic;
signal avalonAddr  : std_logic_vector (31 downto 0);
signal avalonBE    : std_logic_vector (3 downto 0);
signal avalonBeginTransfer : std_logic;
signal avalonWaitReq   : std_logic;
signal avalonReadValid : std_logic;
signal avalonReadData  : std_logic_vector (31 downto 0);
signal avalonWriteData : std_logic_vector (31 downto 0);

signal sRready		: std_logic;
signal sArvalid	: std_logic;
signal sBready		: std_logic;
signal sWvalid		: std_logic;
signal sAwvalid	: std_logic;
signal sAwaddr		: std_logic_vector (31 downto 0);
signal sWdata		: std_logic_vector (31 downto 0);
signal sAraddr		: std_logic_vector (31 downto 0);



begin

	M_AXI_RREADY  	<=		sRready	;
	M_AXI_ARVALID	<= 	sArvalid	;
	M_AXI_BREADY	<= 	sBready	;
	M_AXI_WVALID	<= 	sWvalid	;
	M_AXI_AWVALID	<=		sAwvalid	;
	M_AXI_AWADDR	<=		sAwaddr	;
	M_AXI_WDATA		<=		sWdata	;
	M_AXI_ARADDR	<=		sAraddr	;

    test_RValid  <=   M_AXI_RVALID    ;
    test_RReady  <=   sRready    ;
    test_Arvalid <=   sArvalid   ;
    test_Arready <=   M_AXI_ARREADY   ;
    test_Bready  <=   M_AXI_BVALID    ;
    test_Bvalid  <=   sBready    ;
    test_Wvalid  <=   sWvalid    ;
    test_Wready  <=   M_AXI_WREADY    ;
    test_Awvalid <=   sAwvalid   ;
    test_Awready <=   M_AXI_AWREADY   ;
    test_wait    <=   avalonWaitReq   ;
    test_read    <=   avalonRead      ;
    test_write   <=   avalonWrite     ;
    test_awaddr  <=   sAwaddr    ;
    test_wdata   <=   sWdata     ;
    test_araddr  <=   sAraddr    ;
    test_rdata   <=   M_AXI_RDATA     ;

WRAPPER: entity work.axi_lite_master_wrapper
    generic map
       (
        C_M_AXI_ADDR_WIDTH => C_M_AXI_ADDR_WIDTH,
        C_M_AXI_DATA_WIDTH => C_M_AXI_DATA_WIDTH
        )
   port map
       (
        -- System Signals
        M_AXI_ACLK         => M_AXI_ACLK,
        M_AXI_ARESETN      => M_AXI_ARESETN,
        -- Master Interface Write Address
        M_AXI_AWADDR       => sAwaddr,
        M_AXI_AWPROT       => M_AXI_AWPROT,
        M_AXI_AWVALID      => sAwvalid,
        M_AXI_AWREADY      => M_AXI_AWREADY,
        -- Master Interface Write Data
        M_AXI_WDATA        => sWdata,
        M_AXI_WSTRB        => M_AXI_WSTRB,
        M_AXI_WVALID       => sWvalid,
        M_AXI_WREADY       => M_AXI_WREADY,
        -- Master Interface Write Response
        M_AXI_BRESP        => M_AXI_BRESP,
        M_AXI_BVALID       => M_AXI_BVALID,
        M_AXI_BREADY       => sBready,
        -- Master Interface Read Address
        M_AXI_ARADDR       => sAraddr,
        M_AXI_ARPROT       => M_AXI_ARPROT,
        M_AXI_ARVALID      => sArvalid,
        M_AXI_ARREADY      => M_AXI_ARREADY,
        -- Master Interface Read Data
        M_AXI_RDATA        => M_AXI_RDATA,
        M_AXI_RRESP        => M_AXI_RRESP,
        M_AXI_RVALID       => M_AXI_RVALID,
        M_AXI_RREADY       => sRready,
        -- Avalon Interface
        iAvalonRead         => avalonRead,
        iAvalonWrite        => avalonWrite,
        iAvalonAddr         => avalonAddr,
        iAvalonBE           => avalonBE,
        oAvalonWaitReq      => avalonWaitReq, --TODO: Check this part
        oAvalonReadValid    => avalonReadValid,
        oAvalonReadData     => avalonReadData,
        iAvalonWriteData    => avalonWriteData
       );

--Avalon Bus master Interface
AVALON_MASTER: entity work.avalon_master
    generic map
    (
        ADDR_WIDTH  => 32,
        WIDTH_WIDTH => 32,
--        READ_WRITE_ADDR => 3338665984,
        NO_READ_WRITE  => 16
    )
    port map
    (
        iClk    =>  M_AXI_ACLK,
        iResetn =>  M_AXI_ARESETN,
        avalonRead =>   avalonRead,
        avalonWrite =>  avalonWrite,
        avalonAddr  =>  avalonAddr,
        avalonBE    =>  avalonBE,
        avalonBeginTransfer =>  avalonBeginTransfer,
        avalonWaitReq =>    avalonWaitReq,
        avalonReadValid =>  avalonReadValid,
        avalonReadData => avalonReadData,
        avalonWriteData =>  avalonWriteData,
        test_avm_state  => test_avm_state,
        read_write      => read_write
     );

end implementation;
