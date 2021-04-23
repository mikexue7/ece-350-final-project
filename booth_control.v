module booth_control (shift, do_nothing, add_sub, select);

   //Inputs
   input[2:0] select;

   //Output
   output shift, do_nothing, add_sub;

   wire [31:0] out;

   mux_8 MUX(out, select, 001, 000, 000, 010, 110 , 100, 100, 001);

   assign add_sub = out[2];
   assign shift = out[1];
   assign do_nothing = out[0];

endmodule
