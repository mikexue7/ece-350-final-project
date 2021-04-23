module alu_control (Opcode, ALU_op, add, addi, sub, and_op, or_op, sll, sra, mul, div);

   //Inputs
   input [4:0] Opcode, ALU_op;
   wire [31:0] Opcode_out, ALU_out;

   //Output
   output add, addi, sub, and_op, or_op, sll, sra, mul, div;

   decoder OP(Opcode_out, Opcode, 1'b1);
   decoder ALU(ALU_out, ALU_op, 1'b1);

   // check if Opcode is all 0
   wire equal0;
   assign equal0 = ~|Opcode;


   assign addi = Opcode_out[5];

   assign add = equal0 & ALU_out[0];
   assign sub = equal0 & ALU_out[1];
   assign and_op = equal0 & ALU_out[2];
   assign or_op = equal0 & ALU_out[3];
   assign sll = equal0 & ALU_out[4];
   assign sra = equal0 &  ALU_out[5];
   assign mul = equal0 & ALU_out[6];
   assign div = equal0 & ALU_out[7];

endmodule
