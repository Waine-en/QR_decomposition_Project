`timescale 1 ns/10 ps
`define CYCLE 10
module QR_test;
// (1.) parameter setting:
parameter WL_INPUT = 20;                    // {1,5,14} Amplitude WordLength 
parameter FL_INPUT = 14;
parameter WL_P_INPUT = 19;                     // {1,3,12} Phase WordLength
parameter FL_P_INPUT = 13;
parameter MAG_EXT_BIT = 0;                    // {1,0,9} Amplitude WordLength 

parameter first_cycle = 7;    // 最初的7個cycle
parameter output_cycle = 8;    // 每8個cycle為一組資料
parameter symbol_number = 1000;    // 要模擬多少個symbol
parameter Cycle_number = first_cycle + (output_cycle * symbol_number);

parameter PE_number = 7;
parameter systolic_dim = 4;
parameter input_len = output_cycle*symbol_number;

integer err_cnt;
integer cmp_cnt;
integer addr;
reg compare;
// (2.) input/output declaration:
reg clk, rset_n;
reg signed [WL_INPUT-1:0] input_A_r;
reg signed [WL_INPUT-1:0] input_B_r;
reg signed [WL_INPUT-1:0] input_C_r;
reg signed [WL_INPUT-1:0] input_D_r;
reg signed [WL_INPUT-1:0] input_A_i;
reg signed [WL_INPUT-1:0] input_B_i;
reg signed [WL_INPUT-1:0] input_C_i;
reg signed [WL_INPUT-1:0] input_D_i;

reg signed [WL_INPUT-1:0] gold_input_A_r[0:input_len - 1]; 
reg signed [WL_INPUT-1:0] gold_input_A_i[0:input_len - 1]; 
reg signed [WL_INPUT-1:0] gold_input_B_r[0:input_len - 1]; 
reg signed [WL_INPUT-1:0] gold_input_B_i[0:input_len - 1]; 
reg signed [WL_INPUT-1:0] gold_input_C_r[0:input_len - 1]; 
reg signed [WL_INPUT-1:0] gold_input_C_i[0:input_len - 1]; 
reg signed [WL_INPUT-1:0] gold_input_D_r[0:input_len - 1]; 
reg signed [WL_INPUT-1:0] gold_input_D_i[0:input_len - 1]; 

reg signed [WL_INPUT-1:0] gold_output_A_r[0:input_len - 1]; 
reg signed [WL_INPUT-1:0] gold_output_A_i[0:input_len - 1]; 
reg signed [WL_INPUT-1:0] gold_output_B_r[0:input_len - 1]; 
reg signed [WL_INPUT-1:0] gold_output_B_i[0:input_len - 1]; 
reg signed [WL_INPUT-1:0] gold_output_C_r[0:input_len - 1]; 
reg signed [WL_INPUT-1:0] gold_output_C_i[0:input_len - 1]; 
reg signed [WL_INPUT-1:0] gold_output_D_r[0:input_len - 1]; 
reg signed [WL_INPUT-1:0] gold_output_D_i[0:input_len - 1]; 

wire signed [WL_INPUT-1:0] output_A_r;
wire signed [WL_INPUT-1:0] output_B_r;
wire signed [WL_INPUT-1:0] output_C_r;
wire signed [WL_INPUT-1:0] output_D_r;
wire signed [WL_INPUT-1:0] output_A_i;
wire signed [WL_INPUT-1:0] output_B_i;
wire signed [WL_INPUT-1:0] output_C_i;
wire signed [WL_INPUT-1:0] output_D_i;
// (3.) circuit declaration:
QR_top #(WL_INPUT, FL_INPUT, WL_P_INPUT, FL_P_INPUT, MAG_EXT_BIT) QR1(
	//input
	clk,  				//ok 
	rset_n,				//ok 
	
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




// ======================================================
// Compare logic: when compare==1, compare DATA_NUMBER samples
// ======================================================
reg done;
always @(posedge clk or negedge rset_n) begin
    if (!rset_n) begin
        err_cnt <= 0;
        cmp_cnt <= 0;
        done    <= 1'b0;
    end else begin
        if (!done && compare) begin
            // mismatch output A detection via !==
            if ( (output_A_r !== gold_output_A_r[cmp_cnt]) ||
                 (output_A_i !== gold_output_A_i[cmp_cnt]) ) begin
                err_cnt <= err_cnt + 1;
                $display("[%0t] MISMATCH output_A_r idx=%0d (gold_addr=%0d)",
                         $time, cmp_cnt, cmp_cnt);
                $display("    OUT : real=%0d (0x%0h), imag=%0d (0x%0h)",
                         output_A_r, output_A_r, output_A_i, output_A_i);
                $display("    GOLD: real=%0d (0x%0h), imag=%0d (0x%0h)\n",
                         gold_output_A_r[cmp_cnt], gold_output_A_r[cmp_cnt],
                         gold_output_A_i[cmp_cnt], gold_output_A_i[cmp_cnt]);
            end
			
            // mismatch output B detection via !==
            if ( (output_B_r !== gold_output_B_r[cmp_cnt]) ||
                 (output_B_i !== gold_output_B_i[cmp_cnt]) ) begin
                err_cnt <= err_cnt + 1;
                $display("[%0t] MISMATCH output_B_r idx=%0d (gold_addr=%0d)",
                         $time, cmp_cnt, cmp_cnt);
                $display("    OUT : real=%0d (0x%0h), imag=%0d (0x%0h)",
                         output_B_r, output_B_r, output_B_i, output_B_i);
                $display("    GOLD: real=%0d (0x%0h), imag=%0d (0x%0h)\n",
                         gold_output_B_r[cmp_cnt], gold_output_B_r[cmp_cnt],
                         gold_output_B_i[cmp_cnt], gold_output_B_i[cmp_cnt]);
            end
			
            // mismatch output C detection via !==
            if ( (output_C_r !== gold_output_C_r[cmp_cnt]) ||
                 (output_C_i !== gold_output_C_i[cmp_cnt]) ) begin
                err_cnt <= err_cnt + 1;
                $display("[%0t] MISMATCH output_C_r idx=%0d (gold_addr=%0d)",
                         $time, cmp_cnt, cmp_cnt);
                $display("    OUT : real=%0d (0x%0h), imag=%0d (0x%0h)",
                         output_C_r, output_C_r, output_C_i, output_C_i);
                $display("    GOLD: real=%0d (0x%0h), imag=%0d (0x%0h)\n",
                         gold_output_C_r[cmp_cnt], gold_output_C_r[cmp_cnt],
                         gold_output_C_i[cmp_cnt], gold_output_C_i[cmp_cnt]);
            end
			
            // mismatch output D detection via !==
            if ( (output_D_r !== gold_output_D_r[cmp_cnt]) ||
                 (output_D_i !== gold_output_D_i[cmp_cnt]) ) begin
                err_cnt <= err_cnt + 1;
                $display("[%0t] MISMATCH output_D_r idx=%0d (gold_addr=%0d)",
                         $time, cmp_cnt, cmp_cnt);
                $display("    OUT : real=%0d (0x%0h), imag=%0d (0x%0h)",
                         output_D_r, output_D_r, output_D_i, output_D_i);
                $display("    GOLD: real=%0d (0x%0h), imag=%0d (0x%0h)\n",
                         gold_output_D_r[cmp_cnt], gold_output_D_r[cmp_cnt],
                         gold_output_D_i[cmp_cnt], gold_output_D_i[cmp_cnt]);
            end

            // advance gold address / compare count
            if (cmp_cnt == input_len-1) begin
                done <= 1'b1;
                // 用 strobe 讓 err_cnt 的 NBA 更新後再印
				$strobe("================================================\n");
				$strobe("================================================\n");
				$strobe("==== COMPARE DONE: total=%0d, errors=%0d ====\n", input_len, err_cnt);
				$strobe("================================================\n");
				$strobe("================================================\n");
                // 給一點點時間讓 $strobe 印完
                #10 $finish;
            end else begin
                cmp_cnt <= cmp_cnt + 1;
            end
        end
    end
end
// ======================================================
// Compare logic end
// ======================================================





// ======================================================
// 給input:
// ======================================================
initial begin
	#(`CYCLE*0.75);
	rset_n = 1; 
end
initial begin
	rset_n = 0; 
	clk = 1;
	addr = 0;
	input_A_r = {WL_INPUT{1'b0}};
	input_B_r = {WL_INPUT{1'b0}};
	input_C_r = {WL_INPUT{1'b0}};
	input_D_r = {WL_INPUT{1'b0}};
	input_A_i = {WL_INPUT{1'b0}};
	input_B_i = {WL_INPUT{1'b0}};
	input_C_i = {WL_INPUT{1'b0}};
	input_D_i = {WL_INPUT{1'b0}};

	compare = 1'b0;
	
	// 讀input/output檔案
	$readmemh("./result1/input_A_r.mem", gold_input_A_r);
	$readmemh("./result1/input_A_i.mem", gold_input_A_i);
	$readmemh("./result1/input_B_r.mem", gold_input_B_r);
	$readmemh("./result1/input_B_i.mem", gold_input_B_i);
	$readmemh("./result1/input_C_r.mem", gold_input_C_r);
	$readmemh("./result1/input_C_i.mem", gold_input_C_i);
	$readmemh("./result1/input_D_r.mem", gold_input_D_r);
	$readmemh("./result1/input_D_i.mem", gold_input_D_i);

	$readmemh("./result1/output_A_r.mem", gold_output_A_r);
	$readmemh("./result1/output_A_i.mem", gold_output_A_i);
	$readmemh("./result1/output_B_r.mem", gold_output_B_r);
	$readmemh("./result1/output_B_i.mem", gold_output_B_i);
	$readmemh("./result1/output_C_r.mem", gold_output_C_r);
	$readmemh("./result1/output_C_i.mem", gold_output_C_i);
	$readmemh("./result1/output_D_r.mem", gold_output_D_r);
	$readmemh("./result1/output_D_i.mem", gold_output_D_i);
	
	
 // 對齊到下一個 posedge 再開始送（避免半拍對不齊）
  @(negedge clk);
  // === 給 input：每 cycle addr+1 並送出 mem ===
	// Vector mode:
  repeat (input_len) begin
	input_A_r = gold_input_A_r[addr];
	input_A_i = gold_input_A_i[addr];
	input_B_r = gold_input_B_r[addr];
	input_B_i = gold_input_B_i[addr];
	input_C_r = gold_input_C_r[addr];
	input_C_i = gold_input_C_i[addr];
	input_D_r = gold_input_D_r[addr];
	input_D_i = gold_input_D_i[addr];
  
	if (addr == 7) begin
		compare = 1'b1;
	end
	
	if (addr <= input_len) begin
		addr = addr + 1;
	end
	else begin
		addr = addr;
	end

    @(negedge clk);
  end
  
	 
	 
	#(`CYCLE*10); 
	$finish;
end
// ======================================================
// 給input (end)
// ======================================================













always begin
	#(`CYCLE*0.5) clk=~clk;
end

initial
begin
//$fsdbDumpfile("Conv_test.fsdb");
//$fsdbDumpvars;
//wait(addr == 7950);
$dumpfile("QR_test.fsdb");
$dumpvars;

//$dumpoff;


//$dumpfile("TESTVG.vcd");
//$dumpvars;
//$sdf_annotate("XXX.sdf", testtop);
end 
endmodule