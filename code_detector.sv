`timescale 1ns / 1ps

module code_detector(
        input  logic clk_i,
        input  logic a_resn_i,
        input  logic start_i,
        input  logic r_i,g_i,b_i,
        input  logic a_i,
        output logic u_o
    );
    
    typedef enum logic [2:0]{
        S_IDLE,
        S_START,
        S_RED0,
        S_BLUE,
        S_GREEN,
        S_RED1
    }state_t;
    
    state_t state, next_state;
        
    always_ff @(posedge clk_i or negedge a_resn_i) begin: STATE_REG
        if(~a_resn_i) 
            state <= S_IDLE;
        else
            state <= next_state;
    end
    
    logic red, green, blue;
    assign red    =  r_i & ~g_i & ~b_i;
    assign green  = ~r_i &  g_i & ~b_i;
    assign blue   = ~r_i & ~g_i &  b_i;
      
    always_comb begin: TRANSITION_LOGIC
        case(state)
        S_IDLE:  next_state =  (start_i & ~a_i)? S_START : S_IDLE;
        S_START: next_state =  (red)?     S_RED0  : ((a_i)? S_IDLE: S_START);
        S_RED0:  next_state =  (blue)?    S_BLUE  : ((a_i)? S_IDLE: S_RED0);
        S_BLUE:  next_state =  (green)?   S_GREEN : ((a_i)? S_IDLE: S_BLUE);
        S_GREEN: next_state =  (red)?     S_RED1  : ((a_i)? S_IDLE: S_GREEN);
        S_RED1:  next_state =  S_RED1;    //unlocked until reset
        default: next_state =  S_IDLE;
        endcase  
    end    
    
    always_comb begin: OUTPUT_LOGIC
        u_o = (state == S_RED1)? 1 : 0;
    end
endmodule
