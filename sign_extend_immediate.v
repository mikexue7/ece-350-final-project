module sign_extend_immediate(extended, Immediate);

   //Inputs
   input[16:0] Immediate;

   //Output
   output [31:0] extended;

   wire sign;
   assign sign = Immediate[16];

   assign extended[16:0] = Immediate;

  assign extended[17] = sign;
  assign extended[18] = sign;
  assign extended[19] = sign;
  assign extended[20] = sign;
  assign extended[21] = sign;
  assign extended[22] = sign;
  assign extended[23] = sign;
  assign extended[24] = sign;
  assign extended[25] = sign;
  assign extended[26] = sign;
  assign extended[27] = sign;
  assign extended[28] = sign;
  assign extended[29] = sign;
  assign extended[30] = sign;
  assign extended[31] = sign;


endmodule
