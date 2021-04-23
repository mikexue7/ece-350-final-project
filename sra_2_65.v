module sra_2_65(result, data_operandA);
	input [64:0] data_operandA;
	wire [64:0] temp;
	wire sign;
	output [64:0] result;


	assign sign = data_operandA[64];

	genvar i;
  	generate
    	for (i = 0 ; i < 63; i = i+1)
    	begin : gen_loop
        	assign temp[i] = data_operandA[i+2];
    	end
  	endgenerate


	assign temp[63] = sign;
	assign temp[64] = sign;

	assign result = temp;


endmodule
