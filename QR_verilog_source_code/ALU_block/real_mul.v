module real_mul #(
    parameter integer WA = 16,
    parameter integer FA = 15,
    parameter integer WB = 16,
    parameter integer FB = 15,
    parameter integer WY = 16,
    parameter integer FY = 15
)(
    input  wire signed [WA-1:0] a,
    input  wire signed [WB-1:0] b,
    output wire signed [WY-1:0] y
);

    // ============================================================
    // 1) Internal format selection
    //    實數乘法後:
    //      y = a * b
    //
    //    乘積的小數位數為 FA+FB
    // ============================================================
    localparam integer FINT = FA + FB;

    // 單一乘積位寬
    localparam integer WMUL = WA + WB;

    // 為了後續轉成 FY，若 FY > FINT，左移可能需要更多位元
    localparam integer FSHIFT_UP = (FY > FINT) ? (FY - FINT) : 0;
    localparam integer WCVT = WMUL + FSHIFT_UP;

    // ============================================================
    // 2) Multiplication
    // ============================================================
    wire signed [WMUL-1:0] mul;

    assign mul = a * b;

    // ============================================================
    // 3) Convert from internal format (WMUL, FINT) to output (WY, FY)
    //    - FY < FINT : arithmetic right shift => truncation
    //    - FY > FINT : left shift
    // ============================================================
    wire signed [WCVT-1:0] mul_ext;
    assign mul_ext = {{(WCVT-WMUL){mul[WMUL-1]}}, mul};

    wire signed [WCVT-1:0] y_full;

    generate
        if (FY >= FINT) begin : GEN_LEFT_SHIFT
            assign y_full = $signed(mul_ext) <<< (FY - FINT);
        end else begin : GEN_RIGHT_SHIFT
            assign y_full = $signed(mul_ext) >>> (FINT - FY);
        end
    endgenerate

    // ============================================================
    // 4) Output truncation to WY bits
    //    保留原始 sign bit，其餘保留低位 bits
    // ============================================================
  //  assign y = {y_full[WCVT-1], y_full[WY-2:0]};
	generate
		if (WY >= WCVT) begin
			assign y = {{(WY-WCVT){y_full[WCVT-1]}}, y_full};
		end else begin
			assign y = y_full[WY-1:0];
			//assign y = {y_full[WCVT-1], y_full[WY-2:0]};
		end
	endgenerate
endmodule