-------------------------------------------------------------------------------
--! @file axiLiteMasterWrapper-rtl-ea.vhd
--
--! @brief AXI lite master wrapper on avalon master interface signals
--
--! @details This will convert avalon master interface signals to AXI master
--! interface signals.
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
-- Version History
-------------------------------------------------------------------------------
-- 2014-01-13   Vinod PA    Added AXI-Lite warpper for Avalon master
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.global.all;

--TODO: update the description
-------------------------------------------------------------------------------
--! @brief AXI lite master wrapper on avalon master interface signals
--
--! @details This will convert avalon master interface signals to AXI master
--! interface signals. An Finite tFsm Machine with 8 states (sINIT,sAWVALID,
--! sWVALID,sBREADY,sARVALID,sRREADY,sWRITE_DONE,sREAD_DONE) are used for
--! control the transitions of signals on both Avalon & AXI interface.
-------------------------------------------------------------------------------

entity axiLiteMasterWrapper is
    generic (
        --! Address width for AXI bus interface
        gAddrWidth          : integer := 32;
        --! Data width for AXI bus interface
        gDataWidth          : integer := 32
    );
    port (
        --! Global Clock for AXI
        iAclk               : in    std_logic;
        --! Global Reset for AXI
        inAReset            : in    std_logic;
        --! Address for Write Address Channel
        oAwaddr             : out   std_logic_vector(gAddrWidth-1 downto 0);
        --! Protection for Write Address Channel
        oAwprot             : out   std_logic_vector(2 downto 0);
        --! AddressValid for Write Address Channel
        oAwvalid            : out   std_logic;
        --! AddressReady for Write Address Channel
        iAwready            : in    std_logic;
        --! WriteData for Write Data Channel
        oWdata              : out   std_logic_vector(gDataWidth-1 downto 0);
        --! WriteStrobe for Write Data Channel
        oWstrb              : out   std_logic_vector(gDataWidth/8-1 downto 0);
        --! WriteValid for Write Data Channel
        oWvalid             : out   std_logic;
        --! WriteReady for Write Data Channel
        iWready             : in    std_logic;
        --! WriteLast for Write Data Channel to indicate last write operations
        oWlast              : out   std_logic;
        --! WriteResponse for Write Response Channel
        iBresp              : in    std_logic_vector(1 downto 0);
        --! ResponseValid for Write Response Channel
        iBvalid             : in    std_logic;
        --!  ResponaseReady for Write Response Channel
        oBready             : out   std_logic;
        --! ReadAddress for Read Adddress Channel
        oAraddr             : out   std_logic_vector(gAddrWidth-1 downto 0);
        --! ReadAddressProtection for Read Address Channel
        oArprot             : out   std_logic_vector(2 downto 0);
        --! ReadAddressValid for Read Address Channel
        oArvalid            : out   std_logic;
        --! ReadAddressReady for Read Address Channel
        iArready            : in    std_logic;
        --! ReadData for Read Data Channel
        iRdata              : in    std_logic_vector(gDataWidth-1 downto 0);
        --! ReadResponse for Read Data Channel
        iRresp              : in    std_logic_vector(1 downto 0);
        --! ReadValid for Read Data Channel
        iRvalid             : in    std_logic;
        --! ReadReady for Read Dara Channel
        oRready             : out   std_logic;
        --! Read signal for Avalon Master Interface
        iAvalonRead         : in    std_logic;
        --! Write Signal for Avalon Master interface
        iAvalonWrite        : in    std_logic;
        --! Address for Avalon Master Interface
        iAvalonAddr         : in    std_logic_vector(gAddrWidth-1 downto 0);
        --! Byte Enable for Avalon Master interface
        iAvalonBE           : in    std_logic_vector(3 downto 0);
        --! Wait request for Avalon Master Interface
        oAvalonWaitReq      : out   std_logic;
        --! Wait Request for Avalon Master Interface
        oAvalonReadValid    : out   std_logic;
        --! Read Data for Avalon Master Interface
        oAvalonReadData     : out   std_logic_vector(gDataWidth-1 downto 0);
        --! Write Data for Avaon Master Interface
        iAvalonWriteData    : in    std_logic_vector(gDataWidth-1 downto 0)
    );
end axiLiteMasterWrapper;

architecture rtl of axiLiteMasterWrapper is
    --! Axi lite master FSM type
    type tFsm is (
        sINIT,
        sAWVALID,
        sWVALID,
        sBREADY,
        sARVALID,
        sRREADY,
        sWRITE_DONE,
        sREAD_DONE
    );

    signal fsm      : tFsm;
    signal fsm_next : tFsm;

    --  Handle Avalon Master
    signal start_transfer   : std_logic ;
    signal done_transfer    : std_logic ;
    signal RReady           : std_logic ;
    signal writeOp_done     : std_logic ;
    signal readOp_done      : std_logic ;
    signal readData         : std_logic_vector(31 downto 0);
begin

    --AXI Master Signals
    oAwprot <= "000";
    oArprot <= "000";
    oAwaddr <= iAvalonAddr;
    oAraddr <= iAvalonAddr;
    oWdata  <= iAvalonWriteData;
    -- Only read or write at a time and Read will always 32bit
    oWstrb  <= iAvalonBE;

    -- Memory operations (AXI4) demands presence of WLAST (active for last data)
    oWlast  <=  cActivated;

    oAwvalid <= cActivated when fsm = sINIT and iAvalonWrite = cActivated else
                cActivated when fsm = sAWVALID else
                cInactivated;

    oWvalid <=  cActivated when fsm = sINIT and iAvalonWrite = cActivated else
                cActivated when fsm = sAWVALID else
                cActivated when fsm = sWVALID else
                cInactivated;

    oBready <=  cActivated when fsm = sWRITE_DONE else
                cActivated when fsm = sBREADY else
                cInactivated;

    oArvalid <= cActivated when iAvalonRead = cActivated else
                cActivated when fsm =  sARVALID else
                cInactivated;

    oRready <=  cActivated when fsm = sREAD_DONE else
                cInactivated;

    -- Avalon Interface Signals
    oAvalonReadValid    <= iRvalid;
    oAvalonReadData     <= readData;

    readData <= iRdata when iRvalid = cActivated else
                readData; --FIXME: This is a crazy latch! Use register for storing!!!

    oAvalonWaitReq <=   cActivated when start_transfer = cActivated else
                        cInactivated when done_transfer = cActivated else
                        cInactivated;

    -- Internal Signals for Read Ready
    RReady <=   cActivated when fsm = sREAD_DONE else
                cInactivated;

    -- Start of Operations
    start_transfer <=   cInactivated when done_transfer = cActivated else
                        (iAvalonRead and not RReady) or iAvalonWrite; --TODO: Split it to multiple logics

    -- Completion of Read/Write Operations
    done_transfer <= writeOp_done or readOp_done;

    writeOp_done <= cActivated when fsm = sWRITE_DONE else
                    cInactivated;

    readOp_done <=  cActivated when fsm = sREAD_DONE else
                    cInactivated;

    -- Master FSM
    --TODO: Explain logic if possible with Diagram in doxygen
    --! Clock Based Process for tFsm changes
    SEQ_LOGIC : process(iAclk)
    begin
        if rising_edge (iAclk) then
            if inAReset = cnActivated then
                fsm <= sINIT;
            else
                fsm <= fsm_next;
            end if;
        end if;
    end process SEQ_LOGIC;

    -- Combinational Logics
    -- --TODO: Explain logic if possible with Diagram in doxygen
    --! Control based Process for tFsm updation
    COMB_LOGIC : process (
        fsm,
        iAvalonRead,
        iAvalonWrite,
        iAwready,
        iWready,
        iBvalid,
        iArready,
        iRvalid
    )
    begin
        -- Default Values for signals
        fsm_next <= fsm ;

        case fsm is
            when sINIT =>
            -- Read Operations
            if iAvalonRead = cActivated then
                fsm_next <= sARVALID;
                if iArready = cActivated then
                    if iRvalid = cActivated then
                        fsm_next <= sREAD_DONE;
                    else
                        fsm_next <= sRREADY;
                    end if;
                else
                    fsm_next <= sARVALID;
                end if;
            -- Write Operations
            elsif iAvalonWrite = cActivated then
                fsm_next <= sAWVALID;
                if iAwready = cActivated then
                    if iWready = cActivated then
                        if iBvalid = cActivated then
                            fsm_next <= sWRITE_DONE;
                        else
                            fsm_next <= sBREADY;
                        end if;
                    else
                        fsm_next <= sWVALID;
                    end if;
                else
                    fsm_next <= sAWVALID;
                end if;
            else
                fsm_next <= sINIT;
            end if;

            when sAWVALID =>
                if iAwready = cActivated then
                    if iWready = cActivated then
                        if iBvalid = cActivated then
                            fsm_next <= sWRITE_DONE;
                        else
                            fsm_next <= sBREADY;
                        end if;
                    else
                        fsm_next <= sWVALID;
                    end if;
                else
                    fsm_next <= sAWVALID;
                end if;

            when sWVALID =>
                if iWready = cActivated then
                    if iBvalid = cActivated then
                        fsm_next <= sWRITE_DONE;
                    else
                        fsm_next <= sBREADY;
                    end if;
                else
                    fsm_next <= sWVALID;
                end if;

            when sBREADY =>
                if iBvalid = cActivated then
                    fsm_next <= sWRITE_DONE;
                else
                    fsm_next <= sBREADY;
                end if;

            when sARVALID =>
                if iArready = cActivated  then
                    if iRvalid = cActivated then
                        fsm_next <= sREAD_DONE;
                    else
                        fsm_next <= sRREADY;
                    end if;
                else
                    fsm_next <= sARVALID;
                end if;

            when sRREADY =>
                if iRvalid = cActivated then
                    fsm_next <= sREAD_DONE;
                else
                    fsm_next <= sRREADY;
                end if;

            when sWRITE_DONE =>
                fsm_next <= sINIT;

            when sREAD_DONE =>
                fsm_next <= sINIT;

            when others =>
                null;
        end case;
    end process COMB_LOGIC;
end rtl;
