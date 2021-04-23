module PW_pipeline (IM_out, Product_out, clk, reset, IM, Product_in, en);

   //Inputs
   input clk, en, reset;
   input[31:0] IM, Product_in;

   output[31:0] IM_out, Product_out;

   register32 PRODUCT_REG(Product_out, 1'b1, clk, reset, Product_in, en);

   register32 IR(IM_out, 1'b1, clk, reset, IM, 1'b1);

endmodule
