module serialize #(parameter MSG_SIZE = 64)(
    input iEn,
    input iClk,
    input iRst,
    input [$clog2(MSG_SIZE) - 1:0] iCiphertext_counter,
    input [MSG_SIZE - 1:0] iCiphertext,
    output reg oSerial_out,
    output reg oSerial_flag
);

integer serialized_counter;
reg done_serializing;

always @(posedge iClk or negedge iRst) begin
    if (!iRst) begin
        // Reset condition
        oSerial_out <= 1'b0;
        oSerial_flag <= 1'b0;
        serialized_counter <= MSG_SIZE - 1; // Start from the MSB
        done_serializing <= 0;
    end else if (iEn && iCiphertext_counter == MSG_SIZE - 1 && !done_serializing) begin
        if (serialized_counter >= 0) begin
            // Still serializing: send out ciphertext bit by bit
            oSerial_flag <= 1;
            oSerial_out <= iCiphertext[serialized_counter]; // Output current bit
            serialized_counter <= serialized_counter - 1; // Move to next bit
        end
        
        // Once the last bit is done, keep the flag high for one more cycle
        if (serialized_counter == -1) begin
            oSerial_flag <= 0; // Clear the flag AFTER the last bit is processed
            done_serializing <= 1; // Set flag indicating serialization is done
        end
    end
end

endmodule
