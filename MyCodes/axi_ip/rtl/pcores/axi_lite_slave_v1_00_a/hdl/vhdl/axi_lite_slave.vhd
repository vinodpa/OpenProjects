-----------------------------------------------------------------------------
--
-- AXI Lite Slave
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_misc.all;

--library unisim;
--use unisim.vcomponents.all;

entity axi_lite_slave is
generic
    (
    C_BASEADDR         : std_logic_vector(31 downto 0) := x"00000000";
    C_HIGHADDR         : std_logic_vector(31 downto 0) := x"0000ffff";
    C_S_AXI_ADDR_WIDTH : integer                       := 32;
    C_S_AXI_DATA_WIDTH : integer                       := 32
    );

port
	(
	-- System Signals
    ACLK            :   in      std_logic                                               ;
    ARESETN         :   in      std_logic                                               ;
    -- Slave Interface Write Address Ports
    S_AXI_AWADDR    :   in      std_logic_vector    (C_S_AXI_ADDR_WIDTH -1 downto 0)    ;
    S_AXI_AWPROT    :   in      std_logic_vector    (3-1 downto 0)                      ;
    S_AXI_AWVALID   :   in      std_logic                                               ;
    S_AXI_AWREADY   :   out     std_logic                                               ;
    -- Slave Interface Write Data Ports
    S_AXI_WDATA     :   in      std_logic_vector    (C_S_AXI_DATA_WIDTH-1 downto 0)     ;
    S_AXI_WSTRB     :   in      std_logic_vector    (C_S_AXI_DATA_WIDTH/8-1 downto 0)   ;
    S_AXI_WVALID    :   in      std_logic                                               ;
    S_AXI_WREADY    :   out     std_logic                                               ;
    -- Slave Interface Write Response Ports
    S_AXI_BRESP     :   out     std_logic_vector    (2-1 downto 0)                      ;
    S_AXI_BVALID    :   out     std_logic                                               ;
    S_AXI_BREADY    :   in      std_logic                                               ;
    -- Slave Interface Read Address Ports
    S_AXI_ARADDR    :   in      std_logic_vector    (C_S_AXI_ADDR_WIDTH -1 downto 0)    ;
    S_AXI_ARPROT    :   in      std_logic_vector    (3-1 downto 0)                      ;
    S_AXI_ARVALID   :   in      std_logic                                               ;
    S_AXI_ARREADY   :   out     std_logic                                               ;
    -- Slave Interface Read Data Ports
    S_AXI_RDATA     :   out     std_logic_vector    (C_S_AXI_DATA_WIDTH-1 downto 0)     ;
    S_AXI_RRESP     :   out     std_logic_vector    (2-1 downto 0)                      ;
    S_AXI_RVALID    :   out     std_logic                                               ;
    S_AXI_RREADY    :   in      std_logic												;
	--test ports
	tAvsPcpAddress      : out std_logic_vector    (31 downto 0)   ;
    tAvsPcpByteenable   : out std_logic_vector    (3 downto 0)    ;
    tAvsPcpRead         : out std_logic  ;
	tAvsPcpWrite        : out std_logic  ;
	tAvsPcpWritedata    : out std_logic_vector   (31 downto 0);
	tAvsPcpReaddata     : out std_logic_vector   (31 downto 0);
	tAvsPcpWaitrequest  : out std_logic   					  ;
	tAWVALID			: out std_logic   					  ;
	tAWREADY			: out std_logic   					  ;
	tWVALID				: out std_logic   					  ;
	tWREADY				: out std_logic   					  ;
	tBVALID				: out std_logic   					  ;
	tBREADY				: out std_logic   					  ;
	tARVALID			: out std_logic   					  ;
	tARREADY			: out std_logic   					  ;
	tRVALID				: out std_logic   					  ;
	tRREADY				: out std_logic   					  
    );

end axi_lite_slave;

architecture implementation of axi_lite_slave is

signal  AvsPcpAddress      :  std_logic_vector    (31 downto 0)   ;
signal  AvsPcpByteenable   :  std_logic_vector    (3 downto 0)    ;
signal  AvsPcpRead         :  std_logic  ;
signal  AvsPcpWrite        :  std_logic  ;
signal  AvsPcpWritedata    :  std_logic_vector   (31 downto 0);
signal  AvsPcpReaddata     :  std_logic_vector   (31 downto 0);
signal  AvsPcpWaitrequest  :  std_logic   ;

signal	AWREADY			  :  std_logic   ;
signal  WREADY			  :  std_logic   ;
signal	BVALID			  :  std_logic   ;
signal	ARREADY		  	  :  std_logic   ;
signal 	RVALID		  	  :  std_logic   ;
	

begin

	tAvsPcpAddress			<= AvsPcpAddress ;
    tAvsPcpByteenable		<= AvsPcpByteenable ;
    tAvsPcpRead      		<= AvsPcpRead		;
	tAvsPcpWrite     		<= AvsPcpWrite		;
	tAvsPcpWritedata 		<= AvsPcpWritedata ;
	tAvsPcpReaddata  		<= AvsPcpReaddata ;
	tAvsPcpWaitrequest		<= AvsPcpWaitrequest ;
	
	-- Slave Interface Write Address Ports
    tAWVALID   <=  S_AXI_AWVALID   ;
    S_AXI_AWREADY  <=  AWREADY   ;
	tAWREADY   		<=  AWREADY   ;
    -- Slave Interface Write Data Ports
    tWVALID    <=  S_AXI_WVALID    ;
    S_AXI_WREADY   <=  WREADY    ;
	tWREADY    		<=  WREADY    ;
    -- Slave Interface Write Response Ports
    S_AXI_BVALID   <=  BVALID    ;
	tBVALID    		<=  BVALID    ;
    tBREADY    <=  S_AXI_BREADY    ;
    -- Slave Interface Read Address Ports
    tARVALID   <=  S_AXI_ARVALID   ;
    S_AXI_ARREADY  <=  ARREADY   ;
	tARREADY   		<=  ARREADY   ;
    -- Slave Interface Read Data Ports
    S_AXI_RVALID   <=  RVALID    ;
	tRVALID    		<=  RVALID    ;
    tRREADY    <=  S_AXI_RREADY    ;


WRAPPER: entity work.axi_lite_slave_wrapper
    generic map (
    C_BASEADDR         => C_BASEADDR ,
    C_HIGHADDR         => C_HIGHADDR ,
    C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH ,
    C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH
    )
    port map
    (
    -- System Signals
    ACLK            =>  ACLK    ,
    ARESETN         =>  ARESETN ,
    -- Slave Interface Write Address Ports
    S_AXI_AWADDR    =>  S_AXI_AWADDR    ,
    S_AXI_AWPROT    =>  S_AXI_AWPROT    ,
    S_AXI_AWVALID   =>  S_AXI_AWVALID   ,
    S_AXI_AWREADY   =>  AWREADY   ,
    -- Slave Interface Write Data Ports
    S_AXI_WDATA     =>  S_AXI_WDATA     ,
    S_AXI_WSTRB     =>  S_AXI_WSTRB     ,
    S_AXI_WVALID    =>  S_AXI_WVALID    ,
    S_AXI_WREADY    =>  WREADY    ,
    -- Slave Interface Write Response Ports
    S_AXI_BRESP     =>  S_AXI_BRESP     ,
    S_AXI_BVALID    =>  BVALID    ,
    S_AXI_BREADY    =>  S_AXI_BREADY    ,
    -- Slave Interface Read Address Ports
    S_AXI_ARADDR    =>  S_AXI_ARADDR    ,
    S_AXI_ARPROT    =>  S_AXI_ARPROT    ,
    S_AXI_ARVALID   =>  S_AXI_ARVALID   ,
    S_AXI_ARREADY   =>  ARREADY   ,
    -- Slave Interface Read Data Ports
    S_AXI_RDATA     =>  S_AXI_RDATA     ,
    S_AXI_RRESP     =>  S_AXI_RRESP     ,
    S_AXI_RVALID    =>  RVALID    ,
    S_AXI_RREADY    =>  S_AXI_RREADY    ,
    --Avalon Interface
    oAvsAddress  =>  AvsPcpAddress   ,
    oAvsByteenable =>    AvsPcpByteenable ,
    oAvsRead     =>  AvsPcpRead      ,
    oAvsWrite    =>  AvsPcpWrite     ,
    oAvsWritedata => AvsPcpWritedata ,
    iAvsReaddata =>  AvsPcpReaddata  ,
    iAvsWaitrequest =>   AvsPcpWaitrequest
    );


--SLAVE: entity work.avalon_slave
--        port map
--            (
--              iClk                  =>  ACLK                    ,
--              nReset                =>  ARESETN                 ,
--              avs_pcp_address       =>  AvsPcpAddress (10 downto 0)   ,
--              avs_pcp_byteenable    =>  AvsPcpByteenable             ,
--              avs_pcp_read          =>  AvsPcpRead            ,
--              avs_pcp_READData      =>  AvsPcpReaddata             ,   --TODO:Check Direct Assign is fine or not
--              avs_pcp_write         =>  AvsPcpWrite            ,
--              avs_pcp_writedata     =>  AvsPcpWritedata             ,    --TODO:Check Direct Assign is fine or not
--              avs_pcp_waitrequest   =>  AvsPcpWaitrequest                        --TODO: No need of wait request
--             );

end implementation;