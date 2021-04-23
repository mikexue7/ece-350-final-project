module not_equal(result, data_operandA, data_operandB);

	input [31:0] data_operandA, data_operandB;

	wire[31:0] temp;
	output result;

	wire w1;
	assign w1 = 0;

	genvar i;
  	generate
    	for (i = 0 ; i < 32; i = i+1)
    	begin : gen_loop
        	xor XOR1(temp[i], data_operandA[i], data_operandB[i]);
    	end
  	endgenerate

	 or OR1(result, temp[0], temp[1], temp[2], temp[3], temp[4], temp[5],
			temp[6], temp[7], temp[8], temp[9], temp[10], temp[11], temp[12],
			temp[13], temp[14], temp[15], temp[16], temp[17], temp[18], temp[19],
			temp[20], temp[21], temp[22], temp[23], temp[24], temp[25], temp[26],
			temp[27], temp[28], temp[29], temp[30], temp[31]);


endmodule
