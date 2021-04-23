module MW_pipeline (IM_out, O_out, D_out, Ovf_out, clk, reset, IM, O_in, D_in, Ovf_in);

   //Inputs
   input clk, Ovf_in, reset;
   input[31:0] IM, O_in, D_in;

   output[31:0] IM_out, O_out, D_out;
   output Ovf_out;

   register32 O(O_out, 1'b1, clk, reset, O_in, 1'b1);

   register32 D(D_out, 1'b1, clk, reset, D_in, 1'b1);

   register32 IR(IM_out, 1'b1, clk, reset, IM, 1'b1);

   register_1 OR(Ovf_out, 1'b1, clk, reset, Ovf_in, 1'b1);

endmodule
