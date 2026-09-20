module CORDIC_unit_v2 #(parameter Stage = 0, 
parameter WL_AMP = 0, parameter FL_AMP = 0, 
parameter WL_PH = 0, parameter FL_PH = 0, 
parameter PhaseRam = 0
)(
	// input
	real_in,
	imag_in,
	phase_in,
	cordic_mode,
	// output
	real_out,
	imag_out,
	phase_out
);
// Parameter declaration
//parameter Stage = 0;                     // CORDIC Stage =>決定算數位移多少bits
//parameter AmpWL = 0;                     // Amplitude WordLength 
//parameter PhWL = 0;                      // Phase WordLength
//parameter PhaseRam = 14'b00000000000000;   // Phase Ram 

// Input/Output declaration
input signed [WL_AMP-1:0] real_in;
input signed [WL_AMP-1:0] imag_in;
input signed [WL_PH-1:0] phase_in;
input cordic_mode;
output wire signed [WL_AMP-1:0] real_out;
output wire signed [WL_AMP-1:0] imag_out;
output wire signed [WL_PH-1:0] phase_out;


// Register & Wire declaration
wire signed [WL_AMP-1:0] real_shift;
wire signed [WL_AMP-1:0] imag_shift;


wire signed [WL_AMP-1:0] X_ADD_Ysh;
wire signed [WL_AMP-1:0] X_SUB_Ysh;
wire signed [WL_AMP-1:0] Y_ADD_Xsh;
wire signed [WL_AMP-1:0] Y_SUB_Xsh;
wire signed [WL_PH-1:0] Z_ADD_Pram;
wire signed [WL_PH-1:0] Z_SUB_Pram;

// CORDIC Stage Unit                
//                real_in                imag_in
//                   |                      |
//                   |                      |
//             -------------          -------------
//            |             |        |             |
//            |           -----    -----           |
//            |          | >> S|  | >> S|          |
//            |           -----    -----           |
//            |              \       /             |
//            |               ---X---              |
//            |              /       \             |
//            |             /         \            |
//         ---------------------   ---------------------
//        |      ADD/SUB        | |      ADD/SUB        |
//         ---------------------   --------------------- 
//                   |                      |
//                real_out               imag_out

// CORDIC Stage Update Equation
// Vector (Phase) Mode (cordic_mode=0)
//       Y>=0 : 順時針轉                Y<0 : 逆時針轉
//       Y>=0 : X' = X + (Y>>Stage)    Y<0 : X' = X - (Y>>Stage) 
//              Y' = Y - (X>>Stage)          Y' = Y + (X>>Stage) 
//              Z' = Z + PhaseRam            Z' = Z - PhaseRam   
// Roataion Mode (cordic_mode=1)
//       Z>=0 : 逆時針轉                Z<0 : 順時針轉
//       Z>=0 : X' = X - (Y>>Stage)    Z<0 : X' = X + (Y>>Stage) 
//              Y' = Y + (X>>Stage)          Y' = Y - (X>>Stage) 
//              Z' = Z - PhaseRam            Z' = Z + PhaseRam   


// Shifter (算數位移)
assign real_shift = { {Stage{real_in[WL_AMP-1]}}, {real_in[WL_AMP-1:Stage]}};
assign imag_shift = { {Stage{imag_in[WL_AMP-1]}}, {imag_in[WL_AMP-1:Stage]}};


real_add #(WL_AMP, FL_AMP, WL_AMP, FL_AMP, WL_AMP, FL_AMP)R_X_ADD_Ysh(real_in, imag_shift, X_ADD_Ysh);
real_sub #(WL_AMP, FL_AMP, WL_AMP, FL_AMP, WL_AMP, FL_AMP)R_X_SUB_Ysh(real_in, imag_shift, X_SUB_Ysh);
real_add #(WL_AMP, FL_AMP, WL_AMP, FL_AMP, WL_AMP, FL_AMP)R_Y_ADD_Xsh(imag_in, real_shift, Y_ADD_Xsh);
real_sub #(WL_AMP, FL_AMP, WL_AMP, FL_AMP, WL_AMP, FL_AMP)R_Y_SUB_Xsh(imag_in, real_shift, Y_SUB_Xsh);
real_add #(WL_PH, FL_PH, WL_PH, FL_PH, WL_PH, FL_PH)R_Z_ADD_Pram(phase_in, PhaseRam, Z_ADD_Pram);
real_sub #(WL_PH, FL_PH, WL_PH, FL_PH, WL_PH, FL_PH)R_Z_SUB_Pram(phase_in, PhaseRam, Z_SUB_Pram);


// CORDIC Stage Output
assign real_out = (cordic_mode)? ((phase_in[WL_PH-1])? (X_ADD_Ysh):(X_SUB_Ysh))  :  ((imag_in[WL_AMP-1])? (X_SUB_Ysh):(X_ADD_Ysh));
assign imag_out = (cordic_mode)? ((phase_in[WL_PH-1])? (Y_SUB_Xsh):(Y_ADD_Xsh))  :  ((imag_in[WL_AMP-1])? (Y_ADD_Xsh):(Y_SUB_Xsh));
assign phase_out = (cordic_mode)? ((phase_in[WL_PH-1])? (Z_ADD_Pram):(Z_SUB_Pram))   :  ((imag_in[WL_AMP-1])? (Z_SUB_Pram):(Z_ADD_Pram));


endmodule