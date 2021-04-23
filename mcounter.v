module mcounter(number, clk, reset);
	input clk, reset;
	output [4:0] number;

	wire [31:0] in, out;
	wire Ovf, Cout;

	register32 COUNTER(out, 1'b1, clk, reset, in, 1'b1);

	adder ADD(in, Cout, Ovf, out, 1, 1'b0);

	assign number = out[4:0];

endmodule
