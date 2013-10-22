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
    M_AXI_RREADY : out std_logic

    );

end axi_lite_master;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_lite_master is
begin
end implementation;
