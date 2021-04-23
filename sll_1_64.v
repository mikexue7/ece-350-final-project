module sll_1_64(result, data_operandA);
	input [63:0] data_operandA;
	wire [63:0] temp;
	output [63:0] result;

	assign temp[0] = 0;

	genvar i;
  	generate
    	for (i = 1 ; i < 64; i = i+1)
    	begin : gen_loop
        	assign temp[i] = data_operandA[i-1];
    	end
  	endgenerate


  assign result = temp;


endmodule
