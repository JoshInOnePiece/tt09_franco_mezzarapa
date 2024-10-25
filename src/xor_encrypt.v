module xor_encrypt(
    input iClk,       
    input iRst,       
    input iEn,
    input [63:0] iMessage,   // Input message (plaintext)
    input [7:0] iKey,        // XOR key
    input [$clog2(64):0] iMessage_bit_counter,
    input [$clog2(8):0] iKey_bit_counter,
    output reg encryption_status,
    output reg [$clog2(64) - 1:0] OCiphertext_counter,    // Ciphertext counter
    output reg [63:0] oCiphertext            // Ciphertext output
);

always @(posedge iClk or negedge iRst) begin
    if (!iRst) begin
        OCiphertext_counter <= 6'b000000;          // Reset counter to 0
        oCiphertext <= 64'h0000000000000000;       // Initialize ciphertext to zero
    end else if (iEn && OCiphertext_counter < 64) begin
        // Process the message in chunks of 8 bits only if counter is below 64
        if (iMessage_bit_counter == 64 && iKey_bit_counter == 8) begin
            encryption_status <= 1'b1; //Enable encryption status signal for CW if needed.
        
            // XOR each 8 bits of the message with the key
            oCiphertext[OCiphertext_counter * 8 +: 8] <= iMessage[OCiphertext_counter * 8 +: 8] ^ iKey;
            OCiphertext_counter <= OCiphertext_counter + 1;   // Increment the counter
            
            if (OCiphertext_counter == 6'h3F) begin
                OCiphertext_counter <= OCiphertext_counter;
                encryption_status <= 1'b0; //DISABLE encryption status signal for CW if needed. 
            end
        end        
    end
end

endmodule
