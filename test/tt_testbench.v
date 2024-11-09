`timescale 1ns / 1ps

module tt_testbench();

    // Signals
    reg clk;
    reg rst_n;
    reg ena;
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    
    // Control signals
    reg [7:0]  key;
    reg [63:0] message;
    reg [63:0] rebuilt_ciphertext; // Capture directly from uut.key
    reg [63:0] ciphertext;              // Computed ciphertext
    
    integer i;

    // Clock generation (10 MHz)
    localparam CLOCK_PERIOD = 100; // 10 MHz -> T = 1/10MHz = 100 ns
    initial clk = 0;
    always #(CLOCK_PERIOD / 2) clk = ~clk; // Toggle clock every half period

    // Instantiate the top module
    tt_um_franco_mezzarapa uut (
        .clk(clk),                    // Clock
        .ena(ena),                    // Enable
        .rst_n(rst_n),                // Reset (active low)
      
        // Unused connections
        .ui_in(ui_in),                // Input array (0 is serial line, 1 is key, 2 is msg)
        .uo_out(uo_out),              // Output array (0 is serial line, 1 is out stat, 2 is encrypt stat.)
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe)
    );

    // Initial setup
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 1;               // Reset is active low, so 1 means reset is inactive here
        ena = 0;
        ui_in = 8'b00000000;
        uio_in = 8'b00000000;
        
        key = 8'hA5;             // Example key value
        message = 64'hA3B1F9D2E7C6A594; // Initialize message value
        
        //enable and reset chip.
        ena = 1;
        #CLOCK_PERIOD;
        rst_n = 0;
        ena = 0;
        #CLOCK_PERIOD;
        rst_n = 1;
        ena = 1;
        
        // Load a test key and message
        key = 8'hA5;
        message = 64'hA3B1F9D2E7C6A594;
    
        // Load the key
        ui_in[1] = 1;
        for (i = 7; i >= 0; i = i - 1) begin
            ui_in[0] = key[i];
            #CLOCK_PERIOD;
        end
        ui_in[1] = 0;
        ui_in[0] = 0;
    
        // Load the message
        #(CLOCK_PERIOD * 5);
        
        ui_in[2] = 1;
        for (i = 63; i >= 0; i = i - 1) begin
            ui_in[0] = message[i];
            #CLOCK_PERIOD;
        end
        ui_in[2] = 0;
        ui_in[0] = 0;
        
        
        wait(uo_out[1])
        for (i = 63; i >= 0; i = i - 1) begin
            @(posedge clk)
          rebuilt_ciphertext[i] = uo_out[0];
            #CLOCK_PERIOD;
        end
        
        // Perform XOR operation on each 8-bit chunk of the message with the key
        for (i = 0; i < 8; i = i + 1) begin
            ciphertext[i*8 +: 8] = message[i*8 +: 8] ^ key;
        end

        // Display the results
        $display("Key:                 %h", key);
        $display("Message:             %h", message);
        $display("Computed Ciphertext: %h", ciphertext);
        $display("Rebuilt Ciphertext:  %h", rebuilt_ciphertext);

        // Compare computed ciphertext with rebuilt_ciphertext
        if (ciphertext == rebuilt_ciphertext) begin
            $display("Test Passed: Ciphertext matches rebuilt_ciphertext.");
        end else begin
            $display("Test Failed: Ciphertext does not match rebuilt_ciphertext.");
        end

        $finish; // End the simulation
        
        
        
end
endmodule