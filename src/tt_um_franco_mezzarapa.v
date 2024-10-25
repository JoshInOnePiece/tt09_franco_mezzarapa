module tt_um_franco_mezzarapa(
    input  clk,             // input clock.
    input  rst_n,             // input Reset Signal.
    input  ena,
    input  iSerial_in,       // input Serial In.
    input  iLoad_key,        // input load key flag.
    input  iLoad_msg,        // input load msg flag.
    output encryption_status, 
    output oSerial_out,
    output oSerial_flag
);

wire [63 : 0] message_content;      // This holds message plaintext.
wire [7  : 0] key;                  // xor key used. 
wire [63 : 0] ciphertext;

wire [$clog2(64)  : 0] message_bit_counter;    // position counter for message. - 6 bits total.
wire [$clog2(64)  : 0] ciphertext_bit_counter; //  position counter for ciphertext - 6 bits total.
wire [$clog2(8)   : 0] key_bit_counter;        // position counter for key.      - 2 bits total.

deserializer #(.DATA_SIZE(8)) deserializer_key(
     .iClk(clk),
     .iRst(rst_n),
     .iEn(ena),
     .iSerial_in(iSerial_in),
     .iLoad_flag(iLoad_key),
     .oData(key),
     .oBit_counter(key_bit_counter)
);

deserializer #(.DATA_SIZE(64)) deserializer_message(
     .iClk(clk),
     .iRst(rst_n),
     .iEn(ena),
     .iSerial_in(iSerial_in),
     .iLoad_flag(iLoad_msg),
     .oData(message_content),
     .oBit_counter(message_bit_counter)
);

xor_encrypt encryption_module(
    .iClk(clk),       
    .iRst(rst_n),       
    .iEn(ena),
    .iMessage(message_content),
    .iKey(key),
    .iMessage_bit_counter(message_bit_counter),
    .iKey_bit_counter(key_bit_counter),
    .encryption_status(encryption_status),
    .OCiphertext_counter(ciphertext_bit_counter),
    .oCiphertext(ciphertext)
);

serialize #(.MSG_SIZE(64)) serializer_unit(
     .iEn(ena),
     .iClk(clk),
     .iRst(rst_n),
     .iCiphertext_counter(ciphertext_bit_counter),        // Position counter for START OF serial operations.
     .iCiphertext(ciphertext),                            // Ciphertext
     .oSerial_out(oSerial_out),                           // Serial output
     .oSerial_flag(oSerial_flag)                          // Serial status flag for receiving chip.
);

endmodule
