
module avalon_slave #
    (
    //TODO: add Parameters Here
    parameter       BASEADDRESS = 32'h0000_0000,
    parameter       ADD_DATA_WIDTH = 32
    )
    (
     input  wire       iClk                 ,
     input  wire        nReset              ,

     input  wire    [10:0]  avs_pcp_address ,
        // Avalon-MM slave pcp byteenable
     input  wire    [3:0]   avs_pcp_byteenable  ,
        // Avalon-MM slave pcp read
     input  wire            avs_pcp_read        ,
        // Avalon-MM slave pcp readdata
     output reg     [31:0]  avs_pcp_readdata    ,
        // Avalon-MM slave pcp write
     input  wire            avs_pcp_write       ,
        // Avalon-MM slave pcp writedata
     input  wire    [31:0]  avs_pcp_writedata   ,
        //Avalon-MM slave pcp waitrequest
     output wire            avs_pcp_waitrequest
    );


// Registers Declcarations
reg   [31:0]  slave_reg0    =   32'h0000_0000      ;
reg   [31:0]  slave_reg1    =   32'h0000_0000      ;
reg   [31:0]  slave_reg2    =   32'h0000_0000      ;
reg   [31:0]  slave_reg3    =   32'h0000_0000      ;


assign avs_pcp_waitrequest = avs_pcp_write || avs_pcp_read ;
//Read Registers
always @ (posedge iClk)
begin
    if(nReset == 1'b0)
    begin
      //TODO: Reset the Registers to default value
    end
    else if( avs_pcp_read == 1'b1 )
    begin
       //TODO: Integrate Byte Enable
       case  (avs_pcp_address [7:0])
       8'h00 : avs_pcp_readdata <= slave_reg0  ;
       8'h04 : avs_pcp_readdata <= slave_reg1  ;
       8'h08 : avs_pcp_readdata <= slave_reg2  ;
       8'h0C : avs_pcp_readdata <= slave_reg3  ;
       default:
       begin
        //TODO:
            avs_pcp_readdata <= 32'hDEAD_BEEF  ;
        end
       endcase
    end
    else
    begin
        //Free Readdata
       avs_pcp_readdata <= 32'hABCD_ABCD;
    end

end

//Write Registers
always @ (posedge iClk)
begin

    if(nReset == 1'b0)
    begin
      //TODO: Reset the Registers to default value
    end
    else if( avs_pcp_write == 1'b1 )
    begin
       //TODO: Integrate Byte Enable
       case  (avs_pcp_address [7:0])
       8'h00 : slave_reg0 <= avs_pcp_writedata ;
       8'h04 : slave_reg1 <= avs_pcp_writedata ;
       8'h08 : slave_reg2 <= avs_pcp_writedata ;
       8'h0C : slave_reg3 <= avs_pcp_writedata ;
       default:
       begin
        //TODO:
        end
       endcase
    end
    else
    begin
        //Hold the Data
       slave_reg0 <= slave_reg0 ;
       slave_reg1 <= slave_reg1 ;
       slave_reg2 <= slave_reg2 ;
       slave_reg3 <= slave_reg3 ;
    end
end
endmodule