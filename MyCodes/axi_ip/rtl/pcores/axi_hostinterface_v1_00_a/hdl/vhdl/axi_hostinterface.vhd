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
use ieee.numeric_std.all;
--! use global library
use work.global.all;

entity axi_hostinterface is
    generic (
        --AXI Lite Slave PCP Interface
        C_BASEADDR         : std_logic_vector(31 downto 0) := x"00000000"; --TODO: Rename
        C_HIGHADDR         : std_logic_vector(31 downto 0) := x"0000ffff"; --TODO: Rename
        C_S_AXI_ADDR_WIDTH : integer                       := 32; --TODO: Rename
        C_S_AXI_DATA_WIDTH : integer                       := 32; --TODO: Rename
        --AXI Lite Slave Host Interface
--        C_HOST_BASEADDR         : std_logic_vector(31 downto 0) := x"00000000";
--        C_HOST_HIGHADDR         : std_logic_vector(31 downto 0) := x"0000ffff";
--        C_S_HOST_AXI_ADDR_WIDTH : integer                       := 32;
--        C_S_HOST_AXI_DATA_WIDTH : integer                       := 32;
        ----Host Interface Parameters
        --! Version major
        gVersionMajor       : natural := 16#FF#;
        --! Version minor
        gVersionMinor       : natural := 16#FF#;
        --! Version revision
        gVersionRevision    : natural := 16#FF#;
        --! Version count
        gVersionCount       : natural := 0;
        -- Base address mapping
        --! Base address Dynamic Buffer 0
        gBaseDynBuf0        : natural := 16#00800#;
        --! Base address Dynamic Buffer 1
        gBaseDynBuf1        : natural := 16#01000#;
        --! Base address Error Counter
        gBaseErrCntr        : natural := 16#01800#;
        --! Base address TX NMT Queue
        gBaseTxNmtQ         : natural := 16#02800#;
        --! Base address TX Generic Queue
        gBaseTxGenQ         : natural := 16#03800#;
        --! Base address TX SyncRequest Queue
        gBaseTxSynQ         : natural := 16#04800#;
        --! Base address TX Virtual Ethernet Queue
        gBaseTxVetQ         : natural := 16#05800#;
        --! Base address RX Virtual Ethernet Queue
        gBaseRxVetQ         : natural := 16#06800#;
        --! Base address Kernel-to-User Queue
        gBaseK2UQ           : natural := 16#07000#;
        --! Base address User-to-Kernel Queue
        gBaseU2KQ           : natural := 16#09000#;
        --! Base address Tpdo
        gBaseTpdo           : natural := 16#0B000#;
        --! Base address Rpdo
        gBaseRpdo           : natural := 16#0E000#;
        --! Base address Reserved (-1 = high address of Rpdo)
        gBaseRes            : natural := 16#14000#;
        --! Select Host Interface Type (0 = Avalon, 1 = Parallel)
        gHostIfType         : natural := 0;
        --! Data width of parallel interface (16/32)
        gParallelDataWidth  : natural := 16;
        --! Address and Data bus are multiplexed (0 = FALSE, otherwise = TRUE)
        gParallelMultiplex  : natural := 0
    );
    port (
        --! Clock Source input
        --csi_c0_clock                    : in std_logic;
        --! Reset Source input
        --rsi_r0_reset                    : in std_logic;
        -- Avalon Memory Mapped Slave for PCP
        -- System Signals
        PCP_ACLK            :   in  std_logic                                        ;
        PCP_ARESETN         :   in  std_logic                                        ;
        -- Slave Interface Write Address Ports
        S_PCP_AXI_AWADDR    :   in  std_logic_vector (C_S_AXI_ADDR_WIDTH -1 downto 0);
        S_PCP_AXI_AWPROT    :   in  std_logic_vector ( 2 downto 0)                   ;
        S_PCP_AXI_AWVALID   :   in  std_logic                                        ;
        S_PCP_AXI_AWREADY   :   out std_logic                                        ;
        -- Slave Interface Write Data Ports
        S_PCP_AXI_WDATA     :   in  std_logic_vector (C_S_AXI_DATA_WIDTH-1 downto 0) ;
        S_PCP_AXI_WSTRB     :   in  std_logic_vector (C_S_AXI_DATA_WIDTH/8-1 downto 0);
        S_PCP_AXI_WVALID    :   in  std_logic                                        ;
        S_PCP_AXI_WREADY    :   out std_logic                                        ;
        -- Slave Interface Write Response Ports
        S_PCP_AXI_BRESP     :   out std_logic_vector (1 downto 0)                    ;
        S_PCP_AXI_BVALID    :   out std_logic                                        ;
        S_PCP_AXI_BREADY    :   in  std_logic                                        ;
        -- Slave Interface Read Address Ports
        S_PCP_AXI_ARADDR    :   in  std_logic_vector (C_S_AXI_ADDR_WIDTH -1 downto 0);
        S_PCP_AXI_ARPROT    :   in  std_logic_vector (2 downto 0)                    ;
        S_PCP_AXI_ARVALID   :   in  std_logic                                        ;
        S_PCP_AXI_ARREADY   :   out std_logic                                        ;
        -- Slave Interface Read Data Ports
        S_PCP_AXI_RDATA     :   out std_logic_vector (C_S_AXI_DATA_WIDTH-1 downto 0) ;
        S_PCP_AXI_RRESP     :   out std_logic_vector (1 downto 0)                    ;
        S_PCP_AXI_RVALID    :   out std_logic                                        ;
        S_PCP_AXI_RREADY    :   in  std_logic                                        ;

        -- Avalon Memory Mapped Slave for Host
        -- System Signals
--        HOST_ACLK            :   in  std_logic                                        ;
--        HOST_ARESETN         :   in  std_logic                                        ;
        -- Slave Interface Write Address Ports
--        S_HOST_AXI_AWADDR    :   in  std_logic_vector (C_S_AXI_ADDR_WIDTH -1 downto 0);
--        S_HOST_AXI_AWPROT    :   in  std_logic_vector ( 2 downto 0)                   ;
--        S_HOST_AXI_AWVALID   :   in  std_logic                                        ;
--        S_HOST_AXI_AWREADY   :   out std_logic                                        ;
        -- Slave Interface Write Data Ports
--        S_HOST_AXI_WDATA     :   in  std_logic_vector (C_S_AXI_DATA_WIDTH-1 downto 0) ;
--        S_HOST_AXI_WSTRB     :   in  std_logic_vector (C_S_AXI_DATA_WIDTH/8-1 downto 0);
--        S_HOST_AXI_WVALID    :   in  std_logic                                        ;
--        S_HOST_AXI_WREADY    :   out std_logic                                        ;
        -- Slave Interface Write Response Ports
--        S_HOST_AXI_BRESP     :   out std_logic_vector (1 downto 0)                    ;
--        S_HOST_AXI_BVALID    :   out std_logic                                        ;
--        S_HOST_AXI_BREADY    :   in  std_logic                                        ;
        -- Slave Interface Read Address Ports
--        S_HOST_AXI_ARADDR    :   in  std_logic_vector (C_S_AXI_ADDR_WIDTH -1 downto 0);
--        S_HOST_AXI_ARPROT    :   in  std_logic_vector (2 downto 0)                    ;
--        S_HOST_AXI_ARVALID   :   in  std_logic                                        ;
--        S_HOST_AXI_ARREADY   :   out std_logic                                        ;
        -- Slave Interface Read Data Ports
--        S_HOST_AXI_RDATA     :   out std_logic_vector (C_S_AXI_DATA_WIDTH-1 downto 0) ;
--        S_HOST_AXI_RRESP     :   out std_logic_vector (1 downto 0)                    ;
--        S_HOST_AXI_RVALID    :   out std_logic                                        ;
--        S_HOST_AXI_RREADY    :   in  std_logic                                        ;

        -- Avalon Memory Mapped Master for Host via Magic Bridge
        --! Avalon-MM master hostBridge address
        avm_hostBridge_address          : out std_logic_vector(29 downto 0);
        --! Avalon-MM master hostBridge byteenable
        avm_hostBridge_byteenable       : out std_logic_vector(3 downto 0);
        --! Avalon-MM master hostBridge read
        avm_hostBridge_read             : out std_logic;
        --! Avalon-MM master hostBridge readdata
        avm_hostBridge_readdata         : in std_logic_vector(31 downto 0);
        --! Avalon-MM master hostBridge write
        avm_hostBridge_write            : out std_logic;
        --! Avalon-MM master hostBridge writedata
        avm_hostBridge_writedata        : out std_logic_vector(31 downto 0);
        --! Avalon-MM master hostBridge waitrequest
        avm_hostBridge_waitrequest      : in std_logic;
        --! Interrupt receiver
        inr_irqSync_irq                 : in std_logic;
        --! Interrupt sender
        ins_irqOut_irq                  : out std_logic;
        --! External Sync Source
        coe_ExtSync_exsync              : in std_logic;
        --! Node Id
        coe_NodeId_nodeid               : in std_logic_vector(7 downto 0);
        --! POWERLINK Error LED
        coe_PlkLed_lederr               : out std_logic;
        --! POWERLINK Status LED
        coe_PlkLed_ledst                : out std_logic;
        -- Parallel Host Interface
        --! Chipselect
        coe_parHost_chipselect          : in std_logic;
        --! Read strobe
        coe_parHost_read                : in std_logic;
        --! Write strobe
        coe_parHost_write               : in std_logic;
        --! Address Latch enable (Multiplexed only)
        coe_parHost_addressLatchEnable  : in std_logic;
        --! High active Acknowledge
        coe_parHost_acknowledge         : out std_logic;
        --! Byteenables
        coe_parHost_byteenable          : in std_logic_vector(gParallelDataWidth/8-1 downto 0);
        --! Address bus (Demultiplexed, word-address)
        coe_parHost_address             : in std_logic_vector(15 downto 0);
        --! Data bus (Demultiplexed)
        coe_parHost_data_I                : in std_logic_vector(gParallelDataWidth-1 downto 0);
        coe_parHost_data_O                : out std_logic_vector(gParallelDataWidth-1 downto 0);
        coe_parHost_data_T                : out std_logic ;
        --! Address/Data bus (Multiplexed, word-address))
        --coe_parHost_addressData         : inout std_logic_vector(gParallelDataWidth-1 downto 0)
        coe_parHost_addressData_I         : in std_logic_vector(gParallelDataWidth-1 downto 0);
        coe_parHost_addressData_O         : out std_logic_vector(gParallelDataWidth-1 downto 0);
        coe_parHost_addressData_T         : out std_logic 
    );
end axi_hostinterface;

architecture rtl of axi_hostinterface is
    --! The bridge translation lut is implemented in memory blocks to save logic resources.
    --! If no M9K shall be used, set this constant to 0.
    constant cBridgeUseMemBlock : natural := 1;

    signal host_address     : std_logic_vector(16 downto 2);
    signal host_byteenable  : std_logic_vector(3 downto 0);
    signal host_Read        : std_logic;
    signal host_readdata    : std_logic_vector(31 downto 0);
    signal host_write       : std_logic;
    signal host_writedata   : std_logic_vector(31 downto 0);
    signal host_waitrequest : std_logic;

    --Signals for warapper to PCP Host Interface
    signal  AvsPcpAddress      :  std_logic_vector    (31 downto 0)   ;
    signal  AvsPcpByteenable   :  std_logic_vector    (3 downto 0)    ;
    signal  AvsPcpRead         :  std_logic  ;
    signal  AvsPcpWrite        :  std_logic  ;
    signal  AvsPcpWritedata    :  std_logic_vector   (31 downto 0);
    signal  AvsPcpReaddata     :  std_logic_vector   (31 downto 0);
    signal  AvsPcpWaitrequest  :  std_logic   ;

    --Signals for warapper to PCP Host Interface
    signal  AvsHostAddress      :  std_logic_vector    (31 downto 0)   ;
    signal  AvsHostByteenable   :  std_logic_vector    (3 downto 0)    ;
    signal  AvsHostRead         :  std_logic  ;
    signal  AvsHostWrite        :  std_logic  ;
    signal  AvsHostWritedata    :  std_logic_vector   (31 downto 0);
    signal  AvsHostReaddata     :  std_logic_vector   (31 downto 0);
    signal  AvsHostWaitrequest  :  std_logic   ;
    
    --Few Cheating Handlors
    signal csi_c0_clock          : std_logic;
        --! Reset Source input
    signal rsi_r0_reset         : std_logic;
    
begin

    -- Cheat code
    csi_c0_clock     <=  PCP_ACLK ;
    rsi_r0_reset    <=  PCP_ARESETN ;
    --! Assign the host side to Avalon
    genAvalon : if gHostIfType = 0 generate
    begin
       --    --TODO: Port Naming Conflits has to fix
--    AxiLiteSlaveWrapperAP: entity work.axi_lite_slave_wrapper
--    generic map (
--            C_BASEADDR         => C_HOST_BASEADDR ,
--            C_HIGHADDR         => C_HOST_HIGHADDR ,
--            C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH ,
--            C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH
--    )
--    port map
--    (
--            -- System Signals
--            ACLK            =>  HOST_ACLK    ,
--            ARESETN         =>  HOST_ARESETN ,
--            -- Slave Interface Write Address Ports
--            S_AXI_AWADDR    =>  S_HOST_AXI_AWADDR    ,
--            S_AXI_AWPROT    =>  S_HOST_AXI_AWPROT    ,
--            S_AXI_AWVALID   =>  S_HOST_AXI_AWVALID   ,
--            S_AXI_AWREADY   =>  S_HOST_AXI_AWREADY   ,
--            -- Slave Interface Write Data Ports
--            S_AXI_WDATA     =>  S_HOST_AXI_WDATA     ,
--            S_AXI_WSTRB     =>  S_HOST_AXI_WSTRB     ,
--            S_AXI_WVALID    =>  S_HOST_AXI_WVALID    ,
--            S_AXI_WREADY    =>  S_HOST_AXI_WREADY    ,
--            -- Slave Interface Write Response Ports
--            S_AXI_BRESP     =>  S_HOST_AXI_BRESP     ,
--            S_AXI_BVALID    =>  S_HOST_AXI_BVALID    ,
--            S_AXI_BREADY    =>  S_HOST_AXI_BREADY    ,
--            -- Slave Interface Read Address Ports
--            S_AXI_ARADDR    =>  S_HOST_AXI_ARADDR    ,
--            S_AXI_ARPROT    =>  S_HOST_AXI_ARPROT    ,
--            S_AXI_ARVALID   =>  S_HOST_AXI_ARVALID   ,
--            S_AXI_ARREADY   =>  S_HOST_AXI_ARREADY   ,
--            -- Slave Interface Read Data Ports
--            S_AXI_RDATA     =>  S_HOST_AXI_RDATA     ,
--            S_AXI_RRESP     =>  S_HOST_AXI_RRESP     ,
--            S_AXI_RVALID    =>  S_HOST_AXI_RVALID    ,
--            S_AXI_RREADY    =>  S_HOST_AXI_RREADY    ,
--            --Avalon Interface
--            oAvsAddress  =>  AvsHostAddress   ,
--            oAvsByteenable =>    AvsHostByteenable ,
--            oAvsRead     =>  AvsHostRead      ,
--            oAvsWrite    =>  AvsHostWrite     ,
--            oAvsWritedata => AvsHostWritedata ,
--            iAvsReaddata =>  AvsHostReaddata  ,
--            iAvsWaitrequest =>   AvsHostWaitrequest
--    );
--      host_address    <=  AvsHostAddress (16 downto 0) ;
--      host_byteenable <=  AvsHostByteenable           ;
--      host_Read       <=  AvsHostRead                 ;
--      host_write      <=  AvsHostWrite                ;
--      host_writedata  <=  AvsHostWritedata            ;
--      AvsHostWaitrequest <= host_waitrequest          ;
--      AvsHostReaddata <=  host_readdata            ;
--
    end generate;

    --! Assign the host side to Parallel
    genParallel : if gHostIfType = 1 generate
        signal hostData_i           : std_logic_vector(gParallelDataWidth-1 downto 0);
        signal hostData_o           : std_logic_vector(gParallelDataWidth-1 downto 0);
        signal hostData_en          : std_logic;
        signal hostAddressData_i    : std_logic_vector(gParallelDataWidth-1 downto 0);
        signal hostAddressData_o    : std_logic_vector(gParallelDataWidth-1 downto 0);
        signal hostAddressData_en   : std_logic;
    begin
        -- not used signals are set to inactive
        --avs_host_readdata <= (others => cInactivated); --TODO: Check these signals
        --avs_host_waitrequest <= cInactivated; --TODO: Check these signals

        theParallelInterface : entity work.parallelInterface
            generic map (
                gDataWidth => gParallelDataWidth,
                gMultiplex => gParallelMultiplex
            )
            port map (
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
                iClk                        => csi_c0_clock,
                iRst                        => rsi_r0_reset,
                oHostAddress                => host_address,
                oHostByteenable             => host_byteenable,
                oHostRead                   => host_Read,
                iHostReaddata               => host_readdata,
                oHostWrite                  => host_write,
                oHostWritedata              => host_writedata,
                iHostWaitrequest            => host_waitrequest
            );

        -- tri-state buffers
        -- Removed for Xilinx Design
        --coe_parHost_data <= hostData_o when hostData_en = cActivated else
         --                   (others => 'Z');

        --hostData_i <= coe_parHost_data;
        
        -- Added for Xilinx Design
        hostData_i <= coe_parHost_data_I ;
        coe_parHost_data_O <= hostData_o ;
        coe_parHost_data_T <= hostData_en ;

         -- Removed for Xilinx Design
        --coe_parHost_addressData <= hostAddressData_o when hostAddressData_en = cActivated else
        --                           (others => 'Z');

        --hostAddressData_i <= coe_parHost_addressData;
        
        -- Added for Xilinx Design
        hostAddressData_i <= coe_parHost_addressData_I ;
        coe_parHost_addressData_O <= hostAddressData_o ;
        coe_parHost_addressData_T <= hostAddressData_en ;
        
    end generate;

    --! The host interface
    theHostInterface: entity work.hostInterface
    generic map (
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
    port map (
        iClk                   => csi_c0_clock,
        iRst                   => rsi_r0_reset,
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
        oHostBridgeAddress     => avm_hostBridge_address,           --TODO: Rename Ports
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

    --TODO: Port Naming Conflits has to fix
    AxiLiteSlaveWrapperPCP: entity work.axi_lite_slave_wrapper
    generic map (
            C_BASEADDR         => C_BASEADDR ,  --TODO: Rename
            C_HIGHADDR         => C_HIGHADDR , --TODO: Rename
            C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH , --TODO: Rename
            C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH  --TODO: Rename
    )
    port map
    (
            -- System Signals
            ACLK            =>  PCP_ACLK    ,
            ARESETN         =>  PCP_ARESETN ,
            -- Slave Interface Write Address Ports
            S_AXI_AWADDR    =>  S_PCP_AXI_AWADDR    ,
            S_AXI_AWPROT    =>  S_PCP_AXI_AWPROT    ,
            S_AXI_AWVALID   =>  S_PCP_AXI_AWVALID   ,
            S_AXI_AWREADY   =>  S_PCP_AXI_AWREADY   ,
            -- Slave Interface Write Data Ports
            S_AXI_WDATA     =>  S_PCP_AXI_WDATA     ,
            S_AXI_WSTRB     =>  S_PCP_AXI_WSTRB     ,
            S_AXI_WVALID    =>  S_PCP_AXI_WVALID    ,
            S_AXI_WREADY    =>  S_PCP_AXI_WREADY    ,
            -- Slave Interface Write Response Ports
            S_AXI_BRESP     =>  S_PCP_AXI_BRESP     ,
            S_AXI_BVALID    =>  S_PCP_AXI_BVALID    ,
            S_AXI_BREADY    =>  S_PCP_AXI_BREADY    ,
            -- Slave Interface Read Address Ports
            S_AXI_ARADDR    =>  S_PCP_AXI_ARADDR    ,
            S_AXI_ARPROT    =>  S_PCP_AXI_ARPROT    ,
            S_AXI_ARVALID   =>  S_PCP_AXI_ARVALID   ,
            S_AXI_ARREADY   =>  S_PCP_AXI_ARREADY   ,
            -- Slave Interface Read Data Ports
            S_AXI_RDATA     =>  S_PCP_AXI_RDATA     ,
            S_AXI_RRESP     =>  S_PCP_AXI_RRESP     ,
            S_AXI_RVALID    =>  S_PCP_AXI_RVALID    ,
            S_AXI_RREADY    =>  S_PCP_AXI_RREADY    ,
            --Avalon Interface
            oAvsAddress  =>  AvsPcpAddress   ,
            oAvsByteenable =>    AvsPcpByteenable ,
            oAvsRead     =>  AvsPcpRead      ,
            oAvsWrite    =>  AvsPcpWrite     ,
            oAvsWritedata => AvsPcpWritedata ,
            iAvsReaddata =>  AvsPcpReaddata  ,
            iAvsWaitrequest =>   AvsPcpWaitrequest
    );

end rtl;
