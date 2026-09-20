module COMPLEX_PE #(
parameter WL_INPUT = 3, parameter FL_INPUT = 3,
parameter WL_P_INPUT = 3, parameter FL_P_INPUT = 3,
parameter MAG_EXT_BIT = 0) (
	//input:
	clk,  				//ok 
	rset_n,				//ok 
	
	A_Real_In,			//ok 
	A_Imag_In,			//ok 
	B_Real_In,			//ok 
	B_Imag_In,			//ok 	 
	CORDIC_mode_In,		//ok 
	
	//output:
	A_Real_Out,			//ok 
	A_Imag_Out,			//ok 
	B_Real_Out,			//ok 
	B_Imag_Out			//ok 
);
// [1.] Parameter declaration:

// [2.] Input/Output declaration:
input clk;
input rset_n;
input signed [WL_INPUT-1:0] A_Real_In; 
input signed [WL_INPUT-1:0] A_Imag_In;
input signed [WL_INPUT-1:0] B_Real_In; 
input signed [WL_INPUT-1:0] B_Imag_In;
input CORDIC_mode_In;

output wire signed [WL_INPUT-1:0] A_Real_Out; 
output wire signed [WL_INPUT-1:0] A_Imag_Out; 
output wire signed [WL_INPUT-1:0] B_Real_Out; 
output wire signed [WL_INPUT-1:0] B_Imag_Out; 

// [3.] Register declaration
wire signed [WL_P_INPUT-1:0] D11;
wire signed [WL_P_INPUT-1:0] D12;
wire signed [WL_P_INPUT-1:0] D21;
wire signed [WL_P_INPUT-1:0] D22;

wire signed [WL_P_INPUT-1:0] D11_reg;
wire signed [WL_P_INPUT-1:0] D12_reg;
wire signed [WL_P_INPUT-1:0] D21_reg;

wire signed [WL_INPUT-1:0] X11;
wire signed [WL_INPUT-1:0] Y11;
wire signed [WL_INPUT-1:0] X21;
wire signed [WL_INPUT-1:0] Y21;

wire signed [WL_INPUT-1:0] A_Real_Out_Tmp; 
wire signed [WL_INPUT-1:0] A_Imag_Out_Tmp; 
wire signed [WL_INPUT-1:0] B_Real_Out_Tmp; 
wire signed [WL_INPUT-1:0] B_Imag_Out_Tmp; 
wire signed [WL_INPUT-1:0] A_Imag_Out_Tmp_Tmp; 
wire signed [WL_INPUT-1:0] B_Real_Out_Tmp_Tmp; 
wire signed [WL_INPUT-1:0] B_Imag_Out_Tmp_Tmp; 

// [4.] Circuit declaration: 
  // 0: vector  1: rotation
reg_mode #(WL_P_INPUT) R11(clk, rset_n, CORDIC_mode_In, D11_reg, D11);
reg_mode #(WL_P_INPUT) R21(clk, rset_n, CORDIC_mode_In, D21_reg, D21);
reg_mode #(WL_P_INPUT) R12(clk, rset_n, CORDIC_mode_In, D12_reg, D12);

// [ok]
CORDIC_v2 #(WL_INPUT, FL_INPUT, WL_P_INPUT, FL_P_INPUT, MAG_EXT_BIT) CORDIC_11(
	//input
	clk,  				//ok 
	rset_n,				//ok 
	
	A_Real_In,			//ok 
	A_Imag_In,			//ok 
	D11,			//ok 
	CORDIC_mode_In,		//ok 
	
	//output
	X11,			//ok 
	Y11,			//ok 
	D11_reg			//ok 
);

// [ok]
CORDIC_v2 #(WL_INPUT, FL_INPUT, WL_P_INPUT, FL_P_INPUT, MAG_EXT_BIT) CORDIC_21(
	//input
	clk,  				//ok 
	rset_n,				//ok 
	
	B_Real_In,			//ok 
	B_Imag_In,			//ok 
	D21,			//ok 
	CORDIC_mode_In,		//ok 
	
	//output
	X21,			//ok 
	Y21,			//ok 
	D21_reg			//ok 
);

// [ok]
CORDIC_v2 #(WL_INPUT, FL_INPUT, WL_P_INPUT, FL_P_INPUT, MAG_EXT_BIT) CORDIC_12(
	//input
	clk,  				//ok 
	rset_n,				//ok 
	
	X11,			//ok 
	X21,			//ok 
	D12,			//ok 
	CORDIC_mode_In,		//ok 
	
	//output
	A_Real_Out_Tmp,			//ok 
	A_Imag_Out_Tmp,			//ok 
	D12_reg			//ok 
);

// [ok]
CORDIC_v2 #(WL_INPUT, FL_INPUT, WL_P_INPUT, FL_P_INPUT, MAG_EXT_BIT) CORDIC_22(
	//input
	clk,  				//ok 
	rset_n,				//ok 
	
	Y11,			//ok 
	Y21,			//ok 
	D12,			//ok 
	CORDIC_mode_In,		//ok 
	
	//output
	B_Real_Out_Tmp,			//ok 
	B_Imag_Out_Tmp,			//ok 
	D22			//ok 
);
assign A_Imag_Out_Tmp_Tmp = (CORDIC_mode_In) ? B_Real_Out_Tmp : A_Imag_Out_Tmp;
assign B_Real_Out_Tmp_Tmp = (CORDIC_mode_In) ? A_Imag_Out_Tmp : {WL_INPUT{1'b0}};
assign B_Imag_Out_Tmp_Tmp = (CORDIC_mode_In) ? B_Imag_Out_Tmp : {WL_INPUT{1'b0}};

reg_p #(WL_INPUT) R_out_1(clk, rset_n, A_Real_Out_Tmp,     A_Real_Out);
reg_p #(WL_INPUT) R_out_2(clk, rset_n, A_Imag_Out_Tmp_Tmp, A_Imag_Out);
reg_p #(WL_INPUT) R_out_3(clk, rset_n, B_Real_Out_Tmp_Tmp, B_Real_Out);
reg_p #(WL_INPUT) R_out_4(clk, rset_n, B_Imag_Out_Tmp_Tmp, B_Imag_Out);

endmodule