module eight_bit_cla(S, G, P, A, B, C0);

	input [7:0] A, B;
	input C0;
	output [7:0] S;
	output P, G;

	wire [7:0] p, g;
	wire C1, C2, C3, C4, C5, C6, C7, Cout;
	wire [35:0] w;

	// ___________________Carry Look Ahead Component________________________________

	// find first carry in C1
	and AND8(w[0], p[0], C0);
  or OR8(C1, g[0], w[0]);

	// find carry in C2
	and AND9(w[1], p[1], p[0], C0);
	and AND10(w[2], p[1], g[0]);
	or OR9(C2, g[1], w[1], w[2]);

 	// find carry in C3
	and AND11(w[3], p[2], p[1], p[0], C0);
	and AND12(w[4], p[2], p[1], g[0]);
	and AND13(w[5], p[2], g[1]);
	or OR10(C3, g[2], w[3], w[4], w[5]);

	// find carry in C4
	and AND14(w[6], p[3], p[2], p[1], p[0], C0);
	and AND15(w[7], p[3], p[2], p[1], g[0]);
	and AND16(w[8], p[3], p[2], g[1]);
	and AND17(w[9], p[3], g[2]);
	or OR11(C4, g[3], w[6], w[7], w[8], w[9]);

	// find carry in C5
	and AND18(w[10], p[4], p[3], p[2], p[1], p[0], C0);
	and AND19(w[11], p[4], p[3], p[2], p[1], g[0]);
	and AND20(w[12], p[4], p[3], p[2], g[1]);
	and AND21(w[13], p[4], p[3], g[2]);
	and AND22(w[14], p[4], g[3]);
	or OR12(C5, g[4], w[10], w[11], w[12], w[13], w[14]);

	// find carry in C6
	and AND23(w[15], p[5], p[4], p[3], p[2], p[1], p[0], C0);
	and AND24(w[16], p[5], p[4], p[3], p[2], p[1], g[0]);
	and AND25(w[17], p[5], p[4], p[3], p[2], g[1]);
	and AND26(w[18], p[5], p[4], p[3], g[2]);
	and AND27(w[19], p[5], p[4], g[3]);
	and AND28(w[20], p[5], g[4]);
	or OR13(C6, g[5], w[15], w[16], w[17], w[18], w[19], w[20]);

	// find carry in C7
	and AND29(w[21], p[6], p[5], p[4], p[3], p[2], p[1], p[0], C0);
	and AND30(w[22], p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
	and AND31(w[23], p[6], p[5], p[4], p[3], p[2], g[1]);
	and AND32(w[24], p[6], p[5], p[4], p[3], g[2]);
	and AND33(w[25], p[6], p[5], p[4], g[3]);
	and AND34(w[26], p[6], p[5], g[4]);
	and AND35(w[27], p[6], g[5]);
	or OR14(C7, g[6], w[21], w[22], w[23], w[24], w[25], w[26], w[27]);

	// find carry in C8
	and AND36(w[28], p[7], p[6], p[5], p[4], p[3], p[2], p[1], p[0], C0);
	and AND37(w[29], p[7], p[6], p[5], p[4], p[3], p[2], p[1], g[0]);
	and AND38(w[30], p[7], p[6], p[5], p[4], p[3], p[2], g[1]);
	and AND39(w[31], p[7], p[6], p[5], p[4], p[3], g[2]);
	and AND40(w[32], p[7], p[6], p[5], p[4], g[3]);
	and AND41(w[33], p[7], p[6], p[5], g[4]);
	and AND42(w[34], p[7], p[6], g[5]);
	and AND43(w[35], p[7], g[6]);
	or OR15(Cout, g[7], w[28], w[29], w[30], w[31], w[32], w[33], w[34], w[35]);



	or OR16(G, g[7], w[35], w[34], w[33], w[32], w[31], w[30], w[29]);
	and AND44(P, p[7], p[6], p[5], p[4], p[3], p[2], p[1], p[0], C0);

	// ________________________________________________________________
	// Call all full-adders, g's and p's are computed inside

	full_adder fa0(S[0], g[0], p[0], A[0], B[0], C0);
	full_adder fa1(S[1], g[1], p[1], A[1], B[1], C1);
	full_adder fa2(S[2], g[2], p[2], A[2], B[2], C2);
	full_adder fa3(S[3], g[3], p[3], A[3], B[3], C3);
	full_adder fa4(S[4], g[4], p[4], A[4], B[4], C4);
	full_adder fa5(S[5], g[5], p[5], A[5], B[5], C5);
	full_adder fa6(S[6], g[6], p[6], A[6], B[6], C6);
  full_adder fa7(S[7], g[7], p[7], A[7], B[7], C7);

endmodule

module full_adder(S, g, p, A, B, Cin);

	input A, B, Cin;
	output S, g, p;


	and AND0(g, A, B);
	or OR0(p, A, B);

	xor Sresult(S, A, B, Cin);

endmodule
