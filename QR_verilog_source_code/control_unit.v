module control_unit(
  //input:
  clk,
  rst_n,
  
  //output:
  Cycle_counter,
  PE_control
);

input clk, rst_n;
reg [2:0] Cycle_counter_D;  //0~7;
output reg [2:0] Cycle_counter;  //0~7;
output reg [7:0] PE_control;

always @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
//	PE_control <= {8{1'b0}};
	Cycle_counter_D <= 3'b000;
	Cycle_counter <= 3'b000;
  end
  else begin
	Cycle_counter_D <= Cycle_counter_D + 1'b1;
	Cycle_counter <= Cycle_counter + 1'b1;
  end
	  
end

always @(*) begin
	case (Cycle_counter)
		3'b111: PE_control = 8'b11011111;  //20
		3'b001:	PE_control = 8'b10111110;  //41
		3'b010: PE_control = 8'b11111101;  //02
		3'b011: PE_control = 8'b11111011;  //04		
		3'b100: PE_control = 8'b11110111;  //08
		3'b101: PE_control = 8'b11101111;  //10
		default:PE_control = 8'b11111111;
	endcase	 
end



endmodule