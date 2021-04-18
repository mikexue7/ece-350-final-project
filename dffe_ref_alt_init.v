module dffe_ref_alt_init (q, init_in, d, clk, en, clr);

   //Inputs
   input init_in, d, clk, en, clr;

   //Internal wire
   wire clr;

   //Output
   output q;

   //Register
   reg q;

   //Intialize q to init_in
   initial
   begin
       q = 1'b0;
   end

   reg ready = 1;

   //Set value of q on positive edge of the clock or clear
   always @(posedge clk or posedge clr) begin
       if (ready) begin
           q <= init_in;
           ready <= 1'b0;
       end
       //If clear is high, set q to init_in
       else if (clr) begin
           q <= init_in;
       //If enable is high, set q to the value of d
       end else if (en) begin
           q <= d;
       end
   end
endmodule
