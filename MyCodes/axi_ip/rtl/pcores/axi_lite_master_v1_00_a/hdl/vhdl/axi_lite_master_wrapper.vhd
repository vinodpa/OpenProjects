library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity axi_lite_master_wrapper is
generic
    (
    C_M_AXI_ADDR_WIDTH : integer                       := 32;
    C_M_AXI_DATA_WIDTH : integer                       := 32
    );

port
    (
    -- System Signals
    M_AXI_ACLK          :   in      std_logic                                               ;
    M_AXI_ARESETN       :   in      std_logic                                               ;

    -- Master Interface Write Address
    M_AXI_AWADDR        :   out     std_logic_vector   (C_M_AXI_ADDR_WIDTH-1 downto 0)      ;
    M_AXI_AWPROT        :   out     std_logic_vector   (3-1 downto 0)                       ;
    M_AXI_AWVALID       :   out     std_logic                                               ;
    M_AXI_AWREADY       :   in      std_logic                                               ;

    -- Master Interface Write Data
    M_AXI_WDATA         :   out     std_logic_vector   (C_M_AXI_DATA_WIDTH-1 downto 0)      ;
    M_AXI_WSTRB         :   out     std_logic_vector   (C_M_AXI_DATA_WIDTH/8-1 downto 0)    ;
    M_AXI_WVALID        :   out     std_logic                                               ;
    M_AXI_WREADY        :   in      std_logic                                               ;

    -- Master Interface Write Response
    M_AXI_BRESP         :   in      std_logic_vector   (2-1 downto 0)                       ;
    M_AXI_BVALID        :   in      std_logic                                               ;
    M_AXI_BREADY        :   out     std_logic                                               ;

    -- Master Interface Read Address
    M_AXI_ARADDR        :   out     std_logic_vector   (C_M_AXI_ADDR_WIDTH-1 downto 0)      ;
    M_AXI_ARPROT        :   out     std_logic_vector   (3-1 downto 0)                       ;
    M_AXI_ARVALID       :   out     std_logic                                               ;
    M_AXI_ARREADY       :   in      std_logic                                               ;

    -- Master Interface Read Data
    M_AXI_RDATA         :   in      std_logic_vector   (C_M_AXI_DATA_WIDTH-1 downto 0)      ;
    M_AXI_RRESP         :   in      std_logic_vector   (2-1 downto 0)                       ;
    M_AXI_RVALID        :   in      std_logic                                               ;
    M_AXI_RREADY        :   out     std_logic                                               ;

    avalonRead          :   in      std_logic                                               ;
    avalonWrite         :   in      std_logic                                               ;
    avalonAddr          :   in      std_logic_vector   (31 downto 0)                        ;
    avalonBE            :   in      std_logic_vector   (3 downto 0)                         ;
    avalonBeginTransfer :   in      std_logic                                               ;
    avalonWaitReq       :   out     std_logic                                               ; --TODO: Check this part
    avalonReadValid     :   out     std_logic                                               ;
    avalonReadData      :   out     std_logic_vector   (31 downto 0)                        ;
    avalonWriteData     :   in      std_logic_vector   (31 downto 0)
    );

end axi_lite_master_wrapper;

architecture Behavioral of axi_lite_master_wrapper is

    type state  is (A,B,C)      ;
    type state1 is (A1,B1,C1)   ;
    type state2 is (A2,B2,C2)   ;
    type state3 is (A3,B3,C3)   ;
    type state4 is (A4,B4,C4)   ;

--  Write Address Channel
    signal  Awvalid         :    std_logic  ;
    signal  wAwvaliD        :    std_logic  ;

--  Write Data Channel
    signal  Wvalid          :    std_logic  ;
    signal  wWvalid         :    std_logic  ;

--  Write Response Channel
    signal  Bready          :    std_logic  ;
    signal  wBready         :    std_logic  ;

--  Read Address Channel
    signal  Arvalid         :    std_logic  ;
    signal  wArvalid        :    std_logic  ;

--  Read Data Channel
    signal  Rready          :    std_logic  ;
    signal  wRready         :    std_logic  ;

--  Handle Avalon Master
    signal  start_transfer  :    std_logic  ;
    signal  done_transfer   :    std_logic  ;
    signal  StateCurrent    :    state      ;
    signal  StateNext       :    state      ;
    signal  State1Current   :    state1     ;
    signal  State1Next      :    state1     ;
    signal  State2Current   :    state2     ;
    signal  State2Next      :    state2     ;
    signal  State3Current   :    state3     ;
    signal  State3Next      :    state3     ;
    signal  State4Current   :    state4     ;
    signal  State4Next      :    state4     ;


begin
--AXI Write Operations

    M_AXI_WVALID    <=  wWvalid   ;
    M_AXI_AWVALID   <=  wAwvalid  ;
    M_AXI_BREADY    <=  wBready   ;

--  AXI Read Operations

    M_AXI_ARVALID   <=  wArvalid  ;
    M_AXI_RREADY    <=  wRready   ;

--  Address & Data Valid AWVALID & WVALID
--  TODO: Combinational Feedback on systems , Not a good Idea ?
--  AWValid Handling

AWVALID_HANDLE:
    process (State2Current)
    begin
        if (State2Current = B2)
        then
            wAwvalid    <=  '1' ;
        else
            wAwvalid    <=  '0' ;
        end if  ;
    end process ;
RESET_CHECK:
    process (M_AXI_ACLK)
    begin
        if (rising_edge(M_AXI_ACLK))
        then
        if(M_AXI_ARESETN = '0')
        then
            State2Current <= A2          ;
        else
            State2Current <= State2Next  ;
        end if  ;
        end if  ;
    end process ;

STATE2_FSM:
    process (State2Current,avalonWrite,M_AXI_AWREADY)
    begin
        case (State2Current) is
            when A2 =>
                if (avalonWrite = '1')
                then
                    State2Next <= B2   ;
                else
                    State2Next <= A2   ;
                end if  ;
            when B2 =>
                if (M_AXI_AWREADY = '1')
                then
                    State2Next <= C2   ;
                else
                    State2Next <= B2   ;
                end if  ;
            when C2 =>
                State2Next <= A2   ;
            when others =>

        end case ;
    end process ;

--  WValid Handling
--
WRITE_VALID_HANDLE:
    process (State3Current)
    begin
        if (State3Current = B3)
        then
            wWvalid    <=  '1' ;
        else
            wWvalid    <=  '0' ;
        end if  ;
    end process ;

    process (M_AXI_ACLK)
    begin
        if (rising_edge(M_AXI_ACLK))
        then
        if(M_AXI_ARESETN = '0')
        then
            State3Current <= A3;
        else
            State3Current <= State3Next ;
        end if  ;
        end if  ;
    end process ;

STATE3_FSM:
    process (State3Current, avalonWrite ,M_AXI_WREADY)
    begin
        case (State3Current)is
            when A3 =>
                if (avalonWrite  = '1' )
                then
                    State3Next <= B3   ;
                else
                    State3Next <= A3   ;
                end if  ;
            when B3 =>
                if (M_AXI_WREADY  = '1' )
                then
                    State3Next <= C3   ;
                else
                    State3Next <= B3   ;
                end if  ;
            when C3 =>
                State3Next <= A3;
            when others =>
        end case ;
    end process ;

--  Write Response Handling
WRITE_RESP_HANDLE:
    process (State4Current)
    begin
        if (State4Current = B4)
        then
            wBready    <=  '1' ;
        else
            wBready    <=  '0' ;
        end if  ;
    end process ;

    process ( M_AXI_ACLK )
    begin
        if (rising_edge( M_AXI_ACLK ))
        then
        if(M_AXI_ARESETN = '0')
        then
            State4Current <= A4         ;
        else
            State4Current <= State4Next ;
        end if  ;
        end if  ;
    end process ;

STATE4_FSM:
    process (State4Current, avalonWrite, M_AXI_BVALID)
    begin
        case (State4Current) is
            when A4 =>
                if (avalonWrite  = '1')
                then
                    State4Next <= B4   ;
                else
                    State4Next <= A4   ;
                end if  ;
            when B4 =>
                if (M_AXI_BVALID  = '1')
                then
                    State4Next <= C4   ;
                else
                    State4Next <= B4   ;
                end if  ;
            when C4 =>
                State4Next <= A4;
            when others =>
         end case ;
    end process ;

--  AXI Read Signal Handling
--  ARValid handling

--  TODO: ????
--
ADDR_READ_HANDLE:
    process (StateCurrent )
    begin
        if (StateCurrent = B)
        then
            wArvalid    <=  '1' ;
        else
            wArvalid    <=  '0' ;
        end if  ;
    end process ;

    process ( M_AXI_ACLK )
    begin
        if (rising_edge(M_AXI_ACLK))
        then
        if(M_AXI_ARESETN = '0')
        then
            StateCurrent <= A ;
        else
            StateCurrent <= StateNext ;
        end if ;
        end if ;
    end process ;

    process ( StateCurrent, avalonRead, M_AXI_ARREADY)
    begin
        case (StateCurrent) is
            when A =>
                if (avalonRead  = '1' )
                then
                    StateNext <= B ;
                else
                    StateNext <= A ;
                end if ;
            when B =>
                if (M_AXI_ARREADY  = '1' )
                then
                    StateNext <= C ;
                else
                    StateNext <= B ;
                end if ;
            when C =>
                StateNext <= A ;
            when others =>
        end case ;
    end process ;

    process ( M_AXI_ACLK )
    begin
        if (rising_edge(M_AXI_ACLK))
        then
        if (M_AXI_ARESETN = '0')
        then
            Arvalid <= '0' ;
        elsif (M_AXI_ARREADY  = '1')
        then
            Arvalid <= '0' ;
        elsif (avalonRead = '1')
        then
            Arvalid <= '1' ;
        else
            Arvalid <= Arvalid  ;
        end if ;
        end if ;
    end process ;

--  TODO: ????
--  RReady Handling
--
READ_READY_HANDLE:
    process (StateCurrent)
    begin
        if (StateCurrent = B1)
        then
            wRready    <=  '1' ;
        else
            wRready    <=  '0' ;
        end if  ;
    end process ;

    process ( M_AXI_ACLK )
    begin
        if (rising_edge(M_AXI_ACLK))
        then
        if(M_AXI_ARESETN = '0')
        then
            State1Current <= A1 ;
        else
            State1Current <= State1Next ;
        end if ;
        end if ;
    end process ;

STATE1_FSM:
    process ( State1Current,avalonRead,M_AXI_RVALID )
    begin
        case (State1Current) is
            when A1 =>
                if (avalonRead  = '1')
                then
                    State1Next <= B1   ;
                else
                    State1Next <= A1   ;
                end if ;
            when B1 =>
                if (M_AXI_RVALID = '1')
                then
                    State1Next <= C1   ;
                else
                    State1Next <= B1   ;
                end if ;
            when C1 =>
                State1Next <= A1       ;
            when others =>
         end case ;
     end process ;

    process (M_AXI_ACLK)
    begin
        if (rising_edge(M_AXI_ACLK))
        then
        if(M_AXI_ARESETN = '0')
        then
            Rready  <= '0' ;
        elsif ( M_AXI_RVALID = '1' )
        then
            Rready  <= '0' ;
            --Arvalid <= '0' ;
        elsif (avalonRead = '1')
        then
            Rready  <= '1' ;
            --Arvalid <= '1' ;
        else
            Rready  <= Rready   ;
            --Arvalid <= Arvalid ;
        end if ;
        end if ;
    end process ;


    start_transfer  <=   avalonRead or avalonWrite      ;

    done_transfer   <=   M_AXI_BVALID or M_AXI_RVALID   ;
--
--  Read Data Valid

    avalonReadValid <=  M_AXI_RVALID    ;

--  Read Data

    avalonReadData  <=   M_AXI_RDATA    ;

--  Wait Request
--  Combinational Feedback through a flop //TODO: Check wethert its create dead loops
AVALON_WAIT_REQ:
    process (done_transfer,start_transfer)
    begin
        if (done_transfer = '1' )
        then
            avalonWaitReq   <=  '0'  ;
        elsif (start_transfer = '1' )
        then
            avalonWaitReq   <=  '1'  ;
        else
            avalonWaitReq   <=  '0'  ;
        end if;
    end process;

--
--  Avalon Bus master Interface
--

    MASTER: entity work.avalon_master
            port map
                (
                  iClk                  =>  ACLK                    ,
                  iResetn               =>  ARESETN                 ,
                  avalonRead            =>  avalonRead              ,
                  avalonWrite           =>  avalonWrite             ,
                  avalonAddr            =>  avalonAddr              ,
                  avalonBE              =>  avalonBE                ,
                  avalonBeginTransfer   =>  avalonBeginTransfer     ,
                  avalonWaitReq         =>  avalonWaitReq           ,
                  avalonReadValid       =>  avalonReadValid         ,
                  avalonReadData        =>  avalonReadData          ,
                  avalonWriteData       =>  avalonWriteData
                 );

end Behavioral;



