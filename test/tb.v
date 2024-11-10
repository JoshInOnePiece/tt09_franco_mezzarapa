`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  tt_um_franco_mezzarapa dut (
    `ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
    `endif

      .clk(clk),                    // Clock
      .ena(ena),                    // Enable
      .rst_n(rst_n),                // Reset (active low)
      .ui_in(ui_in),                // Input array (0 is serial line, 1 is key, 2 is msg)
      .uo_out(uo_out),              // Output array (0 is serial line, 1 is out stat, 2 is encrypt stat.)
      .uio_in(uio_in),
      .uio_out(uio_out),
      .uio_oe(uio_oe)
  );
endmodule
