module multdiv(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV,	clock,
	data_result, data_exception, data_resultRDY);

    input [31:0] data_operandA, data_operandB;
    input ctrl_MULT, ctrl_DIV, clock;

    output [31:0] data_result;
    output data_exception, data_resultRDY;

		wire [31:0] mult_result, div_result;

		wire data_exception_mult, data_exception_div;
		wire data_resultRDY_mult, data_resultRDY_div;

		mult MULTIPLY(data_operandA, data_operandB, clock, ctrl_MULT, mult_result, data_exception_mult, data_resultRDY_mult);
		div DIVIDE(data_operandA, data_operandB, clock, ctrl_DIV, div_result, data_exception_div, data_resultRDY_div);

		wire Q, Qbar;
		sr_latch SR(ctrl_MULT, ctrl_DIV, Q, Qbar);

		assign data_result = Q ? div_result : mult_result;
		assign data_exception = Q ? data_exception_div : data_exception_mult;
		assign data_resultRDY = Q ? data_resultRDY_div : data_resultRDY_mult;


endmodule
