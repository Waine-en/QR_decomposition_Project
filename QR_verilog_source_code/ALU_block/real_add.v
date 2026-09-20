module real_add #(
    parameter integer WA = 16,
    parameter integer FA = 15,
    parameter integer WB = 15,
    parameter integer FB = 14,
    parameter integer WY = 17,
    parameter integer FY = 15
)(
    input  wire signed [WA-1:0] a,
    input  wire signed [WB-1:0] b,
    output wire signed [WY-1:0] y
);

    // ============================================================
    // 1) Internal format selection
    //    將 a / b 先對齊到相同的小數位數 FINT
    // ============================================================
    localparam integer FINT = (FA > FB) ? FA : FB;

    // 對齊後所需 bit-width
    localparam integer WAI  = WA + (FINT - FA);
    localparam integer WBI  = WB + (FINT - FB);

    // 加法結果需要多 1 bit guard bit
    localparam integer WSUM = ((WAI > WBI) ? WAI : WBI) + 1;

    // 為了後續轉成 FY，若 FY > FINT，左移可能需要更多位元
    localparam integer FSHIFT_UP = (FY > FINT) ? (FY - FINT) : 0;
    localparam integer WCVT = WSUM + FSHIFT_UP;

    // ============================================================
    // 2) Sign extension + fractional alignment
    // ============================================================
    // 2.1) Sign extension
    wire signed [WAI-1:0] a_ext;
    wire signed [WBI-1:0] b_ext;

    assign a_ext = {{(WAI-WA){a[WA-1]}}, a};
    assign b_ext = {{(WBI-WB){b[WB-1]}}, b};

    // 2.2) fractional alignment
    wire signed [WAI-1:0] a_aligned;
    wire signed [WBI-1:0] b_aligned;

    assign a_aligned = $signed(a_ext) <<< (FINT - FA);
    assign b_aligned = $signed(b_ext) <<< (FINT - FB);

    // ============================================================
    // 3) Addition
    // ============================================================
    wire signed [WSUM-1:0] sum;

    assign sum =
        $signed({a_aligned[WAI-1], a_aligned}) +
        $signed({b_aligned[WBI-1], b_aligned});

    // ============================================================
    // 4) Convert from internal format (WSUM, FINT) to output (WY, FY)
    //    - FY < FINT : arithmetic right shift => truncation
    //    - FY > FINT : left shift
    // ============================================================
    wire signed [WCVT-1:0] sum_ext;
    assign sum_ext = {{(WCVT-WSUM){sum[WSUM-1]}}, sum};

    wire signed [WCVT-1:0] y_full;

    generate
        if (FY >= FINT) begin : GEN_LEFT_SHIFT
            assign y_full = $signed(sum_ext) <<< (FY - FINT);
        end else begin : GEN_RIGHT_SHIFT
            assign y_full = $signed(sum_ext) >>> (FINT - FY);
        end
    endgenerate

    // ============================================================
    // 5) Output truncation to WY bits
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