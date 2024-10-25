module deserializer #(parameter DATA_SIZE = 8)(
    input iClk,
    input iRst,
    input iEn,
    input iSerial_in,
    input iLoad_flag,
    output reg [DATA_SIZE - 1 : 0] oData,               //register spawn point for message and key
    output reg [$clog2(DATA_SIZE): 0 ] oBit_counter     //register spawn point for key and message bit counters.
);

always @(posedge iClk or negedge iRst) begin
    // Reset triggered when new message and key are sent.    
    if (!iRst) begin
        oData <= {DATA_SIZE{1'b0}};
        oBit_counter <= {$clog2(DATA_SIZE){1'b0}};
    
    end else if ( iEn && iLoad_flag) begin
        
        //I might be able to optimize here.
        if ( oBit_counter < DATA_SIZE) begin             // Check to see if all the bits have been shifted.
            oData <= {oData[DATA_SIZE-2:0], iSerial_in}; // Shift in the new bit
            oBit_counter <=  oBit_counter + 1;           // Update the counter.
        end
        
        
        if (oBit_counter == DATA_SIZE) begin
            oBit_counter <= oBit_counter;
        end
    end        
end
endmodule 