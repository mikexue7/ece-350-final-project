module sign_extend_target(extended, Target);

   //Inputs
   input[26:0] Target;

   //Output
   output [31:0] extended;

   wire sign;
   assign sign = Target[26];

   assign extended[26:0] = Target;

   assign extended[27] = sign;
   assign extended[28] = sign;
   assign extended[29] = sign;
   assign extended[30] = sign;
   assign extended[31] = sign;


endmodule
