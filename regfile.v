module regfile (
	clock,
	ctrl_writeEnable, ctrl_reset, ctrl_writeReg,
	ctrl_readRegA, ctrl_readRegB, data_writeReg,
	data_readRegA, data_readRegB,
	score_flag,
	score,
	reg1
);

	input clock, ctrl_writeEnable, ctrl_reset, score_flag;
	input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	input [31:0] data_writeReg;

	output [31:0] data_readRegA, data_readRegB;
	output [5:0] score;
	output [14:0] reg1;

	wire[31:0] out [31:0];
	wire[31:0] write_decoder_output;
	wire[31:0] write_enable_selector;

	// Decipher Input Enable Signal

	decoder DEC1(write_decoder_output, ctrl_writeReg, 1'b1);
	genvar i;
	generate
		for (i = 0 ; i < 32; i = i+1)
		begin : gen_loop1
				and AND1(write_enable_selector[i], ctrl_writeEnable, write_decoder_output[i]);
		end
	endgenerate

	// Output Tri State Selections
	wire[31:0] decoder_output1, decoder_output2;

	decoder DEC2(decoder_output1, ctrl_readRegA, 1'b1);

	genvar j;
	generate
		for (j = 0 ; j < 32; j = j+1)
		begin : gen_loop2
				assign data_readRegA = decoder_output1[j] ? out[j] : 32'bz;
		end
	endgenerate

	decoder DEC3(decoder_output2, ctrl_readRegB, 1'b1);

	genvar k;
	generate
		for (k = 0 ; k < 32; k = k+1)
		begin : gen_loop3
				assign data_readRegB = decoder_output2[k] ? out[k] : 32'bz;
		end
	endgenerate


	register REG0(.out(out[0]), .output_enable(1'b1), .clk(clock), .clr(ctrl_reset), .in(data_writeReg), .input_enable(1'b0));

	genvar l;

	generate
		for (l = 1 ; l < 30; l = l+1)
		begin : gen_loop4
				register REG(.out(out[l]), .output_enable(1'b1), .clk(clock), .clr(ctrl_reset), .in(data_writeReg), .input_enable(write_enable_selector[l]));
		end
	endgenerate

	wire[31:0] data_write;
	wire input_enable_final;

	assign data_write = score_flag ? 32'd6 : data_writeReg;
	assign input_enable_final = score_flag ? 1'b1 : write_enable_selector[30];

	register REG30(.out(out[30]), .output_enable(1'b1), .clk(clock), .clr(ctrl_reset), .in(data_write), .input_enable(input_enable_final));
	register REG31(.out(out[31]), .output_enable(1'b1), .clk(clock), .clr(ctrl_reset), .in(data_writeReg), .input_enable(write_enable_selector[31]));

	assign score = out[1][5:0];
	assign reg1 = out[1][14:0];


endmodule
