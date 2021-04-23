module XM_pipeline (IM_out, O_out, B_out, Ovf_out, clk, reset, IM, O_in, B_in, Ovf_in, en);

   //Inputs
   input clk, Ovf_in, reset, en;
   input[31:0] IM, O_in, B_in;

   output[31:0] IM_out, O_out, B_out;
   output Ovf_out;

   register32 O(O_out, 1'b1, clk, reset, O_in, en);

   register32 B(B_out, 1'b1, clk, reset, B_in, en);

   register32 IR(IM_out, 1'b1, clk, reset, IM, en);

   register_1 OR(Ovf_out, 1'b1, clk, reset, Ovf_in, en);

endmodule
