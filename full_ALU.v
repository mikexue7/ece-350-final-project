module full_ALU(data_operandA, data_operandB, ALU_op, ctrl_shiftamt,	clock, isNotEqual, isLessThan, data_result);

    input [31:0] data_operandA, data_operandB;
    input [4:0] ALU_op, ctrl_shiftamt;
    input clock;

    output [31:0] data_result;
    output isNotEqual, isLessThan;

		wire [31:0] ALU_result, multdiv_result;

    wire multdiv_exception, overflow, data_resultRDY;
    wire ctrl_MULT, ctrl_DIV;

		alu ALU(data_operandA, data_operandB, ALU_op, ctrl_shiftamt, ALU_result, isNotEqual, isLessThan, overflow);

    wire [7:0] op_one_hot;
    three_bit_decoder TBD(op_one_hot , ALU_op[2:0], 1'b1);

    assign ctrl_MULT = op_one_hot[6];
    assign ctrl_DIV = op_one_hot[7];
    multdiv MD(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV,	clock,	multdiv_result, multdiv_exception, data_resultRDY);

    // Stall till data_resultRDY == 1, then output answer regardless of if its ALU or multdiv

    mux_8 ALU_MUX(data_result, ALU_op[2:0], ALU_result, ALU_result, ALU_result, ALU_result, ALU_result, ALU_result, multdiv_result, multdiv_result);



endmodule
