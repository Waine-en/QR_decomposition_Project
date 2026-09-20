module CORDIC_v2 #(
parameter WL_INPUT = 3, parameter FL_INPUT = 3,
parameter WL_P_INPUT = 3, parameter FL_P_INPUT = 3,
parameter MAG_EXT_BIT = 0)(
	//input
	clk,  				//ok 
	rset_n,				//ok 
	
	Real_In,			//ok 
	Imag_In,			//ok 
	Phase_In,			//ok 
	CORDIC_mode_In,		//ok 
	
	//output
	Real_Out,			//ok 
	Imag_Out,			//ok 
	Phase_Out			//ok 
);
// [1.] Parameter declaration:
parameter WL_S = 15;
parameter FL_S = 14;
localparam integer MUL_W = WL_INPUT + WL_S;      // multiply result width
 
// ---------------------------------------------------------
// [2.] ROM宣告: 小數點位數要對上WL_P_INPUT、FL_P_INPUT
	// (1.) Phase constants for Q4.12 (signed 16-bit two's complement)

localparam signed [18:0] PH_0          = 19'sb0000000000000000000; // 0
localparam signed [18:0] PH_PI_2_POS   = 19'sb0000011001001000011; //  +pi/2  ≈ +1.5707 * 4096
localparam signed [18:0] PH_PI_POS     = 19'sb0000110010010000111; //  +pi    ≈ +3.1415 * 4096
localparam signed [18:0] PH_3PI_2_POS  = 19'sb0001001011011001011; //  +3pi/2 ≈ +4.7123 * 4096
localparam signed [18:0] PH_2PI_POS    = 19'sb0001100100100001111; //  +2pi   ≈ +6.2831 * 4096
localparam signed [18:0] PH_PI_2_NEG   = 19'sb1111100110110111100; //  -pi/2
localparam signed [18:0] PH_PI_NEG     = 19'sb1111001101101111000; //  -pi
localparam signed [18:0] PH_3PI_2_NEG  = 19'sb1110110100100110100; //  -3pi/2
localparam signed [18:0] PH_2PI_NEG    = 19'sb1110011011011110000; //  -2pi

	// (2.) Element angle: {1, 3, 12}
parameter THETA_E_0  = 19'sh01921;
parameter THETA_E_1  = 19'sh00ED6;
parameter THETA_E_2  = 19'sh007D6;
parameter THETA_E_3  = 19'sh003FA;
parameter THETA_E_4  = 19'sh001FF;
parameter THETA_E_5  = 19'sh000FF;
parameter THETA_E_6  = 19'sh0007F;
parameter THETA_E_7  = 19'sh0003F;
parameter THETA_E_8  = 19'sh0001F;
parameter THETA_E_9  = 19'sh0000F;
parameter THETA_E_10 = 19'sh00007;
parameter THETA_E_11 = 19'sh00003;
parameter THETA_E_12 = 19'sh00001;



	// (3.) Scaling factor: {1, 0, 15}
//parameter S = 15'sb010011011011101;
wire signed [WL_S-1:0] S = 15'sb010011011011101;
// ---------------------------------------------------------



// [3.] Input/Output declaration
input clk;
input rset_n;
//input CORDIC_In_RDY;
input signed [WL_INPUT-1:0] Real_In; 
input signed [WL_INPUT-1:0] Imag_In;
input signed [WL_P_INPUT-1:0] Phase_In;
input CORDIC_mode_In;

output wire signed [WL_INPUT-1:0] Real_Out;
output wire signed [WL_INPUT-1:0] Imag_Out;
output wire signed [WL_P_INPUT-1:0] Phase_Out;
//output reg CORDIC_Out_RDY;

// [4.] buffer declaration:
wire signed [WL_INPUT-1:0] Real_In_buf;
wire signed [WL_INPUT-1:0] Imag_In_buf;
wire signed [WL_P_INPUT-1:0] Phase_In_buf;
wire CORDIC_mode_In_buf;

wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_pipe_stage1;      ////////////////check
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_Y_pipe_stage1;      ////////////////check
wire signed [WL_P_INPUT-1:0] Input_Phase_pipe_stage1;
wire CORDIC_mode_pipe_stage1;
wire signed [WL_INPUT-1:0] Real_In_pipe_buf;         ////////////////check

// [5.] Register & Wire declaration
reg [1:0] Cordic_Cnt; //決定CORDIC執行的cycle數
reg Cnt_RDY;


wire signed [WL_INPUT-1:0] Input_X_v_stage0, Input_Y_v_stage0;
reg signed [WL_INPUT-1:0] Input_X_r_stage0, Input_Y_r_stage0;
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_stage1 , Input_Y_stage1 ; 
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_stage2 , Input_Y_stage2 ; 
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_stage3 , Input_Y_stage3 ; 
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_stage4 , Input_Y_stage4 ; 
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_stage5 , Input_Y_stage5 ; 
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_stage6 , Input_Y_stage6 ; 
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_stage7 , Input_Y_stage7 ; 
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_stage8 , Input_Y_stage8 ; 
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_stage9 , Input_Y_stage9 ; 
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_stage10, Input_Y_stage10; 
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_stage11, Input_Y_stage11; 
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_stage12, Input_Y_stage12; 
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_stage13, Input_Y_stage13; 
wire signed [WL_INPUT+MAG_EXT_BIT-1:0] Input_X_stage14, Input_Y_stage14; 

reg signed [WL_P_INPUT-1:0] Input_Phase_r_stage0;
wire signed [WL_P_INPUT-1:0] Input_Phase_stage1 ;
wire signed [WL_P_INPUT-1:0] Input_Phase_stage2 ;
wire signed [WL_P_INPUT-1:0] Input_Phase_stage3 ;
wire signed [WL_P_INPUT-1:0] Input_Phase_stage4 ;
wire signed [WL_P_INPUT-1:0] Input_Phase_stage5 ;
wire signed [WL_P_INPUT-1:0] Input_Phase_stage6 ;
wire signed [WL_P_INPUT-1:0] Input_Phase_stage7 ;
wire signed [WL_P_INPUT-1:0] Input_Phase_stage8 ;
wire signed [WL_P_INPUT-1:0] Input_Phase_stage9 ;
wire signed [WL_P_INPUT-1:0] Input_Phase_stage10;
wire signed [WL_P_INPUT-1:0] Input_Phase_stage11;
wire signed [WL_P_INPUT-1:0] Input_Phase_stage12;
wire signed [WL_P_INPUT-1:0] Input_Phase_stage13;
wire signed [WL_P_INPUT-1:0] Input_Phase_stage14;


wire signed [WL_INPUT-1:0] Real_Out_Tmp_Tmp;
wire signed [WL_INPUT-1:0] Imag_Out_Tmp_Tmp;
wire signed [WL_INPUT-1:0] Real_Out_Tmp;
wire signed [WL_INPUT-1:0] Imag_Out_Tmp;
wire signed [WL_P_INPUT-1:0] Phase_Out_Tmp;


// [6.] module connection:
// (1.) input register (ok)
//reg_p #(WL_INPUT) D_MAG_0(clk, rset_n, Real_In, Real_In_buf);
//reg_p #(WL_INPUT) D_MAG_1(clk, rset_n, Imag_In, Imag_In_buf);
//reg_p #(WL_P_INPUT) D_PHASE_0(clk, rset_n, Phase_In, Phase_In_buf);
//reg_p D_C_MODE_0 (clk, rset_n, CORDIC_mode_In, CORDIC_mode_In_buf);
assign Real_In_buf = Real_In;
assign Imag_In_buf = Imag_In;
assign Phase_In_buf = Phase_In;
assign CORDIC_mode_In_buf = CORDIC_mode_In;

// (2.) Vectoring Mode Range Detection (ok) 
assign Input_X_v_stage0 = (Real_In_buf[WL_INPUT-1])? (~Real_In_buf+1):(Real_In_buf);
assign Input_Y_v_stage0 = (Real_In_buf[WL_INPUT-1])? (~Imag_In_buf+1):(Imag_In_buf);



// (3.) Roatation Mode Range Detection (ok) => 先轉一部分
always @(Phase_In_buf or Real_In_buf or Imag_In_buf)
begin
	if ((PH_PI_2_POS > Phase_In_buf) && (Phase_In_buf[WL_P_INPUT-1]==0)) // pi/2>Phase>=0 (ok)
	begin
		Input_X_r_stage0 = Real_In_buf;
		Input_Y_r_stage0 = Imag_In_buf;
		Input_Phase_r_stage0 = Phase_In_buf;
	end
	
	else if ((PH_PI_POS > Phase_In_buf) && (Phase_In_buf >= PH_PI_2_POS)) // pi>Phase>=pi/2 (ok)
	begin
		Input_X_r_stage0 = ~Imag_In_buf + 1;
		Input_Y_r_stage0 = Real_In_buf;
		Input_Phase_r_stage0 = Phase_In_buf + PH_PI_2_NEG;  //-pi/2
	end
	
	else if ((PH_3PI_2_POS > Phase_In_buf) && (Phase_In_buf >= PH_PI_POS)) // 3pi/2>Phase>=pi (ok)
	begin
		Input_X_r_stage0 = ~Real_In_buf + 1;
		Input_Y_r_stage0 = ~Imag_In_buf + 1;
		Input_Phase_r_stage0 = Phase_In_buf + PH_PI_NEG;  //-pi
	end
	
	else if ((PH_2PI_POS > Phase_In_buf) && (Phase_In_buf >= PH_3PI_2_POS)) // 2pi>=Phase>=3pi/2 (ok)
	begin
		Input_X_r_stage0 = Imag_In_buf;
		Input_Y_r_stage0 = ~Real_In_buf + 1;
		Input_Phase_r_stage0 = Phase_In_buf + PH_3PI_2_NEG;  //-3pi/2
	end
	
	else if ((Phase_In_buf[WL_P_INPUT-1]==1) && (Phase_In_buf >= PH_PI_2_NEG)) // 0>Phase>=-pi/2
	begin
		Input_X_r_stage0 = Real_In_buf;
		Input_Y_r_stage0 = Imag_In_buf;
		Input_Phase_r_stage0 = Phase_In_buf;
	end
	
	else if ((PH_PI_2_NEG > Phase_In_buf) && (Phase_In_buf >= PH_PI_NEG)) // -pi/2>Phase>-=pi
	begin
		Input_X_r_stage0 = Imag_In_buf;
		Input_Y_r_stage0 = ~Real_In_buf + 1;
		Input_Phase_r_stage0 = Phase_In_buf + PH_PI_2_POS;  //pi/2
	end
	
	else if ((PH_PI_NEG > Phase_In_buf) && (Phase_In_buf >= PH_3PI_2_NEG)) // -pi>Phase>=-3pi/2
	begin
		Input_X_r_stage0 = ~Real_In_buf + 1;
		Input_Y_r_stage0 = ~Imag_In_buf + 1;
		Input_Phase_r_stage0 = Phase_In_buf + PH_PI_POS; //pi
	end
	
	else if ((PH_3PI_2_NEG > Phase_In_buf)&&(Phase_In_buf >= PH_2PI_NEG)) // -3pi/2>Phase>=-2pi
	begin
		Input_X_r_stage0 = ~Imag_In_buf + 1;
		Input_Y_r_stage0 = Real_In_buf;
		Input_Phase_r_stage0 = Phase_In_buf + PH_3PI_2_POS;  //3pi/2
	end
	
	else
	begin
		Input_X_r_stage0 = {WL_INPUT{1'b0}};
		Input_Y_r_stage0 = {WL_INPUT{1'b0}};
		Input_Phase_r_stage0 = {WL_P_INPUT{1'b0}};
	end
end
  //////////////////////////////////////////////////////////////////////////
// (4.) CORDIC Stage Unit Input (1: rotation mode, 0: vectoring mode) (ok)
assign Input_X_stage1 = (CORDIC_mode_In_buf)? ({{MAG_EXT_BIT{Input_X_r_stage0[WL_INPUT-1]}},{Input_X_r_stage0}}):({{MAG_EXT_BIT{Input_X_v_stage0[WL_INPUT-1]}},{Input_X_v_stage0}});
assign Input_Y_stage1 = (CORDIC_mode_In_buf)? ({{MAG_EXT_BIT{Input_Y_r_stage0[WL_INPUT-1]}},{Input_Y_r_stage0}}):({{MAG_EXT_BIT{Input_Y_v_stage0[WL_INPUT-1]}},{Input_Y_v_stage0}});
assign Input_Phase_stage1 = (CORDIC_mode_In_buf)? (Input_Phase_r_stage0):({WL_P_INPUT{1'b0}});

// (5.) CORDIC Stage Unit (ok)
CORDIC_unit_v2 #(0,(WL_INPUT+MAG_EXT_BIT), FL_INPUT, WL_P_INPUT, FL_P_INPUT, THETA_E_0)Stage0x(Input_X_stage1, Input_Y_stage1, Input_Phase_stage1, CORDIC_mode_In_buf, Input_X_stage2 , Input_Y_stage2 , Input_Phase_stage2 );
CORDIC_unit_v2 #(1,(WL_INPUT+MAG_EXT_BIT), FL_INPUT, WL_P_INPUT, FL_P_INPUT, THETA_E_1)Stage1x(Input_X_stage2, Input_Y_stage2, Input_Phase_stage2, CORDIC_mode_In_buf, Input_X_stage3 , Input_Y_stage3 , Input_Phase_stage3 );
CORDIC_unit_v2 #(2,(WL_INPUT+MAG_EXT_BIT), FL_INPUT, WL_P_INPUT, FL_P_INPUT, THETA_E_2)Stage2x(Input_X_stage3, Input_Y_stage3, Input_Phase_stage3, CORDIC_mode_In_buf, Input_X_stage4 , Input_Y_stage4 , Input_Phase_stage4 );
CORDIC_unit_v2 #(3,(WL_INPUT+MAG_EXT_BIT), FL_INPUT, WL_P_INPUT, FL_P_INPUT, THETA_E_3)Stage3x(Input_X_stage4, Input_Y_stage4, Input_Phase_stage4, CORDIC_mode_In_buf, Input_X_stage5 , Input_Y_stage5 , Input_Phase_stage5 );
//reg_p D_MAG_pipe_0 #(MAG_BIT + MAG_EXT_BIT)(clk, rset_n, Input_X_stage5, Input_X_pipe_stage1);
//reg_p D_MAG_pipe_1 #(MAG_BIT + MAG_EXT_BIT)(clk, rset_n, Input_Y_stage5, Input_Y_pipe_stage1);
//reg_p D_PHASE_pipe_0 #(PHASE_BIT)(clk, rset_n, Input_Phase_stage5, Input_Phase_pipe_stage1);
//reg_p D_C_MODE_pipe_0 #(PHASE_BIT)(clk, rset_n, CORDIC_mode_In_buf, CORDIC_mode_pipe_stage1);
//reg_p D_R_Real_pipe_0 #(PHASE_BIT)(clk, rset_n, Real_In_buf, Real_In_pipe_buf);
CORDIC_unit_v2 #(4,(WL_INPUT+MAG_EXT_BIT), FL_INPUT, WL_P_INPUT, FL_P_INPUT, THETA_E_4)Stage4x(Input_X_stage5, Input_Y_stage5, Input_Phase_stage5, CORDIC_mode_In_buf, Input_X_stage6 , Input_Y_stage6 , Input_Phase_stage6 );
CORDIC_unit_v2 #(5,(WL_INPUT+MAG_EXT_BIT), FL_INPUT, WL_P_INPUT, FL_P_INPUT, THETA_E_5)Stage5x(Input_X_stage6, Input_Y_stage6, Input_Phase_stage6, CORDIC_mode_In_buf, Input_X_stage7 , Input_Y_stage7 , Input_Phase_stage7 );
CORDIC_unit_v2 #(6,(WL_INPUT+MAG_EXT_BIT), FL_INPUT, WL_P_INPUT, FL_P_INPUT, THETA_E_6)Stage6x(Input_X_stage7, Input_Y_stage7, Input_Phase_stage7, CORDIC_mode_In_buf, Input_X_stage8 , Input_Y_stage8 , Input_Phase_stage8 );
CORDIC_unit_v2 #(7,(WL_INPUT+MAG_EXT_BIT), FL_INPUT, WL_P_INPUT, FL_P_INPUT, THETA_E_7)Stage7x(Input_X_stage8, Input_Y_stage8, Input_Phase_stage8, CORDIC_mode_In_buf, Input_X_stage9 , Input_Y_stage9 , Input_Phase_stage9 );
CORDIC_unit_v2 #(8,(WL_INPUT+MAG_EXT_BIT), FL_INPUT, WL_P_INPUT, FL_P_INPUT, THETA_E_8)Stage8x(Input_X_stage9, Input_Y_stage9, Input_Phase_stage9, CORDIC_mode_In_buf, Input_X_stage10, Input_Y_stage10, Input_Phase_stage10);
CORDIC_unit_v2 #(9,(WL_INPUT+MAG_EXT_BIT), FL_INPUT, WL_P_INPUT, FL_P_INPUT, THETA_E_9)Stage9x(Input_X_stage10, Input_Y_stage10, Input_Phase_stage10, CORDIC_mode_In_buf, Input_X_stage11 , Input_Y_stage11 , Input_Phase_stage11);
CORDIC_unit_v2 #(10,(WL_INPUT+MAG_EXT_BIT),FL_INPUT, WL_P_INPUT, FL_P_INPUT, THETA_E_10)Stage10x(Input_X_stage11, Input_Y_stage11, Input_Phase_stage11, CORDIC_mode_In_buf, Input_X_stage12, Input_Y_stage12, Input_Phase_stage12);
CORDIC_unit_v2 #(11,(WL_INPUT+MAG_EXT_BIT),FL_INPUT, WL_P_INPUT, FL_P_INPUT, THETA_E_11)Stage11x(Input_X_stage12, Input_Y_stage12, Input_Phase_stage12, CORDIC_mode_In_buf, Input_X_stage13, Input_Y_stage13, Input_Phase_stage13);
CORDIC_unit_v2 #(12,(WL_INPUT+MAG_EXT_BIT),FL_INPUT, WL_P_INPUT, FL_P_INPUT, THETA_E_12)Stage12x(Input_X_stage13, Input_Y_stage13, Input_Phase_stage13, CORDIC_mode_In_buf, Input_X_stage14, Input_Y_stage14, Input_Phase_stage14);

// (6.) Output Range Detection
//assign RealOutTmp  = (CordicMode)? ({{RealIn10x[AmpWL+1]},{RealIn10x[AmpWL-1:1]}}):(10'b0000000000);
//assign ImagOutTmp  = (CordicMode)? ({{ImagIn10x[AmpWL+1]},{ImagIn10x[AmpWL-1:1]}}):(10'b0000000000);
//assign Real_Out_Tmp  = {{Input_X_stage10[MAG_BIT+1]},{Input_X_stage10[MAG_BIT-1:1]}};
//assign Imag_Out_Tmp  = {{Input_Y_stage10[MAG_BIT+1]},{Input_Y_stage10[MAG_BIT-1:1]}};

assign Real_Out_Tmp_Tmp  = {{Input_X_stage14[WL_INPUT + MAG_EXT_BIT-1]},{Input_X_stage14[WL_INPUT-2:0]}};
assign Imag_Out_Tmp_Tmp  = (CORDIC_mode_In_buf)?  {{Input_Y_stage14[WL_INPUT + MAG_EXT_BIT-1]},{Input_Y_stage14[WL_INPUT-2:0]}} : ({WL_INPUT{1'b0}});
// Rotation_mode? => 要不要加回pi?
assign Phase_Out_Tmp = (CORDIC_mode_In_buf)? (Phase_In_buf):( (Real_In_buf[WL_INPUT-1])? ((Input_Phase_stage14) + PH_PI_POS):(Input_Phase_stage14) );
/*
wire signed [MUL_W-1:0] prod_R   = $signed(Real_Out_Tmp_Tmp) * $signed(S);
wire signed [MUL_W-1:0] scaled_R = prod_R >>> FL_S;      // FL_S = 15
assign Real_Out_Tmp  = scaled_R[WL_INPUT-1:0];       // 回到 WL_P_INPUT
wire signed [MUL_W-1:0] prod_I   = $signed(Imag_Out_Tmp_Tmp) * $signed(S);
wire signed [MUL_W-1:0] scaled_I = prod_I >>> FL_S;      // FL_S = 15
assign Imag_Out_Tmp  = scaled_I[WL_INPUT-1:0];       // 回到 WL_P_INPUT
*/

real_mul #(WL_INPUT, FL_INPUT, WL_S, FL_S, WL_INPUT, FL_INPUT) real_mul_R(
    Real_Out_Tmp_Tmp,
    S,
    Real_Out_Tmp
);
real_mul #(WL_INPUT, FL_INPUT, WL_S, FL_S, WL_INPUT, FL_INPUT) real_mul_I(
    Imag_Out_Tmp_Tmp,
    S,
    Imag_Out_Tmp
);

// (7.) output register (ok)
//reg_p #(WL_INPUT) D_MAG_OUT_0(clk, rset_n, Real_Out_Tmp, Real_Out);
//reg_p #(WL_INPUT) D_MAG_OUT_1(clk, rset_n, Imag_Out_Tmp, Imag_Out);
//reg_p #(WL_P_INPUT) D_PHASE_OUT_0(clk, rset_n, Phase_Out_Tmp, Phase_Out);
assign Real_Out = Real_Out_Tmp;
assign Imag_Out = Imag_Out_Tmp;
assign Phase_Out = Phase_Out_Tmp;



endmodule