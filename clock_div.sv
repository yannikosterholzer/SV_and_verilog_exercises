`timescale 1ns / 1ps

module clock_div(
    input  logic       clk_i,
    input  logic       aresn_i,
    input  logic [5:0] n_i,
    input  logic       ld,
    output logic       clk_o
    );
    
        
    logic co_next;
    logic [5:0] counter, next;
    always_ff @(posedge clk_i or negedge aresn_i) begin: COUNTER_REG
        if(~aresn_i) begin
            counter <= 0;
            clk_o   <= 0;
        end else begin
            counter <= next;
            clk_o   <= co_next;
        end
    end
    
    always_comb begin: TRANSITION_LOGIC
        if(counter == 0) begin
            next    = (ld)? ((n_i > 1)? n_i - 1 : 0 ) : 0;
            co_next = (ld)? clk_o ^ 1 : clk_o;
        end else begin
            next    = counter - 1;    
            co_next = clk_o;
        end
    end
                
endmodule
