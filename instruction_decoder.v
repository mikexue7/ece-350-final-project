module instruction_decoder (instruction, Opcode, ALU_op, rd, rs, rt, shamt, Immediate, Target);

   //Inputs
   input[31:0] instruction;

   //Output
   output [4:0] Opcode, rd, rs, rt, shamt, ALU_op;
   output [16:0] Immediate;
   output [26:0] Target;

   assign Opcode = instruction[31:27];
   assign rd = instruction[26:22];
   assign rs = instruction[21:17];
   assign rt = instruction[16:12];
   assign shamt = instruction[11:7];
   assign ALU_op = instruction[6:2];

   assign Immediate = instruction[16:0];
   assign Target = instruction[26:0];


endmodule
