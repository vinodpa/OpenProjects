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

    iAvalonRead          :   in      std_logic                                               ;
    iAvalonWrite         :   in      std_logic                                               ;
    iAvalonAddr          :   in      std_logic_vector   (31 downto 0)                        ;
    iAvalonBE            :   in      std_logic_vector   (3 downto 0)                         ;
    oAvalonWaitReq       :   out     std_logic                                               ; --TODO: Check this part
    oAvalonReadValid     :   out     std_logic                                               ;
    oAvalonReadData      :   out     std_logic_vector   (31 downto 0)                        ;
    iAvalonWriteData     :   in      std_logic_vector   (31 downto 0)
    );

end axi_lite_master_wrapper;

architecture Behavioral of axi_lite_master_wrapper is

type state  is (sINIT,sAWVALID,sWVALID,sBREADY,sARVALID,sRREADY,sWRITE_DONE,sREAD_DONE);
signal  StateCurrent    :    state      ;
signal  StateNext       :    state      ;

--  Handle Avalon Master
    signal  start_transfer  :    std_logic  ;
    signal  done_transfer   :    std_logic  ;
	signal  RReady			:    std_logic  ;
	
	signal	rd_done			:    std_logic  ;

begin
--AXI Master Operations

    M_AXI_AWPROT    <= "000"   ;
    M_AXI_ARPROT    <= "000"    ;

    M_AXI_AWADDR    <= iAvalonAddr ;
    M_AXI_ARADDR    <= iAvalonAddr ;
    M_AXI_WDATA     <= iAvalonWriteData ;
    M_AXI_WSTRB     <= iAvalonBE  ;
--TODO: Read strobe ?

    M_AXI_AWVALID   <=  '1' when iAvalonWrite = '1' else
                        '1' when StateCurrent = sAWVALID else
                        '0';

    M_AXI_WVALID    <=  '1' when iAvalonWrite = '1' else
                        '1' when StateCurrent = sAWVALID else
                        '1' when StateCurrent = sWVALID else
                        '0';

    M_AXI_BREADY    <=  '1' when StateCurrent = sWRITE_DONE else
                        '0';

    M_AXI_ARVALID   <=  '1' when iAvalonRead = '1' else
                        '1' when StateCurrent =  sARVALID else
                        '0' ; 
    M_AXI_RREADY    <=  '1' when StateCurrent = sREAD_DONE else
                        '0';
  
--  Read Data Valid
    oAvalonReadValid <=  M_AXI_RVALID    ;
--  Read Data
    oAvalonReadData  <=   M_AXI_RDATA    ;

--  Wait Request
--  Combinational Feedback through a flop //TODO: Check wethert its create dead loops
    oAvalonWaitReq <= '0' when done_transfer = '1' else
                      '1' when  start_transfer = '1' else
                      '0' ;

--
--
	RReady			<= '1' when StateCurrent = sREAD_DONE else
					   '0'
	
    start_transfer  <=   (iAvalonRead and not RReady) or iAvalonWrite      ;
    done_transfer   <=   M_AXI_WREADY or (M_AXI_RVALID and RReady) or rd_done   ;
	
	process (M_AXI_ACLK, M_AXI_ARESETN)
    begin
     if rising_edge (M_AXI_ACLK) then
      if(M_AXI_ARESETN = '0') then
        rd_done <= '0'    ;
      else
        rd_done <= (M_AXI_RVALID and RReady)  ;
      end if;
     end if;
    end process;
	
-- Master FSM	
-- Sequenctial Logics
    process (M_AXI_ACLK, M_AXI_ARESETN)
    begin
     if rising_edge (M_AXI_ACLK) then
      if(M_AXI_ARESETN = '0') then
        StateCurrent <= sINIT    ;
      else
        StateCurrent <= StateNext ;
      end if;
     end if;
    end process;
-- Combinational Logics
    process (
               StateCurrent,
               iAvalonRead,
               iAvalonWrite,
               M_AXI_AWREADY,
               M_AXI_WREADY,
               M_AXI_BVALID,
               M_AXI_ARREADY,
               M_AXI_RVALID
            )
    begin
        StateNext <= StateCurrent ;
        case (StateCurrent) is 
         when sINIT =>
            if (iAvalonRead = '1') then
                StateNext   <= sARVALID ;
					elsif (iAvalonWrite = '1') then
                StateNext   <= sAWVALID ;
            else
                StateNext <= sINIT ;
            end if;
         when sAWVALID =>
            if(M_AXI_AWREADY = '1') then
                if (M_AXI_WREADY = '1') then
                    if (M_AXI_BVALID = '1') then
                        StateNext   <= sWRITE_DONE ;
                    else
                        StateNext   <= sBREADY ;
                    end if;
                else
                    StateNext   <= sWVALID ;
                end if;
            else
                StateNext   <= sAWVALID ;
            end if;

         when sWVALID  =>
            if (M_AXI_WREADY = '1') then
                if (M_AXI_BVALID = '1') then
                StateNext   <= sWRITE_DONE ;
                else
                StateNext   <= sBREADY ;
                end if;
            else
                StateNext   <= sWVALID ;
            end if;
         when sBREADY  =>
            if (M_AXI_BVALID = '1') then
                StateNext   <= sWRITE_DONE ;
            else
                StateNext   <= sBREADY ;
            end if;
         when sARVALID =>
            if(M_AXI_ARREADY = '1') then
                if(M_AXI_RVALID = '1') then
                    StateNext   <= sREAD_DONE ;
                else
                    StateNext   <= sRREADY ;
                end if;
            else
                StateNext   <= sARVALID ;
            end if;
         when sRREADY  =>
            if(M_AXI_RVALID = '1') then
                StateNext   <= sREAD_DONE ;
            else
                StateNext   <= sRREADY ;
            end if;
         when sWRITE_DONE    =>
                StateNext <= sINIT ;
         when sREAD_DONE    =>
                StateNext <= sINIT ;
         when others => null;
        end case;
    end process;

end Behavioral;



