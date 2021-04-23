module register_1 (out, output_enable, clk, clr, in, input_enable);

   //Inputs
   input clk, clr, input_enable, output_enable;
   input in;

   //Internal wire
   wire q;

   //Output
   output out;

   genvar i;
   generate
     for (i = 0 ; i < 1; i = i+1)
     begin : gen_loop
         dffe_ref DFFE(q, in, clk, input_enable, clr );

     end
   endgenerate


   assign out = output_enable ? q : 1'bz;




endmodule
