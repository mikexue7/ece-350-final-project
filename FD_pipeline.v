module FD_pipeline (IM_out, PC_out, clk, reset, IM, PC_in, en);

   //Inputs
   input clk, en, reset;
   input[31:0] IM, PC_in;

   output[31:0] IM_out, PC_out;

   register32 PC_REG(PC_out, 1'b1, clk, reset, PC_in, en);

   register32 IR(IM_out, 1'b1, clk, reset, IM, en);

endmodule
