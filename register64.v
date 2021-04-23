module register64 (out, output_enable, clk, clr, in, input_enable);

   //Inputs
   input clk, clr, input_enable, output_enable;
   input[63:0] in;

   //Internal wire
   wire[63:0] q;

   //Output
   output[63:0] out;

   genvar i;
   generate
     for (i = 0 ; i < 64; i = i+1)
     begin : gen_loop
         dffe_ref DFFE(q[i], in[i], clk, input_enable, clr );

     end
   endgenerate


   assign out = output_enable ? q : 64'bz;




endmodule
