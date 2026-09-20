module QR_top #(
parameter WL_INPUT = 20, parameter FL_INPUT = 14,
parameter WL_P_INPUT = 19, parameter FL_P_INPUT = 13,
parameter MAG_EXT_BIT = 0)(
	//input
	clk,  				//ok 
	rst_n,				//ok 
	
    input_A_r, 
    input_B_r, 
    input_C_r, 
    input_D_r, 
    input_A_i, 
    input_B_i, 
    input_C_i, 
    input_D_i, 	
	
	//output
    output_A_r, 
    output_B_r, 
    output_C_r, 
    output_D_r, 
    output_A_i, 
    output_B_i, 
    output_C_i, 
    output_D_i
);
// [1.] Parameter declaration:
// parameter WL_INPUT = 14;  //{1, 1, 12} Amplitude WordLength 
// parameter FL_INPUT = 12; 
// parameter WL_P_INPUT = 16;  //{1, 3, 12} Amplitude WordLength 
// parameter FL_P_INPUT = 12; 

// [2.] Input/Output declaration
input clk;
input rst_n;
input signed [WL_INPUT-1:0] input_A_r; 
input signed [WL_INPUT-1:0] input_B_r;
input signed [WL_INPUT-1:0] input_C_r; 
input signed [WL_INPUT-1:0] input_D_r;
input signed [WL_INPUT-1:0] input_A_i; 
input signed [WL_INPUT-1:0] input_B_i;
input signed [WL_INPUT-1:0] input_C_i; 
input signed [WL_INPUT-1:0] input_D_i;

output wire signed [WL_INPUT-1:0] output_A_r; 
output wire signed [WL_INPUT-1:0] output_B_r;
output wire signed [WL_INPUT-1:0] output_C_r; 
output wire signed [WL_INPUT-1:0] output_D_r;
output wire signed [WL_INPUT-1:0] output_A_i; 
output wire signed [WL_INPUT-1:0] output_B_i;
output wire signed [WL_INPUT-1:0] output_C_i; 
output wire signed [WL_INPUT-1:0] output_D_i;

// [3.] buffer declaration:
	// input buffer:
wire signed [WL_INPUT-1:0] DU1_out_r;
wire signed [WL_INPUT-1:0] DL2_out_r;
wire signed [WL_INPUT-1:0] DL3_out_r;
wire signed [WL_INPUT-1:0] DL4_out_r;
wire signed [WL_INPUT-1:0] DU1_out_i;
wire signed [WL_INPUT-1:0] DL2_out_i;
wire signed [WL_INPUT-1:0] DL3_out_i;
wire signed [WL_INPUT-1:0] DL4_out_i;
	// output buffer:
wire signed [WL_INPUT-1:0] DU1_out_buffer_r;
wire signed [WL_INPUT-1:0] DU2_out_buffer_r;
wire signed [WL_INPUT-1:0] DU3_out_buffer_r;
wire signed [WL_INPUT-1:0] DU4_out_buffer_r;
wire signed [WL_INPUT-1:0] DU1_out_buffer_i;
wire signed [WL_INPUT-1:0] DU2_out_buffer_i;
wire signed [WL_INPUT-1:0] DU3_out_buffer_i;
wire signed [WL_INPUT-1:0] DU4_out_buffer_i;


	// [3.1] 第一列(橫向):
wire signed [WL_INPUT-1:0] DU1_out_PE1_r;	
wire signed [WL_INPUT-1:0] DU1_out_PE1_i;	
wire signed [WL_INPUT-1:0] DU1_out_PE2_r;	
wire signed [WL_INPUT-1:0] DU1_out_PE2_i;	
wire signed [WL_INPUT-1:0] DU1_out_PE3_r;	
wire signed [WL_INPUT-1:0] DU1_out_PE3_i;
	
	// [3.2] 第二列(橫向):
wire signed [WL_INPUT-1:0] DU2_out_PE4_r;
wire signed [WL_INPUT-1:0] DU2_out_PE4_i;
wire signed [WL_INPUT-1:0] DU2_out_PE5_r;
wire signed [WL_INPUT-1:0] DU2_out_PE5_i;

	// [3.3] 第三列(橫向):
wire signed [WL_INPUT-1:0] DU3_out_PE6_r;
wire signed [WL_INPUT-1:0] DU3_out_PE6_i;

	// [3.4] 第四列(橫向):
wire signed [WL_INPUT-1:0] DU4_out_PE7_r;
wire signed [WL_INPUT-1:0] DU4_out_PE7_i;

	// [3.5] 第二欄(縱向):
wire signed [WL_INPUT-1:0] DL2_out_PE1_r;
wire signed [WL_INPUT-1:0] DL2_out_PE1_i;

	// [3.6] 第三欄(縱向):
wire signed [WL_INPUT-1:0] DL3_out_PE2_r;
wire signed [WL_INPUT-1:0] DL3_out_PE2_i;
wire signed [WL_INPUT-1:0] DL3_out_PE4_r;
wire signed [WL_INPUT-1:0] DL3_out_PE4_i;

	// [3.7] 第四欄(縱向):
wire signed [WL_INPUT-1:0] DL4_out_PE3_r;
wire signed [WL_INPUT-1:0] DL4_out_PE3_i;
wire signed [WL_INPUT-1:0] DL4_out_PE5_r;
wire signed [WL_INPUT-1:0] DL4_out_PE5_i;
wire signed [WL_INPUT-1:0] DL4_out_PE6_r;
wire signed [WL_INPUT-1:0] DL4_out_PE6_i;

	// [3.8] 轉向reg:
wire signed [WL_INPUT-1:0] DU2_out_r;	
wire signed [WL_INPUT-1:0] DU2_out_i;
wire signed [WL_INPUT-1:0] DU3_out_r;	
wire signed [WL_INPUT-1:0] DU3_out_i;


wire [2:0] Cycle_counter;
wire [7:0] PE_control;
wire signed [WL_P_INPUT-1:0] D_PE7;
wire signed [WL_P_INPUT-1:0] D_PE7_reg;
	




// [4.] circuit declaration:

  // (1.) 設定control signal:
control_unit CU1(clk, rst_n, Cycle_counter, PE_control); 

  // (2.) 設定input delay:
delay_line #(WL_INPUT, 1) Delay1_in_r(clk, rst_n, input_A_r, DU1_out_r);
delay_line #(WL_INPUT, 1) Delay2_in_r(clk, rst_n, input_B_r, DL2_out_r);
delay_line #(WL_INPUT, 2) Delay3_in_r(clk, rst_n, input_C_r, DL3_out_r);
delay_line #(WL_INPUT, 3) Delay4_in_r(clk, rst_n, input_D_r, DL4_out_r);
delay_line #(WL_INPUT, 1) Delay1_in_i(clk, rst_n, input_A_i, DU1_out_i);
delay_line #(WL_INPUT, 1) Delay2_in_i(clk, rst_n, input_B_i, DL2_out_i);
delay_line #(WL_INPUT, 2) Delay3_in_i(clk, rst_n, input_C_i, DL3_out_i);
delay_line #(WL_INPUT, 3) Delay4_in_i(clk, rst_n, input_D_i, DL4_out_i);

  // (3.) 設定整個array:
COMPLEX_PE #(WL_INPUT, FL_INPUT, WL_P_INPUT, FL_P_INPUT, MAG_EXT_BIT) PE1(clk, rst_n,	DU1_out_r,     DU1_out_i,     DL2_out_r,     DL2_out_i,	    PE_control[0],		
	DU1_out_PE1_r,	DU1_out_PE1_i,	DL2_out_PE1_r,	DL2_out_PE1_i);
COMPLEX_PE #(WL_INPUT, FL_INPUT, WL_P_INPUT, FL_P_INPUT, MAG_EXT_BIT) PE2(clk, rst_n,	DU1_out_PE1_r, DU1_out_PE1_i, DL3_out_r,     DL3_out_i,	    PE_control[1],		
	DU1_out_PE2_r,	DU1_out_PE2_i,	DL3_out_PE2_r,	DL3_out_PE2_i);
COMPLEX_PE #(WL_INPUT, FL_INPUT, WL_P_INPUT, FL_P_INPUT, MAG_EXT_BIT) PE3(clk, rst_n,	DU1_out_PE2_r, DU1_out_PE2_i, DL4_out_r,     DL4_out_i,	    PE_control[2],		
	DU1_out_PE3_r,	DU1_out_PE3_i,	DL4_out_PE3_r,	DL4_out_PE3_i);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
delay_line #(WL_INPUT, 1) Delay_DU2_r(clk, rst_n, DL2_out_PE1_r, DU2_out_r);
delay_line #(WL_INPUT, 1) Delay_DU2_i(clk, rst_n, DL2_out_PE1_i, DU2_out_i);

COMPLEX_PE #(WL_INPUT, FL_INPUT, WL_P_INPUT, FL_P_INPUT, MAG_EXT_BIT) PE4(clk, rst_n,	DU2_out_r,     DU2_out_i,     DL3_out_PE2_r, DL3_out_PE2_i,	PE_control[3],		
	DU2_out_PE4_r,	DU2_out_PE4_i,	DL3_out_PE4_r,	DL3_out_PE4_i);
COMPLEX_PE #(WL_INPUT, FL_INPUT, WL_P_INPUT, FL_P_INPUT, MAG_EXT_BIT) PE5(clk, rst_n,	DU2_out_PE4_r, DU2_out_PE4_i, DL4_out_PE3_r, DL4_out_PE3_i,	PE_control[4],		
	DU2_out_PE5_r,	DU2_out_PE5_i,	DL4_out_PE5_r,	DL4_out_PE5_i);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
delay_line #(WL_INPUT, 1) Delay_DU3_r(clk, rst_n, DL3_out_PE4_r, DU3_out_r);
delay_line #(WL_INPUT, 1) Delay_DU3_i(clk, rst_n, DL3_out_PE4_i, DU3_out_i);

COMPLEX_PE #(WL_INPUT, FL_INPUT, WL_P_INPUT, FL_P_INPUT, MAG_EXT_BIT) PE6(clk, rst_n,	DU3_out_r,     DU3_out_i,     DL4_out_PE5_r, DL4_out_PE5_i,	PE_control[5],		
	DU3_out_PE6_r,	DU3_out_PE6_i,	DL4_out_PE6_r,	DL4_out_PE6_i);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg_mode #(WL_P_INPUT) R_PE7(clk, rst_n,  PE_control[6], D_PE7_reg, D_PE7);
CORDIC_v2 #(WL_INPUT, FL_INPUT, WL_P_INPUT, FL_P_INPUT, MAG_EXT_BIT) CORDIC_PE7(clk, rst_n, DL4_out_PE6_r, DL4_out_PE6_i, D_PE7, PE_control[6], 
	//output
	DU4_out_PE7_r,			//ok 
	DU4_out_PE7_i,			//ok 
	D_PE7_reg			//ok 
);
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // (4.) 設定output delay:
delay_line #(WL_INPUT, 3) Delay1_out_r(clk, rst_n, DU1_out_PE3_r, output_A_r);
delay_line #(WL_INPUT, 2) Delay2_out_r(clk, rst_n, DU2_out_PE5_r, output_B_r);
delay_line #(WL_INPUT, 1) Delay3_out_r(clk, rst_n, DU3_out_PE6_r, output_C_r);
delay_line #(WL_INPUT, 1) Delay4_out_r(clk, rst_n, DU4_out_PE7_r, output_D_r);
delay_line #(WL_INPUT, 3) Delay1_out_i(clk, rst_n, DU1_out_PE3_i, output_A_i);
delay_line #(WL_INPUT, 2) Delay2_out_i(clk, rst_n, DU2_out_PE5_i, output_B_i);
delay_line #(WL_INPUT, 1) Delay3_out_i(clk, rst_n, DU3_out_PE6_i, output_C_i);
delay_line #(WL_INPUT, 1) Delay4_out_i(clk, rst_n, DU4_out_PE7_i, output_D_i);

endmodule