-------------------------------------------------------------------------------
--
-- AXI Master
--
-- VHDL-Standard:   VHDL'93
----------------------------------------------------------------------------
--
-- Structure:
--   axi_master
--
----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

--library unisim;
--use unisim.vcomponents.all;

entity axi_master is
  generic(
    C_M_AXI_THREAD_ID_WIDTH : integer := 1;
    C_M_AXI_ADDR_WIDTH      : integer := 32;
    C_M_AXI_DATA_WIDTH      : integer := 32;
    C_M_AXI_AWUSER_WIDTH    : integer := 1;
    C_M_AXI_ARUSER_WIDTH    : integer := 1;
    C_M_AXI_WUSER_WIDTH     : integer := 1;
    C_M_AXI_RUSER_WIDTH     : integer := 1;
    C_M_AXI_BUSER_WIDTH     : integer := 1
    );
  port(
    -- System Signals
    ACLK    : in std_logic;
    ARESETN : in std_logic;

    -- Master Interface Write Address
    M_AXI_AWID    : out std_logic_vector(C_M_AXI_THREAD_ID_WIDTH-1 downto 0);
    M_AXI_AWADDR  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    M_AXI_AWLEN   : out std_logic_vector(8-1 downto 0);
    M_AXI_AWSIZE  : out std_logic_vector(3-1 downto 0);
    M_AXI_AWBURST : out std_logic_vector(2-1 downto 0);
    M_AXI_AWLOCK  : out std_logic;
    M_AXI_AWCACHE : out std_logic_vector(4-1 downto 0);
    M_AXI_AWPROT  : out std_logic_vector(3-1 downto 0);
    -- AXI3    M_AXI_AWREGION:out std_logic_vector(4-1 downto 0);
    M_AXI_AWQOS   : out std_logic_vector(4-1 downto 0);
    M_AXI_AWUSER  : out std_logic_vector(C_M_AXI_AWUSER_WIDTH-1 downto 0);
    M_AXI_AWVALID : out std_logic;
    M_AXI_AWREADY : in  std_logic;

    -- Master Interface Write Data
    -- AXI3   M_AXI_WID(C_M_AXI_THREAD_ID_WIDTH-1 downto 0);
    M_AXI_WDATA  : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    M_AXI_WSTRB  : out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
    M_AXI_WLAST  : out std_logic;
    M_AXI_WUSER  : out std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0);
    M_AXI_WVALID : out std_logic;
    M_AXI_WREADY : in  std_logic;

    -- Master Interface Write Response
    M_AXI_BID    : in  std_logic_vector(C_M_AXI_THREAD_ID_WIDTH-1 downto 0);
    M_AXI_BRESP  : in  std_logic_vector(2-1 downto 0);
    M_AXI_BUSER  : in  std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0);
    M_AXI_BVALID : in  std_logic;
    M_AXI_BREADY : out std_logic;

    -- Master Interface Read Address
    M_AXI_ARID    : out std_logic_vector(C_M_AXI_THREAD_ID_WIDTH-1 downto 0);
    M_AXI_ARADDR  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    M_AXI_ARLEN   : out std_logic_vector(8-1 downto 0);
    M_AXI_ARSIZE  : out std_logic_vector(3-1 downto 0);
    M_AXI_ARBURST : out std_logic_vector(2-1 downto 0);
    M_AXI_ARLOCK  : out std_logic_vector(2-1 downto 0);
    M_AXI_ARCACHE : out std_logic_vector(4-1 downto 0);
    M_AXI_ARPROT  : out std_logic_vector(3-1 downto 0);
    -- AXI3   M_AXI_ARREGION:out std_logic_vector(4-1 downto 0);
    M_AXI_ARQOS   : out std_logic_vector(4-1 downto 0);
    M_AXI_ARUSER  : out std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0);
    M_AXI_ARVALID : out std_logic;
    M_AXI_ARREADY : in  std_logic;

    -- Master Interface Read Data 
    M_AXI_RID    : in  std_logic_vector(C_M_AXI_THREAD_ID_WIDTH-1 downto 0);
    M_AXI_RDATA  : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    M_AXI_RRESP  : in  std_logic_vector(2-1 downto 0);
    M_AXI_RLAST  : in  std_logic;
    M_AXI_RUSER  : in  std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0);
    M_AXI_RVALID : in  std_logic;
    M_AXI_RREADY : out std_logic;

    -- Example Design only
    error : out std_logic
    );

end axi_master;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_master is
begin
end implementation;
