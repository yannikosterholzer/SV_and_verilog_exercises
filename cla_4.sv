module cla_4    
(
    input  logic [3:0] a_i, b_i,
    input  logic       c_i,
    output logic       c_o, 
    output logic [3:0] s_o
    );
    
    logic [3:0] g; // generate
    logic [3:0] p; // propagate
    logic [4:0] c; // carries
    
    assign c[0] = c_i;
    assign c[1] = g[0] | p[0] & c[0];
    assign c[2] = g[1] | p[1] & g[0] | p[1] & p[0] & c[0];
    assign c[3] = g[2] | p[2] & g[1] | p[2] & p[1] & g[0] | p[2] & p[1] & p[0] & c[0];
    assign c[4] = g[3] | p[3] & g[2] | p[3] & p[2] & g[1] | p[3] & p[2] & p[1] & g[0] | p[3] & p[2] & p[1] & p[0] & c[0]; 
    assign c_o  = c[4];
   
    genvar gv;
    generate
        for(gv = 0; gv < 4; gv++) begin: stage
            assign g[gv]   = a_i[gv] & b_i[gv];
            assign p[gv]   = a_i[gv] ^ b_i[gv];
            assign s_o[gv] = p[gv]   ^ c[gv];
        end
    endgenerate 
    
endmodule
