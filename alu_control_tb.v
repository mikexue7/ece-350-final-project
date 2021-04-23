`timescale 1ns/100ps
module alu_control_tb;

	wire [4:0] Opcode, ALU_op;
	//Output
	wire add, addi, sub, and_op, or_op, sll, sra, mul, div;
	//Instantiate the module to test
  alu_control ACTRL(Opcode, ALU_op, add, addi, sub, and_op, or_op, sll, sra, mul, div);
	integer i;

  assign {Opcode} = 5'b00000;
	assign {ALU_op} = 5'b00001;

	initial begin
		for(i = 0; i < 1; i = i + 1) begin
			#20
			//Display
			$display("Opcode:%b, ALU_op:%b => add:%b, addi:%b, sub:%b, and:%b, or:%b, sll:%b, sra:%b, mul:%b, div:%b",
      Opcode, ALU_op, add, addi, sub, and_op, or_op, sll, sra, mul, div);

		end

		$finish;
	end

endmodule
