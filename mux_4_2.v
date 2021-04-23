module mux_4_2(out, select, in0, in1, in2, in3);
	input [1:0] select;
	input [1:0] in0, in1, in2, in3;
	output [1:0] out;

	wire [1:0] w1, w2;
	mux_2_2 first_top(w1, select[0], in0, in1);
	mux_2_2 first_bottom(w2, select[0], in2, in3);
	mux_2_2 second(out, select[1], w1, w2);

endmodule


module mux_2_2(out, select, in0, in1);
	input select;
	input [1:0] in0, in1;
	output [1:0] out;
	assign out = select ? in1 : in0;
endmodule
