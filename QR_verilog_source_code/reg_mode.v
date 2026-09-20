module reg_mode #(parameter REG_BIT=1)(
  clk,
  rset_n,
  mode,
  r_in,
  r_out
  );

input	clk;
input	rset_n;
input 	mode;
input signed	[REG_BIT-1: 0] r_in;
output reg signed	[REG_BIT-1: 0] r_out;

//register description:
always@(posedge clk or negedge rset_n)
  if (!rset_n) begin
    r_out <= {REG_BIT{1'b0}};
  end
  else begin
	if (mode == 1'b1) begin // rotation
		r_out <= r_in;
		end
	else begin // vector
		r_out <= (~r_in+1);
		end
  end
endmodule