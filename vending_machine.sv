`timescale 1ns / 1ps


module vending_machine(
    input  clk_i,
    input  logic ct50_i,
    input  logic aresn_i,
    input  logic ret_i,
    input  logic rel_i,
    output logic rel_o,
    output logic ret_o
    );
    
    typedef enum logic [2:0] {
      S_IDLE,
      S_WAIT1,
      S_CT50,
      S_WAIT2,      
      S_CT100,
      S_REL,
      S_RET
    } state_t;
    state_t state, next_state;
    
    always_ff @(posedge clk_i or negedge aresn_i) begin: STATE_REG
        if(!aresn_i)
            state <= S_IDLE;
        else
            state <= next_state;
    end
    always_comb begin: TRANSITION_LOGIC
        case(state)
         S_IDLE : next_state = (ct50_i)? S_WAIT1 : S_IDLE;
         S_WAIT1: next_state = (ct50_i)? S_WAIT1 : S_CT50;
         S_CT50 : next_state = (ret_i)?  S_RET  : ((ct50_i)? S_WAIT2 : S_CT50);
         S_WAIT2: next_state = (ct50_i)? S_WAIT2 : S_CT100;
         S_CT100: next_state = (ret_i | ct50_i)?  S_RET  : ((rel_i) ? S_REL   : S_CT100);
         default: next_state =  S_IDLE;
        endcase
    end
          
   logic [1:0] out;
   assign {rel_o, ret_o} = out;     
   always_comb begin: OUTPUT_LOGIC
        case(state)
         S_REL  : out = 2'b10;
         S_RET  : out = 2'b01;
         default: out = 2'b00;
        endcase
   end        
           
endmodule
