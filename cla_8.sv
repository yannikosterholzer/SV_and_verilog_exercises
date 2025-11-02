
module cla_8(
    input  logic [7:0] a_i, b_i,
    input  logic       c_i,
    output logic       c_o, 
    output logic [7:0] s_o
    );
    

       cla_4 u_cla_lo (
        .a_i(a_i[3:0]),     
        .b_i(b_i[3:0]),     
        .c_i(c_i),  
        .c_o(clo), 
        .s_o(s_o[3:0])    
       );
       cla_4 u_cla_hi (
        .a_i(a_i[7:4]),     
        .b_i(b_i[7:4]),     
        .c_i(clo),  
        .c_o(c_o), 
        .s_o(s_o[7:4])    
       );
    
endmodule
