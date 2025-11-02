
module tiny_alu(
    input  logic [7:0] a_i, b_i,
    input  logic [1:0] alu_op_i,
    output logic [7:0] res_o,
    output logic [3:0] flags
    );
    
    
    logic [7:0] res, adder_res, and_res, or_res;  
    logic       v_add, v_sub; 
    logic [7:0] op2;
    logic n, z, c, o;
    logic c_alu, c_in;
    
    //Arithmetic Operations
    cla_8 DUT (
        .a_i(a_i),
        .b_i(op2),
        .c_i(c_in),
        .c_o(c_alu),
        .s_o(adder_res)
    );
    //Bitwise Logic
    assign res_o = res;
    assign and_res = a_i & b_i;
    assign or_res  = a_i | b_i;
     
     
    always_comb begin
        case(alu_op_i)
             2'b10:   res = and_res;
             2'b11:   res = or_res;
             default: begin
                     res = adder_res;
                     case(alu_op_i)
                          2'b01  : begin
                                   op2   = ~b_i;
                                   c_in  = 1'b1;
                                   end
                          default: begin
                                   op2   = b_i;
                                   c_in  = 1'b0;
                                   end
                      endcase 
                      end
        endcase
    end
       
    // Flags
    assign flags = {n, z, c, o};
    assign n = res[7];
    assign z = ~(|res);
    assign c = (alu_op_i == 2'b00 || alu_op_i == 2'b01)? c_alu : 0;
    //signed overflow
    assign v_add = (~(a_i[7] ^ b_i[7])) & (adder_res[7] ^ a_i[7]); 
    assign v_sub =   (a_i[7] ^ b_i[7])   & (adder_res[7] ^ a_i[7]); 
    assign o = (alu_op_i == 2'b00) ? v_add : (alu_op_i == 2'b01) ? v_sub : 1'b0; 
    
endmodule

    
endmodule
