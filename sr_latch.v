module sr_latch (input R, input S, output Q, output Qbar);

wire Q_i, Qbar_i;
assign Q_i = Q;
assign Qbar_i = Qbar;
assign Q = ~ (R | Qbar);
assign Qbar = ~ (S | Q);
endmodule
