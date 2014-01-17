-------------------------------------------------------------------------------
--! @file axi_hostinterface.vhd
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
-- -- Version History
-------------------------------------------------------------------------------
-- 2014-01-13   Vinod PA    initial Draft for Top file
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.global.all;


entity axi_hostinterface is
    generic (
        --! PCP AXI Slave Data Width
        C_S_AXI_DATA_WIDTH          : integer               := 32;
        --! PCP AXI Slave Address width
        C_S_AXI_ADDR_WIDTH          : integer               := 32;
        --! PCP AXI Min Address range size (64Kb limited by scripts)
        C_S_AXI_MIN_SIZE            : std_logic_vector      := X"0001FFFF";
        --! PCP AXI Slave Base Address
        C_BASEADDR                  : std_logic_vector      := X"FFFFFFFF";
        --! PCP AXI Slave High Address
        C_HIGHADDR                  : std_logic_vector      := X"00000000";
        --! PCP AXI IP Family
        C_FAMILY                    : string                := "virtex6";
        --! Host AXI Slave Data Width
        C_S_HOST_AXI_DATA_WIDTH     : integer               := 32;
        --! Host AXI Address Width
        C_S_HOST_AXI_ADDR_WIDTH     : integer               := 32;
        --! HOST AXI Min Address range size
        C_S_HOST_AXI_MIN_SIZE       : std_logic_vector      := X"0001FFFF";
        --! HOST AXI Slave Base Address
        C_HOST_BASEADDR             : std_logic_vector      := X"FFFFFFFF";
        --! HOST AXI Slave High Address
        C_HOST_HIGHADDR             : std_logic_vector      := X"00000000";
        --! HOST AXI IP Family
        C_HOST_FAMILY               : string                := "virtex6";
        --!Master Bridge Address Width
        C_M_AXI_ADDR_WIDTH          : integer               := 32;
        --!Master Bridge Data Widtg Width
        C_M_AXI_DATA_WIDTH          : integer               := 32;
        --! Host Interface Version major
        gVersionMajor               : natural               := 16#FF#;
        --! Host Interface Version minor
        gVersionMinor               : natural               := 16#FF#;
        --! Host Interface Version revision
        gVersionRevision            : natural               := 16#FF#;
        --! Host Interface Version count
        gVersionCount               : natural               := 0;
        --! Host Interface Base address Dynamic Buffer 0
        gBaseDynBuf0                : natural               := 16#00800#;
        --! Host Interface Base address Dynamic Buffer 1
        gBaseDynBuf1                : natural               := 16#01000#;
        --! Host Interface Base address Error Counter
        gBaseErrCntr                : natural               := 16#01800#;
        --! Host Interface Base address TX NMT Queue
        gBaseTxNmtQ                 : natural               := 16#02800#;
        --! Host Interface Base address TX Generic Queue
        gBaseTxGenQ                 : natural               := 16#03800#;
        --! Host Interface Base address TX SyncRequest Queue
        gBaseTxSynQ                 : natural               := 16#04800#;
        --! Host Interface Base address TX Virtual Ethernet Queue
        gBaseTxVetQ                 : natural               := 16#05800#;
        --! Host Interface Base address RX Virtual Ethernet Queue
        gBaseRxVetQ                 : natural               := 16#06800#;
        --! Host Interface Base address Kernel-to-User Queue
        gBaseK2UQ                   : natural               := 16#07000#;
        --! Host Interface Base address User-to-Kernel Queue
        gBaseU2KQ                   : natural               := 16#09000#;
        --! Host Interface Base address Tpdo
        gBaseTpdo                   : natural               := 16#0B000#;
        --! Host Interface Base address Rpdo
        gBaseRpdo                   : natural               := 16#0E000#;
        --! Host Interface Base address Reserved (-1 = high address of Rpdo)
        gBaseRes                    : natural               := 16#14000#;
        --! Select Host Interface Type (0 = Avalon, 1 = Parallel)
        gHostIfType                 : natural               := 0;
        --! Data width of parallel interface (16/32)
        gParallelDataWidth          : natural               := 16;
        --! Address and Data bus are multiplexed (0 = FALSE, otherwise = TRUE)
        gParallelMultiplex          : natural               := 0
    );
    port (
        --! AXI PCP slave PCP clock
        S_AXI_PCP_ACLK              : in    std_logic;
        --! AXI PCP slave PCP Reset Active low
        S_AXI_PCP_ARESETN           : in    std_logic;
        --! AXI PCP slave PCP Address
        S_AXI_PCP_AWADDR            : in    std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        --! AXI PCP slave PCP Address Valid
        S_AXI_PCP_AWVALID           : in    std_logic;
        --! AXI PCP slave Write Data
        S_AXI_PCP_WDATA             : in    std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        --! AXI PCP slave Write Strobe
        S_AXI_PCP_WSTRB             : in    std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        --! AXI PCP slave Write Valid
        S_AXI_PCP_WVALID            : in    std_logic;
        --! AXI PCP slave Write Response Ready
        S_AXI_PCP_BREADY            : in    std_logic;
        --! AXI PCP slave Write Response Valid
        S_AXI_PCP_BVALID            : out   std_logic;
        --! AXI PCP slave Write Response
        S_AXI_PCP_BRESP             : out   std_logic_vector(1 downto 0);
        --! AXI PCP slave Read Address
        S_AXI_PCP_ARADDR            : in    std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        --! AXI PCP slave Address Valid
        S_AXI_PCP_ARVALID           : in    std_logic;
        --! AXI PCP slave Read Ready
        S_AXI_PCP_RREADY            : in    std_logic;
        --! AXI PCP slave Read Address Ready
        S_AXI_PCP_ARREADY           : out   std_logic;
        --! AXI PCP slave Read Data
        S_AXI_PCP_RDATA             : out   std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        --! AXI PCP slave Read Response
        S_AXI_PCP_RRESP             : out   std_logic_vector(1 downto 0);
        --! AXI PCP slave Read Valid
        S_AXI_PCP_RVALID            : out   std_logic;
        --! AXI PCP slave Write ready
        S_AXI_PCP_WREADY            : out   std_logic;
        --! AXI PCP slave Write Address Ready
        S_AXI_PCP_AWREADY           : out   std_logic;
        -- Host Interface AXI
        --! AXI Host Slave Clock
        S_AXI_HOST_ACLK             : in    std_logic;
        --! AXI Host Slave Reset active low
        S_AXI_HOST_ARESETN          : in    std_logic;
        --! AXI Host Slave Write Address
        S_AXI_HOST_AWADDR           : in    std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        --! AXI Host Slave Write Address valid
        S_AXI_HOST_AWVALID          : in    std_logic;
        --! AXI Host Slave Write Data
        S_AXI_HOST_WDATA            : in    std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        --! AXI Host Slave Write strobe
        S_AXI_HOST_WSTRB            : in    std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        --! AXI Host Slave write Valid
        S_AXI_HOST_WVALID           : in    std_logic;
        --! AXI Host Slave Response Ready
        S_AXI_HOST_BREADY           : in    std_logic;
        --! AXI Host Slave Read Address
        S_AXI_HOST_ARADDR           : in    std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        --! AXI Host Slave Read Address Valid
        S_AXI_HOST_ARVALID          : in    std_logic;
        --! AXI Host Slave Read Ready
        S_AXI_HOST_RREADY           : in    std_logic;
        --! AXI Host Slave Read Address Ready
        S_AXI_HOST_ARREADY          : out   std_logic;
        --! AXI Host SlaveRead Data
        S_AXI_HOST_RDATA            : out   std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        --! AXI Host Slave Read Response
        S_AXI_HOST_RRESP            : out   std_logic_vector(1 downto 0);
        --! AXI Host Slave Read Valid
        S_AXI_HOST_RVALID           : out   std_logic;
        --! AXI Host Slave Write Ready
        S_AXI_HOST_WREADY           : out   std_logic;
        --! AXI Host Slave Write Response
        S_AXI_HOST_BRESP            : out   std_logic_vector(1 downto 0);
        --! AXI Host Slave Write Response Valid
        S_AXI_HOST_BVALID           : out   std_logic;
        --! AXI Host Slave Write Address Ready
        S_AXI_HOST_AWREADY          : out   std_logic;
        -- Master Bridge Ports
        --! AXI Bridge Master Clock
        M_AXI_ACLK                  : in    std_logic;
        --! AXI Bridge Master Reset Active low
        M_AXI_ARESETN               : in    std_logic;
        --! AXI Bridge Master Write Address
        M_AXI_AWADDR                : out   std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
        --! AXI Bridge Master Write Address Write protection
        M_AXI_AWPROT                : out   std_logic_vector(2 downto 0);
        --! AXI Bridge Master Write Address Valid
        M_AXI_AWVALID               : out   std_logic;
        --! AXI Bridge Master Write Ready
        M_AXI_AWREADY               : in    std_logic;
        --! AXI Bridge Master Write Data
        M_AXI_WDATA                 : out   std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
        --! AXI Bridge Master Write Strobe
        M_AXI_WSTRB                 : out   std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
        --! AXI Bridge Master Write Valid
        M_AXI_WVALID                : out   std_logic;
        --! AXI Bridge Master Write Last to support AXI4 feature
        M_AXI_WLAST                 : out   std_logic;
        --! AXI Bridge Master Write Ready
        M_AXI_WREADY                : in    std_logic;
        --! AXI Bridge Master Response
        M_AXI_BRESP                 : in    std_logic_vector(1 downto 0);
        --! AXI Bridge Master Response Valid
        M_AXI_BVALID                : in    std_logic;
        --! AXI Bridge Master Response Ready
        M_AXI_BREADY                : out   std_logic;
        --! AXI Bridge Master Read Address
        M_AXI_ARADDR                : out   std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
        --! AXI Bridge Master Read Protection
        M_AXI_ARPROT                : out   std_logic_vector(2 downto 0);
        --! AXI Bridge Master Read Address Valid
        M_AXI_ARVALID               : out   std_logic;
        --! AXI Bridge Master Read Addrss Ready
        M_AXI_ARREADY               : in    std_logic;
        --! AXI Bridge Master Read Data
        M_AXI_RDATA                 : in    std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
        --! AXI Bridge Master Read Response
        M_AXI_RRESP                 : in    std_logic_vector(1 downto 0);
        --! AXI Bridge Master Read Valid
        M_AXI_RVALID                : in    std_logic;
        --! AXI Bridge Master Read Ready
        M_AXI_RREADY                : out   std_logic;
        -- Misc ports
        --! Interrupt receiver
        irqSync_irq                 : in    std_logic;
        --! Interrupt sender
        irqOut_irq                  : out   std_logic;
        --! External Sync Source
        iExtSync_exsync             : in    std_logic;
        --! Node Id
        iNodeId_nodeid              : in    std_logic_vector(7 downto 0);
        --! POWERLINK Error LED
        oPlkLed_lederr              : out   std_logic;
        --! POWERLINK Status LED
        oPlkLed_ledst               : out   std_logic;
        -- Parallel Host Interface
        --! Chipselect
        iParHost_chipselect         : in    std_logic;
        --! Read Signal
        iParHost_read               : in    std_logic;
        --! Write Signal
        iParHost_write              : in    std_logic;
        --! Address Latch enable (Multiplexed only)
        iParHost_addressLatchEnable : in    std_logic;
        --! High active Acknowledge
        oParHost_acknowledge        : out   std_logic;
        --! Byteenables
        iParHost_byteenable         : in    std_logic_vector(gParallelDataWidth/8-1 downto 0);
        --! Address bus (Demultiplexed, word-address)
        iParHost_address            : in    std_logic_vector(15 downto 0);
        -- Data bus IO
        --! Data bus input (Demultiplexed)
        iParHost_data_io            : in    std_logic_vector(gParallelDataWidth-1 downto 0);
        --! Data bus output (Demultiplexed)
        oParHost_data_io            : out   std_logic_vector(gParallelDataWidth-1 downto 0);
        --! Data bus tristate enable (Demultiplexed)
        oParHost_data_io_tri        : out   std_logic;
        -- Address/data bus IO
        --! Address/Data bus input (Multiplexed, word-address))
        iParHost_addressData_io     : in    std_logic_vector(gParallelDataWidth-1 downto 0);
        --! Address/Data bus output (Multiplexed, word-address))
        oParHost_addressData_io     : out   std_logic_vector(gParallelDataWidth-1 downto 0);
        --! Address/Data bus tristate Enable(Multiplexed, word-address))
        oParHost_addressData_tri    : out   std_logic
    );

    --! Declare Maximum Fan out attribute
    attribute MAX_FANOUT : string;
    --! Declare Class of special signals
    attribute SIGIS      : string;
    --! Maximum fan out for PCP clock
    attribute MAX_FANOUT of S_AXI_PCP_ACLK     : signal is "10000";
    --! Maximum fan out for PCP Reset
    attribute MAX_FANOUT of S_AXI_PCP_ARESETN  : signal is "10000";
    --! PCP clock is declared under clock group
    attribute SIGIS of S_AXI_PCP_ACLK          : signal is "Clk"  ;
    --! PCP Reset is declared under Reset group
    attribute SIGIS of S_AXI_PCP_ARESETN       : signal is "Rst"  ;
    --! Maximum fan out for Host clock
    attribute MAX_FANOUT of S_AXI_HOST_ACLK    : signal is "10000";
    --! Maximum fan out for Host Reset
    attribute MAX_FANOUT of S_AXI_HOST_ARESETN : signal is "10000";
    --! Host clock is declared under clock group
    attribute SIGIS of S_AXI_HOST_ACLK         : signal is "Clk"  ;
    --! Host Reset is declared under Reset group
    attribute SIGIS of S_AXI_HOST_ARESETN      : signal is "Rst"  ;
    --! Maximum fan out for Bridge clock
    attribute MAX_FANOUT of M_AXI_ACLK         : signal is "10000";
    --! Maximum fan out for Bridge Reset
    attribute MAX_FANOUT of M_AXI_ARESETN      : signal is "10000";
    --! Bridge clock is declared under clock group
    attribute SIGIS of M_AXI_ACLK              : signal is "Clk"  ;
    --! Bridge Reset is declared under Reset group
    attribute SIGIS of M_AXI_ARESETN           : signal is "Rst"  ;
end entity axi_hostinterface;

-------------------------------------------------------------------------------
-- Architecture section
-------------------------------------------------------------------------------

architecture rtl of axi_hostinterface is
    constant cBridgeUseMemBlock : natural := cTrue;

    signal S_AXI_PCP_AWPROT     :  std_logic_vector(2 downto 0);
    signal S_AXI_PCP_ARPROT     :  std_logic_vector(2 downto 0);
    signal S_AXI_HOST_AWPROT    :  std_logic_vector(2 downto 0);
    signal S_AXI_HOST_ARPROT    :  std_logic_vector(2 downto 0);

    --Signals for warapper to PCP Host Interface
    signal  AvsPcpAddress      :  std_logic_vector(31 downto 0);
    signal  AvsPcpByteenable   :  std_logic_vector(3 downto 0);
    signal  AvsPcpRead         :  std_logic;
    signal  AvsPcpWrite        :  std_logic;
    signal  AvsPcpWritedata    :  std_logic_vector(31 downto 0);
    signal  AvsPcpReaddata     :  std_logic_vector(31 downto 0);
    signal  AvsPcpWaitrequest  :  std_logic;

    -- Avalon Master Bridge signals to AXI master
    signal  avm_hostBridge_address          : std_logic_vector(29 downto 0);
    signal  avm_hostBridge_byteenable       : std_logic_vector(3 downto 0);
    signal  avm_hostBridge_read             : std_logic;
    signal  avm_hostBridge_readdata         : std_logic_vector(31 downto 0);
    signal  avm_hostBridge_write            : std_logic;
    signal  avm_hostBridge_writedata        : std_logic_vector(31 downto 0);
    signal  avm_hostBridge_waitrequest      : std_logic;

    -- Host Interface Internal Bus
    signal  AvsHostAddress      :  std_logic_vector(31 downto 0);
    signal  AvsHostByteenable   :  std_logic_vector(3 downto 0);
    signal  AvsHostRead         :  std_logic;
    signal  AvsHostWrite        :  std_logic;
    signal  AvsHostWritedata    :  std_logic_vector(31 downto 0);
    signal  AvsHostReaddata     :  std_logic_vector(31 downto 0);
    signal  AvsHostWaitrequest  :  std_logic;

    -- Internal Host signals
    signal  host_address        : std_logic_vector(16 downto 2);
    signal  host_byteenable     : std_logic_vector(3 downto 0);
    signal  host_Read           : std_logic;
    signal  host_readdata       : std_logic_vector(31 downto 0);
    signal  host_write          : std_logic;
    signal  host_writedata      : std_logic_vector(31 downto 0);
    signal  host_waitrequest    : std_logic;

    signal  hostif_clock        : std_logic;
    signal  hostif_reset        : std_logic;

    signal AxiLiteBridgeAddress : std_logic_vector(31 downto 0);
begin
    --TODO: Prepare clock & reset for Host Interface IP
    --      Cross check the possibility to use different clocks
    hostif_clock <= S_AXI_PCP_ACLK;
    hostif_reset <= not S_AXI_PCP_ARESETN;

    -------------------------------------------------------------------------------
    --  Host Interface IP
    -------------------------------------------------------------------------------
    --! The host interface IP
    theHostInterface: entity work.hostInterface
    generic map (
        gVersionMajor           => gVersionMajor,
        gVersionMinor           => gVersionMinor,
        gVersionRevision        => gVersionRevision,
        gVersionCount           => gVersionCount,
        gBridgeUseMemBlock      => cBridgeUseMemBlock,
        gBaseDynBuf0            => gBaseDynBuf0,
        gBaseDynBuf1            => gBaseDynBuf1,
        gBaseErrCntr            => gBaseErrCntr,
        gBaseTxNmtQ             => gBaseTxNmtQ,
        gBaseTxGenQ             => gBaseTxGenQ,
        gBaseTxSynQ             => gBaseTxSynQ,
        gBaseTxVetQ             => gBaseTxVetQ,
        gBaseRxVetQ             => gBaseRxVetQ,
        gBaseK2UQ               => gBaseK2UQ,
        gBaseU2KQ               => gBaseU2KQ,
        gBaseTpdo               => gBaseTpdo,
        gBaseRpdo               => gBaseRpdo,
        gBaseRes                => gBaseRes
    )
    port map (
        iClk                    => hostif_clock,
        iRst                    => hostif_reset,
        iHostAddress            => host_address,
        iHostByteenable         => host_byteenable,
        iHostRead               => host_Read,
        oHostReaddata           => host_readdata,
        iHostWrite              => host_write,
        iHostWritedata          => host_writedata,
        oHostWaitrequest        => host_waitrequest,
        iPcpAddress             => AvsPcpAddress(10 downto 2),
        iPcpByteenable          => AvsPcpByteenable,
        iPcpRead                => AvsPcpRead,
        oPcpReaddata            => AvsPcpReaddata,
        iPcpWrite               => AvsPcpWrite,
        iPcpWritedata           => AvsPcpWritedata,
        oPcpWaitrequest         => AvsPcpWaitrequest,
        oHostBridgeAddress      => avm_hostBridge_address,
        oHostBridgeByteenable   => avm_hostBridge_byteenable,
        oHostBridgeRead         => avm_hostBridge_read,
        iHostBridgeReaddata     => avm_hostBridge_readdata,
        oHostBridgeWrite        => avm_hostBridge_write,
        oHostBridgeWritedata    => avm_hostBridge_writedata,
        iHostBridgeWaitrequest  => avm_hostBridge_waitrequest,
        iIrqIntSync             => irqSync_irq,
        iIrqExtSync             => iExtSync_exsync,
        oIrq                    => irqOut_irq,
        iNodeId                 => iNodeId_nodeid,
        oPlkLedError            => oPlkLed_lederr,
        oPlkLedStatus           => oPlkLed_ledst
    );

    -------------------------------------------------------------------------------
    --  PCP AXI lite Slave Interface Wrapper
    -------------------------------------------------------------------------------
    --! AXI slave wrapper for Converting PCP (AXI lite) signals to Avalon interface
    --! in Host interface IP
    AXI_LITE_SLAVE_PCP: entity work.axiLiteSlaveWrapper
    generic map (
        gBaseAddr       => C_BASEADDR,
        gHighAddr       => C_HIGHADDR,
        gAddrWidth      => 32,
        gDataWidth      => 32
    )
    port map (
        -- System Signals
        iAclk           => S_AXI_PCP_ACLK,
        inAReset        => S_AXI_PCP_ARESETN,
        -- Slave Interface Write Address Ports
        iAwaddr         => S_AXI_PCP_AWADDR,
        iAwprot         => S_AXI_PCP_AWPROT,
        iAwvalid        => S_AXI_PCP_AWVALID,
        oAwready        => S_AXI_PCP_AWREADY,
        -- Slave Interface Write Data Ports
        iWdata          => S_AXI_PCP_WDATA,
        iWstrb          => S_AXI_PCP_WSTRB,
        iWvalid         => S_AXI_PCP_WVALID,
        oWready         => S_AXI_PCP_WREADY,
        -- Slave Interface Write Response Ports
        oBresp          => S_AXI_PCP_BRESP,
        oBvalid         => S_AXI_PCP_BVALID,
        iBready         => S_AXI_PCP_BREADY,
        -- Slave Interface Read Address Ports
        iAraddr         => S_AXI_PCP_ARADDR,
        iArprot         => S_AXI_PCP_ARPROT,
        iArvalid        => S_AXI_PCP_ARVALID,
        oArready        => S_AXI_PCP_ARREADY,
        -- Slave Interface Read Data Ports
        oRdata          => S_AXI_PCP_RDATA,
        oRresp          => S_AXI_PCP_RRESP,
        oRvalid         => S_AXI_PCP_RVALID,
        iRready         => S_AXI_PCP_RREADY,
        --Avalon Interface
        oAvsAddress     => AvsPcpAddress,
        oAvsByteenable  => AvsPcpByteenable,
        oAvsRead        => AvsPcpRead,
        oAvsWrite       => AvsPcpWrite,
        oAvsWritedata   => AvsPcpWritedata,
        iAvsReaddata    => AvsPcpReaddata,
        iAvsWaitrequest => AvsPcpWaitrequest
    );

    -------------------------------------------------------------------------------
    --  Bridge AXI lite Master Interface Wrapper
    -------------------------------------------------------------------------------
    --! AXI Master wrapper for Converting Avalon signals from host interface IP to
    --! AXI master
    AXI_LITE_MASTER_BRIDGE: entity work.axiLiteMasterWrapper
    generic map (
        gAddrWidth          => C_M_AXI_ADDR_WIDTH,
        gDataWidth          => C_M_AXI_DATA_WIDTH
    )
    port map (
        -- System Signals
        iAclk               => M_AXI_ACLK,
        inAReset            => M_AXI_ARESETN,
        -- Master Interface Write Address
        oAwaddr             => M_AXI_AWADDR,
        oAwprot             => M_AXI_AWPROT,
        oAwvalid            => M_AXI_AWVALID,
        iAwready            => M_AXI_AWREADY,
        -- Master Interface Write Data
        oWdata              => M_AXI_WDATA,
        oWstrb              => M_AXI_WSTRB,
        oWvalid             => M_AXI_WVALID,
        iWready             => M_AXI_WREADY,
        oWlast              => M_AXI_WLAST,
        -- Master Interface Write Response
        iBresp              => M_AXI_BRESP,
        iBvalid             => M_AXI_BVALID,
        oBready             => M_AXI_BREADY,
        -- Master Interface Read Address
        oAraddr             => M_AXI_ARADDR,
        oArprot             => M_AXI_ARPROT,
        oArvalid            => M_AXI_ARVALID,
        iArready            => M_AXI_ARREADY,
        -- Master Interface Read Data
        iRdata              => M_AXI_RDATA,
        iRresp              => M_AXI_RRESP,
        iRvalid             => M_AXI_RVALID,
        oRready             => M_AXI_RREADY,
        -- Avalon master
        iAvalonRead         => avm_hostBridge_read,
        iAvalonWrite        => avm_hostBridge_write,
        iAvalonAddr         => AxiLiteBridgeAddress,
        iAvalonBE           => avm_hostBridge_byteenable,
        oAvalonWaitReq      => avm_hostBridge_waitrequest,
        oAvalonReadValid    => open,
        oAvalonReadData     => avm_hostBridge_readdata,
        iAvalonWriteData    => avm_hostBridge_writedata
    );

    --TODO: Try to use full memory range, now its allowed only up to 0x3FFFFFFF
    AxiLiteBridgeAddress <= "00" & avm_hostBridge_address;
    -- Host Interface IP Internal Bus
    -------------------------------------------------------------------------------
    --  HOST AXI lite Slave Interface Wrapper
    -------------------------------------------------------------------------------
    genAxiHost : if gHostIfType = 0 generate
    begin
        --! AXI slave wrapper for Converting Host (AXI lite) signals to Avalon
        AXI_LITE_SLAVE_HOST: entity work.axiLiteSlaveWrapper
        generic map (
            gBaseAddr       => C_HOST_BASEADDR,
            gHighAddr       => C_HOST_HIGHADDR,
            gAddrWidth      => 32,
            gDataWidth      => 32
        )
        port map (
            -- System Signals
            iAclk           => S_AXI_HOST_ACLK,
            inAReset        => S_AXI_HOST_ARESETN,
            -- Slave Interface Write Address Ports
            iAwaddr         => S_AXI_HOST_AWADDR,
            iAwprot         => S_AXI_HOST_AWPROT,
            iAwvalid        => S_AXI_HOST_AWVALID,
            oAwready        => S_AXI_HOST_AWREADY,
            -- Slave Interface Write Data Ports
            iWdata          => S_AXI_HOST_WDATA,
            iWstrb          => S_AXI_HOST_WSTRB,
            iWvalid         => S_AXI_HOST_WVALID,
            oWready         => S_AXI_HOST_WREADY,
            -- Slave Interface Write Response Ports
            oBresp          => S_AXI_HOST_BRESP,
            oBvalid         => S_AXI_HOST_BVALID,
            iBready         => S_AXI_HOST_BREADY,
            -- Slave Interface Read Address Ports
            iAraddr         => S_AXI_HOST_ARADDR,
            iArprot         => S_AXI_HOST_ARPROT,
            iArvalid        => S_AXI_HOST_ARVALID,
            oArready        => S_AXI_HOST_ARREADY,
            -- Slave Interface Read Data Ports
            oRdata          => S_AXI_HOST_RDATA,
            oRresp          => S_AXI_HOST_RRESP,
            oRvalid         => S_AXI_HOST_RVALID,
            iRready         => S_AXI_HOST_RREADY,
            --Avalon Interface
            oAvsAddress     => AvsHostAddress ,
            oAvsByteenable  => AvsHostByteenable,
            oAvsRead        => AvsHostRead,
            oAvsWrite       => AvsHostWrite,
            oAvsWritedata   => AvsHostWritedata,
            iAvsReaddata    => AvsHostReaddata,
            iAvsWaitrequest => AvsHostWaitrequest
        );

        host_address        <= AvsHostAddress(16 downto 2);
        host_byteenable     <= AvsHostByteenable;
        host_Read           <= AvsHostRead;
        host_write          <= AvsHostWrite;
        host_writedata      <= AvsHostWritedata;
        AvsHostWaitrequest  <= host_waitrequest;
        AvsHostReaddata     <= host_readdata;
    end generate genAxiHost;

    -------------------------------------------------------------------------------
    --  Parallel Interface External Host Processor
    -------------------------------------------------------------------------------
    genParallel : if gHostIfType = 1 generate
        signal hostData_i        : std_logic_vector(gParallelDataWidth-1 downto 0);
        signal hostData_o        : std_logic_vector(gParallelDataWidth-1 downto 0);
        signal hostData_en       : std_logic;
        signal hostAddressData_i : std_logic_vector(gParallelDataWidth-1 downto 0);
        signal hostAddressData_o : std_logic_vector(gParallelDataWidth-1 downto 0);
        signal hostAddressData_en: std_logic;
    begin
        --! Parallel interface For communicating with external Processor
        theParallelInterface : entity work.parallelInterface
        generic map (
            gDataWidth                  => gParallelDataWidth,
            gMultiplex                  => gParallelMultiplex
        )
        port map (
            iParHostChipselect          => iParHost_chipselect,
            iParHostRead                => iParHost_read,
            iParHostWrite               => iParHost_write,
            iParHostAddressLatchEnable  => iParHost_addressLatchEnable,
            oParHostAcknowledge         => oParHost_acknowledge,
            iParHostByteenable          => iParHost_byteenable,
            iParHostAddress             => iParHost_address,
            oParHostData                => hostData_o,
            iParHostData                => hostData_i,
            oParHostDataEnable          => hostData_en,
            oParHostAddressData         => hostAddressData_o,
            iParHostAddressData         => hostAddressData_i,
            oParHostAddressDataEnable   => hostAddressData_en,
            iClk                        => hostif_clock,
            iRst                        => hostif_reset,
            oHostAddress                => host_address,
            oHostByteenable             => host_byteenable,
            oHostRead                   => host_Read,
            iHostReaddata               => host_readdata,
            oHostWrite                  => host_write,
            oHostWritedata              => host_writedata,
            iHostWaitrequest            => host_waitrequest
        );

        -- Added for Xilinx Design
        -- '1' for In '0' for Out
        hostData_i              <= iParHost_data_io ;
        oParHost_data_io        <= hostData_o ;
        oParHost_data_io_tri    <= not hostData_en ;

        -- Added for Xilinx Design
        hostAddressData_i           <= iParHost_addressData_io ;
        oParHost_addressData_io     <= hostAddressData_o ;
        oParHost_addressData_tri    <= not hostAddressData_en ;
    end generate genParallel;
end rtl;
