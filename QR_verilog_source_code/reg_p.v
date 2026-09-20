module reg_p #(parameter REG_BIT=1)(
  clk,
  rset_n,
  r_in,
  r_out
  );

input	clk;
input	rset_n;
input 	[REG_BIT-1: 0] r_in;
output 	[REG_BIT-1: 0] r_out;
reg 	[REG_BIT-1: 0] r_out;

//register description
always@(posedge clk or negedge rset_n)
  if (!rset_n)
    r_out <= {REG_BIT{1'b0}};
  else 
    r_out <= r_in;
endmodule