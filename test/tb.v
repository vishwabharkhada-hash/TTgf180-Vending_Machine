`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
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

wire onlinepayment_selected = ui_in[0];
    wire [3:0] selected_product_number = ui_in[4:1];
    wire online_payment_success = ui_in[5];

    wire show_product_number;
    wire show_payment_status;
    wire show_output_status;
    wire seg_a, seg_b, seg_c, seg_d;
    wire seg_e, seg_f, seg_g;

      // All output pins must be assigned. If not used, assign to 0.
    assign show_product_number = uo_out[0];
    assign show_payment_status = uo_out[1];
    assign show_output_status = uo_out[2];
    assign seg_a = uo_out[3];
    assign seg_b = uo_out[4];
    assign seg_c = uo_out[5];
    assign seg_d = uo_out[6];
    assign seg_e = uo_out[7];

    assign seg_f = uio_out[0];
    assign seg_g = uio_out[1];

  // Replace tt_um_example with your module name:
tt_um_vending_machine user_project(

      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif

      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

endmodule
