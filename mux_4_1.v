module mux_4_1(out, select, in0, in1, in2, in3);
	input [1:0] select;
	input in0, in1, in2, in3;
	output out;

	wire w1, w2;
	mux_2_1 first_top(w1, select[0], in0, in1);
	mux_2_1 first_bottom(w2, select[0], in2, in3);
	mux_2_1 second(out, select[1], w1, w2);

endmodule


module mux_2_1(out, select, in0, in1);
	input select;
	input in0, in1;
	output out;
	assign out = select ? in1 : in0;
endmodule
