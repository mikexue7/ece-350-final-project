module sra_function(result, data_operandA, shamt);
	input [31:0] data_operandA;
	input [4:0] shamt;
	output [31:0] result;

	wire [31:0] temp0, temp1, temp2, temp3;
	wire [31:0] w1, w2, w4, w8, w16;

	sra_16 shift16(w16, data_operandA);

	assign temp0 = shamt[4] ? w16 : data_operandA;

	sra_8 shift8(w8, temp0);

	assign temp1 = shamt[3] ? w8 : temp0;

	sra_4 shift4(w4, temp1);

	assign temp2 = shamt[2] ? w4 : temp1;

	sra_2 shift2(w2, temp2);

	assign temp3 = shamt[1] ? w2 : temp2;

	sra_1 shift1(w1, temp3);

	assign result = shamt[0] ? w1 : temp3;


endmodule

module sra_16(result, data_operandA);
	input [31:0] data_operandA;
	wire [31:0] temp;
	wire sign;
	output [31:0] result;


	assign sign = data_operandA[31];

	genvar i;
  	generate
    	for (i = 0 ; i < 16; i = i+1)
    	begin : gen_loop
        	assign temp[i] = data_operandA[i+16];
    	end
  	endgenerate

  assign temp[16] = sign;
	assign temp[17] = sign;
  assign temp[18] = sign;
	assign temp[19] = sign;
  assign temp[20] = sign;
	assign temp[21] = sign;
  assign temp[22] = sign;
	assign temp[23] = sign;
	assign temp[24] = sign;
	assign temp[25] = sign;
	assign temp[26] = sign;
	assign temp[27] = sign;
	assign temp[28] = sign;
	assign temp[29] = sign;
	assign temp[30] = sign;
	assign temp[31] = sign;

	assign result = temp;


endmodule

module sra_8(result, data_operandA);
	input [31:0] data_operandA;
	wire [31:0] temp;
	output [31:0] result;
	wire sign;


	assign sign = data_operandA[31];

	genvar i;
  	generate
    	for (i = 0 ; i < 24; i = i+1)
    	begin : gen_loop
        	assign temp[i] = data_operandA[i+8];
    	end
  	endgenerate

	assign temp[24] = sign;
	assign temp[25] = sign;
	assign temp[26] = sign;
	assign temp[27] = sign;
	assign temp[28] = sign;
	assign temp[29] = sign;
	assign temp[30] = sign;
	assign temp[31] = sign;

	assign result = temp;


endmodule

module sra_4(result, data_operandA);
	input [31:0] data_operandA;
	wire [31:0] temp;
	wire sign;
	output [31:0] result;


	assign sign = data_operandA[31];

	genvar i;
  	generate
    	for (i = 0 ; i < 28; i = i+1)
    	begin : gen_loop
        	assign temp[i] = data_operandA[i+4];
    	end
  	endgenerate

	assign temp[28] = sign;
	assign temp[29] = sign;
	assign temp[30] = sign;
	assign temp[31] = sign;

	assign result = temp;


endmodule

module sra_2(result, data_operandA);
	input [31:0] data_operandA;
	wire [31:0] temp;
	wire sign;
	output [31:0] result;


	assign sign = data_operandA[31];

	genvar i;
  	generate
    	for (i = 0 ; i < 30; i = i+1)
    	begin : gen_loop
        	assign temp[i] = data_operandA[i+2];
    	end
  	endgenerate


	assign temp[30] = sign;
	assign temp[31] = sign;

	assign result = temp;


endmodule

module sra_1(result, data_operandA);
	input [31:0] data_operandA;
	wire [31:0] temp;
	wire sign;
	output [31:0] result;


	assign sign = data_operandA[31];

	genvar i;
  	generate
    	for (i = 0 ; i < 31; i = i+1)
    	begin : gen_loop
        	assign temp[i] = data_operandA[i+1];
    	end
  	endgenerate


	assign temp[31] = sign;

	assign result = temp;

endmodule
