module control (instruction, Opcode, ALU_op, rd, rs, rt, shamt, Immediate, Target,
  BLT, JP, JR, JAL, BNE, DMwe, Rwd, ALUinB, Rwe, read_rd, branch, bex, setx, bexeq);

   //Inputs
   input[31:0] instruction;


   output [4:0] Opcode, rd, rs, rt, shamt, ALU_op;
   output [16:0] Immediate;
   wire [26:0] Target_temp;
   output [26:0] Target;


   wire  r_type, i_type, j1_type, j2_type;

   assign Opcode = instruction[31:27];
   assign rd = instruction[26:22];
   assign rs = instruction[21:17];
   assign rt = r_type? instruction[16:12] : 5'b0;
   assign shamt = r_type ? instruction[11:7] : 5'b0;
   assign ALU_op = r_type ? instruction[6:2] : 5'b0;
   assign Immediate = i_type ? instruction[16:0] : 17'b0;
   assign Target_temp = j1_type ? instruction[26:0] : 27'b0;

   wire [26:0] bexeq_Target;

   assign bexeq_Target[21:0] = instruction[21:0];
   assign bexeq_Target[26:22] = 5'b0;
   assign Target = bexeq ? bexeq_Target : Target_temp;


// 11111001100000000000000000000010



   wire [31:0] Opcode_out, ALU_out;
   decoder OP(Opcode_out, Opcode, 1'b1);
   decoder ALU(ALU_out, ALU_op, 1'b1);

   //Output
   output BLT, JP, JR, JAL, BNE, DMwe, Rwd, ALUinB, Rwe, read_rd, branch, bex, setx, bexeq;
   wire add, addi, sub, and_op, or_op, sll, sra, mul, div, lw, sw;


   assign JP = Opcode_out[1];
   assign BNE = Opcode_out[2];
   assign JAL = Opcode_out[3];
   assign JR = Opcode_out[4];
   assign addi = Opcode_out[5];
   assign BLT = Opcode_out[6];
   assign sw = Opcode_out[7];
   assign lw = Opcode_out[8];
   assign setx = Opcode_out[21];
   assign bex = Opcode_out[22];
   assign bexeq = Opcode_out[31];



   assign r_type = Opcode_out[0];
   or OR0(i_type, BNE, addi, BLT, sw, lw);
   or OR11(j1_type, JP, JAL, setx, bex);
   assign j2_type = JR;
   or OR4(branch, BNE, BLT);

   assign add = ALU_out[0];
   assign sub = ALU_out[1];
   assign and_op = ALU_out[2];
   assign or_op = ALU_out[3];
   assign sll = ALU_out[4];
   assign sra = ALU_out[5];
   assign mul = ALU_out[6];
   assign div = ALU_out[7];

   or OR1(Rwe, r_type, addi, mul, div, lw, JAL, setx);
   or OR3(ALUinB, addi, lw, sw); // good
   or OR5(read_rd, BNE, JR, BLT, sw);

   assign Rwd = lw; // good
   assign DMwe = sw; // good


endmodule
