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
    S_AXI_RREADY    :   in      std_logic                                               ;
    --Avalon Interface
    oAvsPcpAddress      :   out std_logic_vector    (31 downto 0)   ;
    oAvsPcpByteenable   :   out std_logic_vector    (3 downto 0)    ;
    oAvsPcpRead         :   out std_logic  ;
    oAvsPcpWrite        :   out std_logic  ;
    oAvsPcpWritedata    :   out std_logic_vector   (31 downto 0);
    iAvsPcpReaddata     :   in  std_logic_vector   (31 downto 0);
    iAvsPcpWaitrequest  :   in  std_logic
    );

end axi_lite_slave;

architecture implementation of axi_lite_slave is

--component avalon_slave
--   port
--      (
--          iClk                  :   in  std_logic                       ;
--          nReset                :   in  std_logic                       ;
--          avs_pcp_address       :   in  std_logic_vector(10 downto 0)   ;
--          avs_pcp_byteenable    :   in  std_logic_vector(3 downto 0)    ;
--          avs_pcp_read          :   in  std_logic                       ;
--          avs_pcp_readdata      :   out std_logic_vector(31 downto 0)   ;
--          avs_pcp_write         :   in  std_logic                       ;
--          avs_pcp_writedata     :   in  std_logic_vector(31 downto 0)   ;
--          avs_pcp_waitrequest   :   out std_logic
--      );
--end component;

type state is (sIDLE,sDELAY,sREAD,sWRITE) ;

--constant IDLE   : std_logic_vector(1 downto 0) := "00";
--constant DELAY  : std_logic_vector(1 downto 0) := "01";
--constant READD  : std_logic_vector(1 downto 0) := "10";
--constant WRITEE : std_logic_vector(1 downto 0) := "11";

--Avalon Interface designs
signal  address      :   std_logic_vector(31 downto 0)   ;
signal  chip_sel     :   std_logic                       ;
signal  byte_enable  :   std_logic_vector(3 downto 0)    ;

signal  StateCurrent   :  state     ;
signal  StateNext      :  state     ;

signal  BvalidCurrent  :   std_logic   ;
signal  AwreadyCurrent :   std_logic   ;
signal  ArreadyCurrent :   std_logic   ;
signal  WreadyCurrent  :   std_logic   ;
signal  RvalidCurrent  :   std_logic   ;

signal  BvalidNext     :   std_logic   ;
signal  AwreadyNext    :   std_logic   ;
signal  ArreadyNext    :   std_logic   ;
signal  WreadyNext     :   std_logic   ;
signal  RvalidNext     :   std_logic   ;

begin


    --Ouput Signals assigns
    oAvsPcpAddress      <=  address             ;
    oAvsPcpByteenable   <=  byte_enable         ;
    oAvsPcpRead         <=  S_AXI_RREADY        ;
    oAvsPcpWrite        <=  S_AXI_WVALID        ;
    oAvsPcpWritedata    <=  S_AXI_WDATA         ;
    S_AXI_RDATA         <=  iAvsPcpReaddata     ;
--                        <=  iAvsPcpWaitrequest

    S_AXI_BVALID     <=   BvalidCurrent     ;
    S_AXI_AWREADY    <=   AwreadyCurrent    ;
    S_AXI_ARREADY    <=   ArreadyCurrent    ;
    S_AXI_WREADY     <=   WreadyCurrent     ;
    S_AXI_RVALID     <=   RvalidCurrent     ;
    S_AXI_BRESP      <=   "00"        ;   --always OK
    S_AXI_RRESP      <=   "00"        ;   --always ok

    -- Address Decoder
SEL_IP:
    process ( S_AXI_AWADDR , S_AXI_ARADDR )
    begin
        if ((C_BASEADDR <=  S_AXI_AWADDR) and (S_AXI_AWADDR <= C_HIGHADDR))
        then
            chip_sel    <=  '1' ;
        elsif ((C_BASEADDR <=  S_AXI_ARADDR) and (S_AXI_ARADDR <= C_HIGHADDR))
        then
            chip_sel    <=  '1' ;
        else
            chip_sel    <=  '0' ;
        end if;
    end process;

    --TODO: Mux Addresss
SEL_ADDR:
    process (S_AXI_ARVALID , S_AXI_AWVALID, S_AXI_ARADDR , S_AXI_AWADDR, chip_sel)
    begin
        if ((chip_sel and S_AXI_ARVALID)='1' )
        then
            address     <=  S_AXI_ARADDR ;
        elsif ((chip_sel and S_AXI_AWVALID)='1' )
        then
            address     <= S_AXI_AWADDR ;
        else
            address     <= x"00000000"  ;
        end if;
    end process;
 --TODO: Byte Enable : Axi Lite supports all data accesses use the full width of the data bus
 --- AXI4-Lite supports a data bus width of 32-bit or 64-bit. SPEC B1- Definition of AXI Lite
 --Supports 4byte read/write

    byte_enable <= S_AXI_WSTRB ;


--AXI Write/Read Data Control signls FSM

--Registerd Logic for FSM
SEQ_LOGIC_FSM:
    process (ACLK)
    begin
        if(rising_edge(ACLK))
        then
        if( ARESETN = '0' )
        then
            StateCurrent     <= sIDLE ;
            BvalidCurrent    <= '0' ;
            AwreadyCurrent   <= '0' ;
            ArreadyCurrent   <= '0' ;
            WreadyCurrent    <= '0' ;
            RvalidCurrent    <= '0' ;
        else
            StateCurrent     <= StateNext ;
            BvalidCurrent    <= BvalidNext;
            AwreadyCurrent   <= AwreadyNext ;
            ArreadyCurrent   <= ArreadyNext ;
            WreadyCurrent    <= WreadyNext ;
            RvalidCurrent    <= RvalidNext ;
        end if;
       end if;
    end process;


--Step1: Wait for Address Valid --> Go to Read/Write (Step 2 or 3)
--Step2: Wait for ReadReady --> ReadValid & ReadAddressReady assert
--Step3: Wait for Wdata Valis --> Assert Wready & Awready & Bvalid with Bresp

--Combinational Logic for FSM
COM_LOGIC_FSM:
    process (StateCurrent)
    begin
    case (StateCurrent) is
            when sIDLE =>
               BvalidNext    <= '0' ;
               AwreadyNext   <= '0' ;
               ArreadyNext   <= '0' ;
               WreadyNext    <= '0' ;
               RvalidNext    <= '0' ;

               if(chip_sel = '1' )
                then
                   if(S_AXI_AWVALID    =   '1') then
                   StateNext <= sWRITE ;
                   elsif (S_AXI_ARVALID    =   '1') then
                   StateNext  <= sREAD ;
                   else
                   StateNext  <= sIDLE ;
                   end if;
                else
                   StateNext <= sIDLE ;
               end if;

            when sDELAY =>
               BvalidNext    <= '0' ;
               AwreadyNext   <= '0' ;
               ArreadyNext   <= '0' ;
               WreadyNext    <= '0' ;
               RvalidNext    <= '0' ;
               StateNext <= sIDLE ;

            when sREAD =>
               BvalidNext    <= '0' ;
               AwreadyNext   <= '0' ;
               WreadyNext    <= '0' ;

               if( S_AXI_RREADY = '1' )
                then
                 ArreadyNext   <= '1' ;
                 RvalidNext    <= '1' ;
                 StateNext     <= sDELAY ;
               else
                 ArreadyNext   <= '0' ;
                 RvalidNext    <= '0' ;
                 StateNext     <= sREAD ;
               end if;

            when sWRITE =>

               ArreadyNext   <= '0' ;
               RvalidNext    <= '0' ;

               if(S_AXI_WVALID = '1' )
                then
                  AwreadyNext   <= '1' ;
                  BvalidNext    <= '1' ; --TODO: Handle Response Independently
                  WreadyNext    <= '1' ;
                  StateNext     <= sDELAY ;
               else
                  AwreadyNext   <= '0' ;
                  BvalidNext    <= '0' ; --TODO: Handle Response Independently
                  WreadyNext    <= '0';
                  StateNext     <= sWRITE ;
               end if;

            when others =>

        end case;
    end process;

    SLAVE: entity work.avalon_slave
            port map
                (
                  iClk                  =>  ACLK                    ,
                  nReset                =>  ARESETN                 ,
                  avs_pcp_address       =>  address (10 downto 0)   ,
                  avs_pcp_byteenable    =>  byte_enable             ,
                  avs_pcp_read          =>  S_AXI_RREADY            ,
                  avs_pcp_READData      =>  S_AXI_RDATA             ,   --TODO:Check Direct Assign is fine or not
                  avs_pcp_write         =>  S_AXI_WVALID            ,
                  avs_pcp_writedata     =>  S_AXI_WDATA             ,    --TODO:Check Direct Assign is fine or not
                  avs_pcp_waitrequest   =>  open                        --TODO: No need of wait request
                 );

end implementation;