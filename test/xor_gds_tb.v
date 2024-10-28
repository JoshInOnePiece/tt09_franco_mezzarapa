`timescale 1ns / 1ps

module xor_gds_tb;

    // Input control signals
    reg iClk;
    reg iRst;
    reg iEn;

    reg [7:0] ui_in;     // Input wire array
    wire [7:0] uo_out;    // Output wire array

    reg [7:0] uio_in;     // Unused
    wire [7:0] uio_out;   // Unused
    wire [7:0] uio_oe;    // Unused

    reg [7:0] key;
    reg [63:0] message;

    reg [63:0] ciphertext;
    
    integer i;

    // Clock generation (10 MHz)
    localparam CLOCK_PERIOD = 100; // 10 MHz -> T = 1/10MHz = 100 ns
    initial iClk = 0;
    always #(CLOCK_PERIOD / 2) iClk = ~iClk; // Toggle clock every half period

    // Instantiate the top module
    tt_um_franco_mezzarapa uut (
        .clk(iClk),         // Clock
        .ena(iEn),          // Enable
        .rst_n(iRst),       // Reset (active low)
        .ui_in(ui_in),      // Input array (0 is serial line, 1 is key, 2 is msg)
        .uo_out(uo_out),    // Output array (0 is serial line, 1 is out stat, 2 is encrypt stat.)
        .uio_in(uio_in),    // Unused
        .uio_out(uio_out),  // Unused
        .uio_oe(uio_oe)     // Unused
    );

    // Test sequence
    initial begin
        // Initialize inputs
        iClk = 0;
        iRst = 0;    // Reset is active low, so 1 means reset is inactive here
        iEn = 0;
        ui_in = 8'b00000000;
        ciphertext = 0;
        
        // Load a test key and message
        key = 8'hA5;                  // 8-bit key
        message = 64'hA3B1F9D2E7C6A594;  // 64-bit message

        // Apply reset
        #(CLOCK_PERIOD);
        iRst = 1;                     // Activate reset
        #(CLOCK_PERIOD);
        iRst = 0;                     // Deactivate reset
        iEn = 1;                      // Enable

        // Load key
        #(CLOCK_PERIOD);
        ui_in[1] = 1;                 // Set iLoad_Key signal
        for (i = 0; i < 8; i = i + 1) begin
            ui_in[0] = key[i];        // Load key bit-by-bit
            #(CLOCK_PERIOD);
        end
        ui_in[1] = 0;                 // Clear iLoad_Key signal

        // Load message
        #(CLOCK_PERIOD);
        ui_in[2] = 1;                 // Set iLoad_msg signal
        for (i = 0; i < 64; i = i + 1) begin
            ui_in[0] = message[i];    // Load message bit-by-bit
            #(CLOCK_PERIOD);
        end
        ui_in[2] = 0;                 // Clear iLoad_msg signal

        while(uo_out[1]) begin
            ciphertext = (ciphertext << 1);
            
            // Capture the current bit from uo_out[0]
            ciphertext[0] = uo_out[0];
        end 
        
        // Wait for encryption to complete and observe outputs
        #(5 * CLOCK_PERIOD);

        // End of test
        $finish;
    end
endmodule
