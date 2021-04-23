module sll_function(result, data_operandA, shamt);
	input [31:0] data_operandA;
	input [4:0] shamt;
	output [31:0] result;

	wire [31:0] temp0, temp1, temp2, temp3;
	wire [31:0] w1, w2, w4, w8, w16;

	sll_16 shift16(w16, data_operandA);

	assign temp0 = shamt[4] ? w16 : data_operandA;

	sll_8 shift8(w8, temp0);

	assign temp1 = shamt[3] ? w8 : temp0;

	sll_4 shift4(w4, temp1);

	assign temp2 = shamt[2] ? w4 : temp1;

	sll_2 shift2(w2, temp2);

	assign temp3 = shamt[1] ? w2 : temp2;

	sll_1 shift1(w1, temp3);

	assign result = shamt[0] ? w1 : temp3;


endmodule

module sll_16(result, data_operandA);
	input [31:0] data_operandA;
	wire [31:0] temp;
	output [31:0] result;

	assign temp[0] = 0;
	assign temp[1] = 0;
	assign temp[2] = 0;
	assign temp[3] = 0;
	assign temp[4] = 0;
	assign temp[5] = 0;
	assign temp[6] = 0;
	assign temp[7] = 0;
	assign temp[8] = 0;
	assign temp[9] = 0;
	assign temp[10] = 0;
	assign temp[11] = 0;
	assign temp[12] = 0;
	assign temp[13] = 0;
	assign temp[14] = 0;
	assign temp[15] = 0;

	genvar i;
  	generate
    	for (i = 16 ; i < 32; i = i+1)
    	begin : gen_loop
        	assign temp[i] = data_operandA[i-16];
    	end
  	endgenerate


	assign result = temp;


endmodule

module sll_8(result, data_operandA);
	input [31:0] data_operandA;
	wire [31:0] temp;
	output [31:0] result;

	assign temp[0] = 0;
	assign temp[1] = 0;
	assign temp[2] = 0;
	assign temp[3] = 0;
	assign temp[4] = 0;
	assign temp[5] = 0;
	assign temp[6] = 0;
	assign temp[7] = 0;

	genvar i;
  	generate
    	for (i = 8 ; i < 32; i = i+1)
    	begin : gen_loop
        	assign temp[i] = data_operandA[i-8];
    	end
  	endgenerate


	assign result = temp;


endmodule

module sll_4(result, data_operandA);
	input [31:0] data_operandA;
	wire [31:0] temp;
	output [31:0] result;

	assign temp[0] = 0;
	assign temp[1] = 0;
	assign temp[2] = 0;
	assign temp[3] = 0;

	genvar i;
  	generate
    	for (i = 4 ; i < 32; i = i+1)
    	begin : gen_loop
        	assign temp[i] = data_operandA[i-4];
    	end
  	endgenerate


	assign result = temp;



endmodule

module sll_2(result, data_operandA);
	input [31:0] data_operandA;
	wire [31:0] temp;
	output [31:0] result;

	assign temp[0] = 0;
	assign temp[1] = 0;

	genvar i;
  	generate
    	for (i = 2 ; i < 32; i = i+1)
    	begin : gen_loop
        	assign temp[i] = data_operandA[i-2];
    	end
  	endgenerate


	assign result = temp;

endmodule

module sll_1(result, data_operandA);
	input [31:0] data_operandA;
	wire [31:0] temp;
	output [31:0] result;

	assign temp[0] = 0;

	genvar i;
  	generate
    	for (i = 1 ; i < 32; i = i+1)
    	begin : gen_loop
        	assign temp[i] = data_operandA[i-1];
    	end
  	endgenerate


  assign result = temp;


endmodule
