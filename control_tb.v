`timescale 1ns/100ps
module control_tb;

	//inputs to the module (wire)
	wire[31:0] instruction;
	//outputs of the module (wire)
  wire [4:0] Opcode, rd, rs, rt, shamt, ALU_op;
  wire [16:0] Immediate;
  wire [26:0] Target;
  wire BLT, JP, JR, JAL, BNE, DMwe, Rwd, ALUinB, Rwe, read_rd;
  wire add, addi, sub, and_op, or_op, sll, sra, mul, div, lw, sw, branch, bex, setx;

	//Instantiate the module to test
  control CTRL(instruction, Opcode, ALU_op, rd, rs, rt, shamt, Immediate, Target,
    BLT, JP, JR, JAL, BNE, DMwe, Rwd, ALUinB, Rwe, read_rd, branch, bex, setx);

	wire temp;

	assign temp = 1'bx == 1'bx;
	integer i;

  assign {instruction} = 32'b10110000000000000000000000001101;
	initial begin
		for(i = 0; i < 1; i = i + 1) begin
			#20
			//Display
			$display("Instruction:%b => Opcode:%b, ALU_op:%b, rd:%b, rs:%b, rt:%b, Immediate:%b, Target:%b",
      instruction, Opcode, ALU_op, rd, rs, rt, Immediate, Target);
      $display("BLT:%b, JP:%b, JR:%b, JAL:%b, BNE:%b, DMwe:%b, Rwd:%b, ALUinB:%b, Rwe:%b, branch:%b, bex:%b, setx:%b",
      BLT, JP, JR, JAL, BNE, DMwe, Rwd, ALUinB, Rwe, branch, bex, setx);
			$display("temp:%b ", temp);

		end

		$finish;
	end

endmodule
