module DX_pipeline (IM_out, PC_out, A_out, B_out, clk, reset, IM, PC_in, A_in, B_in);

   //Inputs
   input clk, reset;
   input[31:0] IM, PC_in, A_in, B_in;
   output[31:0] IM_out, PC_out, A_out, B_out;

   register32 A(A_out, 1'b1, clk, reset, A_in, 1'b1);

   register32 B(B_out, 1'b1, clk, reset, B_in, 1'b1);

   register32 PC_REG(PC_out, 1'b1, clk, reset, PC_in, 1'b1);

   register32 IR(IM_out, 1'b1, clk, reset, IM, 1'b1);

endmodule
