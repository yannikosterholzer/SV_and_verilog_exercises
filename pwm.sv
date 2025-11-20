`timescale 1us/1ns
module pwm (
  input  logic                clk_i,
  input  logic                res_ni,
  input  logic unsigned [7:0] set_thres_i,
  input  logic unsigned [7:0] clr_thres_i,
  input  logic unsigned [7:0] reload_i,
  output logic                pwm_o
);

logic unsigned [7:0]  cnt, clrtr, sttr;
localparam  logic   [7:0]  MXCNT = 8'hFF;

always_ff @(posedge clk_i or negedge res_ni)
	if (!res_ni)
		{cnt, clrtr, sttr} <= 0;
	else begin
		cnt   <= (cnt == MXCNT)? reload_i    : cnt + 1;
        clrtr <= (cnt == MXCNT)? clr_thres_i : clrtr;
        sttr  <= (cnt == MXCNT)? set_thres_i : sttr;
    end

 
always_ff @(posedge clk_i or negedge res_ni)
	if (!res_ni)
		pwm_o <= 1'b0;
	else begin
        if (sttr == clrtr ) //prioritize clearing if both thresholds are the same
		  pwm_o <= 1'b0;
		else begin 
		   if((cnt == reload_i)&&((sttr < reload_i) || (clrtr < reload_i)))begin 
		      if(sttr < clrtr) 
		          if(clrtr < reload_i)
		              pwm_o <= 1'b0;
		          else
		              pwm_o <= 1'b1;
		   end
		   else begin
		     if (cnt == sttr)
                pwm_o <= 1'b1;
             else if (cnt == clrtr) 
                pwm_o <= 1'b0;
		   end
	    end		
    end

endmodule
