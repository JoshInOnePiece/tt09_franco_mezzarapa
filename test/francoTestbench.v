`timescale 1ns / 1ps
module tt_um_franco_mezzarapa_tb();
//tb signals and variables.  
    reg [7:0] key;
    reg [63:0] message;
    integer i;
    
// tt inputs
    reg clk;
    reg rst_n;
    reg ena;
    reg [7:0] ui_in;
    reg [7:0] uio_in;

// tt outputs
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    wire [8 - 1: 0 ] oBit_counter;


    tt_um_franco_mezzarapa uut(
        .ui_in(ui_in),    // Dedicated inputs
        .uo_out(uo_out),   // Dedicated outputs
        .uio_in(uio_in),   // IOs: Input path
        .uio_out(uio_out),  // IOs: Output path
        .uio_oe(uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
        .ena(ena),      // always 1 when the design is powered
        .clk(clk),      // clock
        .rst_n(rst_n),     // reset_n - low to reset
        .oBit_counter(oBit_counter)
    );

    // Clock generation (10 MHz)
    localparam CLOCK_PERIOD = 100; // 10 MHz clock
    initial clk = 0;
    always #(CLOCK_PERIOD / 2) clk = ~clk; // Toggle clock every half period



    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        rst_n = 0;    // Reset is active low, so 1 means reset is inactive here
        ena = 0;
        ui_in = 8'b00000000;

        // Load a test key and message
        key = 8'hA5;                  // 8-bit key
        message = 64'hA3B1F9D2E7C6A594;  // 64-bit message

        // Initialize inputs
        ui_in = 8'b00000000;
        ena = 0;    // Disable during reset
        rst_n = 0;  // Apply reset (active low)
        # (CLOCK_PERIOD * 2);  // Hold reset
        rst_n = 1;  // Release reset
        ena = 1;    // Enable after reset
        // Continue with the rest of the test sequence
        
        // Load key
        #(CLOCK_PERIOD);
        ui_in[1] = 1;                 // Set iLoad_Key signal
        for (i = 0; i < 8; i = i + 1) begin
            ui_in[0] = key[i];        // Load key bit-by-bit
            #(CLOCK_PERIOD);
        end
        ui_in[1] = 0;    
end

    // Monitor outputs
    initial begin
        $monitor("Time: %0t | ui_in: %b | uo_out: %b", $time, ui_in, uo_out);
    end

endmodule