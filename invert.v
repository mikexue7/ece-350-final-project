module invert(result, data_operandA);
	input [31:0] data_operandA;
	output [31:0] result;
	

	genvar i;
  	generate
    	for (i = 0 ; i < 32; i = i+1)
    	begin : gen_loop
          not(result[i], data_operandA[i]);
    	end
  	endgenerate

endmodule