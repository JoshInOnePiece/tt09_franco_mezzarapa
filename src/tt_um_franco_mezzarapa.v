module tt_um_franco_mezzarapa(

//     input  clk,             // input clock.
//     input  rst_n,             // input Reset Signal.
//     input  ena,
//     input  iSerial_in,       // input Serial In.
//     input  iLoad_key,        // input load key flag.
//     input  iLoad_msg,        // input load msg flag.
//     output encryption_status, 
//     output oSerial_out,
//     output oSerial_flag

    input clk,              // External clock
    input ena,              // Enable line
    input rst_n,            // Active low enable.
    input  [7:0] ui_in,     // Inpute wire array
    output [7:0] uo_out,    // Output wire array
    
    input [7:0] uio_in,     // Unused
    output [7:0] uio_out,   // Unused
    output [7:0] uio_oe     // Unused
);

// Original IO.
wire iRst;
wire iSerial_in;
wire iLoad_key;
wire iLoad_msg;
wire oEncryption_status;
wire oSerial_out;
wire oSerial_flag;

//Input assign with repsect to TT.
assign iClk = clk;
assign iRst = ~rst_n;
assign iEn = ena;
assign iSerial_in = ui_in[0];
assign iLoad_key = ui_in[1];
assign iLoad_msg = ui_in[2];

// Output assign with respect to TT
assign uio_out[0] = oSerial_out;
assign uio_out[1] = oSerial_flag;
assign uio_out[2] = oEncryption_status;


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
    .encryption_status(oEncryption_Status),
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
