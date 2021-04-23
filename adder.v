module adder(S, Cout, Ovf, A, B, C0);


	input [31:0] A, B;
	input C0;
	output [31:0] S;
	output Cout, Ovf;

	wire [3:0] G, P;
	wire [31:0] w;
	wire not_S31, not_A31, not_B31;

	wire C8, C16, C24;


	// compute g's and p's

	eight_bit_cla cla1(S[7:0], G[0], P[0], A[7:0], B[7:0], C0);

	and AND1(w[0], P[0], C0);
	or OR1(C8, G[0], w[0]);

	eight_bit_cla cla2(S[15:8], G[1], P[1], A[15:8], B[15:8], C8);

	and AND2(w[1], P[1], P[0], C0);
	and AND3(w[2], P[1], G[0]);
	or OR2(C16, G[1], w[1], w[2]);

 	eight_bit_cla cla3(S[23:16], G[2], P[2], A[23:16], B[23:16], C16);

 	and AND4(w[3], P[2], P[1], P[0], C0);
	and AND5(w[4], P[2], P[1], G[0]);
	and AND6(w[5], P[2], G[1]);
	or OR3(C24, G[2], w[3], w[4], w[5]);


	eight_bit_cla cla4(S[31:24], G[3], P[3], A[31:24], B[31:24], C24);


 	and AND7(w[6], P[3], P[2], P[1], P[0], C0);
	and AND8(w[7], P[3], P[2], P[1], G[0]);
	and AND9(w[8], P[3], P[2], G[1]);
	and AND10(w[9], P[3], G[2]);
	or OR4(Cout, G[3], w[6], w[7], w[8], w[9]);


	not NOT1(not_A31, A[31]);
	not NOT2(not_B31, B[31]);
	not NOT3(not_S31, S[31]);

	and AND11(w[10], A[31], B[31], not_S31);

	and AND12(w[11], not_A31, not_B31, S[31]);

	or OR5(Ovf, w[10], w[11]);

endmodule
