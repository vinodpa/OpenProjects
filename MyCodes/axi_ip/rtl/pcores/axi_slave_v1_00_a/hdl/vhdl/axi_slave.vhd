-----------------------------------------------------------------------------
--
-- AXI Slave
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

--library unisim;
--use unisim.vcomponents.all;

entity axi_slave is
  generic (
    C_S_AXI_ID_WIDTH     : integer := 1;
    C_S_AXI_ADDR_WIDTH   : integer := 32;
    C_S_AXI_DATA_WIDTH   : integer := 32;
    C_S_AXI_AWUSER_WIDTH : integer := 1;
    C_S_AXI_ARUSER_WIDTH : integer := 1;
    C_S_AXI_WUSER_WIDTH  : integer := 1;
    C_S_AXI_RUSER_WIDTH  : integer := 1;
    C_S_AXI_BUSER_WIDTH  : integer := 1
    );
  port(
    -- System Signals
    ACLK    : in std_logic;
    ARESETN : in std_logic;

    -- Slave Interface Write Address Ports
    S_AXI_AWID     : in  std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
    S_AXI_AWADDR   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWLEN    : in  std_logic_vector(8-1 downto 0);
    S_AXI_AWSIZE   : in  std_logic_vector(3-1 downto 0);
    S_AXI_AWBURST  : in  std_logic_vector(2-1 downto 0);
    S_AXI_AWLOCK   : in  std_logic_vector(2-1 downto 0);
    S_AXI_AWCACHE  : in  std_logic_vector(4-1 downto 0);
    S_AXI_AWPROT   : in  std_logic_vector(3-1 downto 0);
    S_AXI_AWREGION : in  std_logic_vector(4-1 downto 0);
    S_AXI_AWQOS    : in  std_logic_vector(4-1 downto 0);
    S_AXI_AWUSER   : in  std_logic_vector(C_S_AXI_AWUSER_WIDTH-1 downto 0);
    S_AXI_AWVALID  : in  std_logic;
    S_AXI_AWREADY  : out std_logic;

    -- Slave Interface Write Data Ports
    S_AXI_WID    : in  std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
    S_AXI_WDATA  : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB  : in  std_logic_vector(C_S_AXI_DATA_WIDTH/8-1 downto 0);
    S_AXI_WLAST  : in  std_logic;
    S_AXI_WUSER  : in  std_logic_vector(C_S_AXI_WUSER_WIDTH-1 downto 0);
    S_AXI_WVALID : in  std_logic;
    S_AXI_WREADY : out std_logic;

    -- Slave Interface Write Response Ports
    S_AXI_BID    : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
    S_AXI_BRESP  : out std_logic_vector(2-1 downto 0);
    S_AXI_BUSER  : out std_logic_vector(C_S_AXI_BUSER_WIDTH-1 downto 0);
    S_AXI_BVALID : out std_logic;
    S_AXI_BREADY : in  std_logic;

    -- Slave Interface Read Address Ports
    S_AXI_ARID     : in  std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
    S_AXI_ARADDR   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARLEN    : in  std_logic_vector(8-1 downto 0);
    S_AXI_ARSIZE   : in  std_logic_vector(3-1 downto 0);
    S_AXI_ARBURST  : in  std_logic_vector(2-1 downto 0);
    S_AXI_ARLOCK   : in  std_logic_vector(2-1 downto 0);
    S_AXI_ARCACHE  : in  std_logic_vector(4-1 downto 0);
    S_AXI_ARPROT   : in  std_logic_vector(3-1 downto 0);
    S_AXI_ARREGION : in  std_logic_vector(4-1 downto 0);
    S_AXI_ARQOS    : in  std_logic_vector(4-1 downto 0);
    S_AXI_ARUSER   : in  std_logic_vector(C_S_AXI_ARUSER_WIDTH-1 downto 0);
    S_AXI_ARVALID  : in  std_logic;
    S_AXI_ARREADY  : out std_logic;

    -- Slave Interface Read Data Ports
    S_AXI_RID    : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
    S_AXI_RDATA  : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP  : out std_logic_vector(2-1 downto 0);
    S_AXI_RLAST  : out std_logic;
    S_AXI_RUSER  : out std_logic_vector(C_S_AXI_RUSER_WIDTH-1 downto 0);
    S_AXI_RVALID : out std_logic;
    S_AXI_RREADY : in  std_logic
    );

end axi_slave;

architecture implementation of axi_slave is
begin

end implementation;
