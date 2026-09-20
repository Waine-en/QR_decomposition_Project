module real_trunc #(
    parameter integer WA = 16,
    parameter integer FA = 15,
    parameter integer WB = 16,
    parameter integer FB = 15
)(
    input  wire signed [WA-1:0] a,
    output wire signed [WB-1:0] y
);

    // ============================================================
    // 1) Internal format selection
    //    將 input (WA, FA) 轉成 output (WB, FB)
    // ============================================================
    localparam integer FSHIFT_UP = (FB > FA) ? (FB - FA) : 0;
    localparam integer WCVT = WA + FSHIFT_UP;

    // ============================================================
    // 2) Sign extension
    // ============================================================
    wire signed [WCVT-1:0] a_ext;
    assign a_ext = {{(WCVT-WA){a[WA-1]}}, a};

    // ============================================================
    // 3) Convert from input format (WA, FA) to output fractional bits FB
    //    - FB < FA : arithmetic right shift => truncation
    //    - FB > FA : left shift
    // ============================================================
    wire signed [WCVT-1:0] y_full;

    generate
        if (FB >= FA) begin : GEN_LEFT_SHIFT
            assign y_full = $signed(a_ext) <<< (FB - FA);
        end else begin : GEN_RIGHT_SHIFT
            assign y_full = $signed(a_ext) >>> (FA - FB);
        end
    endgenerate

    // ============================================================
    // 4) Output truncation to WB bits
    //    保留原始 sign bit，其餘保留低位 bits
    // ============================================================
   // assign y = {y_full[WCVT-1], y_full[WB-2:0]};
	generate
		if (WB >= WCVT) begin
			assign y = {{(WB-WCVT){y_full[WCVT-1]}}, y_full};
		end else begin
			assign y = y_full[WB-1:0];
			//assign y = {y_full[WCVT-1], y_full[WB-2:0]};
		end
	endgenerate
endmodule