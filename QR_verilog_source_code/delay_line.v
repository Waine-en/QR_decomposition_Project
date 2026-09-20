module delay_line #(
    parameter integer WIDTH = 16,
    parameter integer DELAY = 2     // >= 1
)(
    input  wire             clk,
    input  wire             rset_n,  // async active-low reset
    input  wire [WIDTH-1:0] din,
    output wire [WIDTH-1:0] dout
);

integer i;
reg [WIDTH-1:0] pipe [0:DELAY-1];

always @(posedge clk or negedge rset_n) begin
    if (!rset_n) begin
        for (i = 0; i < DELAY; i = i + 1)
            pipe[i] <= {WIDTH{1'b0}};
    end else begin
        pipe[0] <= din;
        for (i = 1; i < DELAY; i = i + 1)
            pipe[i] <= pipe[i-1];
    end
end

assign dout = pipe[DELAY-1];

endmodule