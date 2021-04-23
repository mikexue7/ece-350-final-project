module and_function(result, data_operandA, data_operandB);

	input [31:0] data_operandA, data_operandB;

	output [31:0] result;

	genvar i;
  	generate
    	for (i = 0 ; i < 32; i = i+1)
    	begin : gen_loop
        	and AND1(result[i], data_operandA[i], data_operandB[i]);
    	end
  	endgenerate


endmodule
