`timescale 1ns / 1ps

module tb_vending_machine;

    // DUT interface
    logic clk_i;
    logic aresn_i;
    logic ct50_i;
    logic ret_i;
    logic rel_i;
    logic rel_o;
    logic ret_o;

    // enable/disable output of states, etc.
    bit print_enable;

    // Clock
    initial clk_i = 1'b0;
    always #5 clk_i = ~clk_i;

    // DUT
    vending_machine dut (
        .clk_i  (clk_i),
        .ct50_i (ct50_i),
        .aresn_i(aresn_i),
        .ret_i  (ret_i),
        .rel_i  (rel_i),
        .rel_o  (rel_o),
        .ret_o  (ret_o)
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

    // internal states of DUT
    state_t tb_state;
    state_t tb_next_state;
    assign tb_state      = dut.state;
    assign tb_next_state = dut.next_state;

    // Strings for output of internal states
    string s_state;
    string s_next;

    function string state_to_str(input state_t s);
        case (s)
            S_IDLE  : state_to_str = "S_IDLE ";
            S_WAIT1 : state_to_str = "S_WAIT1";
            S_CT50  : state_to_str = "S_CT50 ";
            S_WAIT2 : state_to_str = "S_WAIT2";
            S_CT100 : state_to_str = "S_CT100";
            S_REL   : state_to_str = "S_REL  ";
            S_RET   : state_to_str = "S_RET  ";
            default : state_to_str = "UNDEF ";
        endcase
    endfunction

    always_comb begin
        s_state = state_to_str(tb_state);
        s_next  = state_to_str(tb_next_state);
    end

    // output only, when print_enable=1
    initial begin
        forever begin
            @(posedge clk_i);
            if (print_enable) begin
                $display(" %7s    %7s |   %b    %b   %b |   %b     %b",
                         s_state,
                         s_next,
                         ct50_i, rel_i, ret_i,
                         rel_o, ret_o);
            end
        end
    end

    // Tasks for generating stimuli
    task reset;
        begin
            aresn_i = 1'b0;
            ct50_i  = 1'b0;
            rel_i   = 1'b0;
            ret_i   = 1'b0;
            repeat (2) @(posedge clk_i);
            aresn_i = 1'b1;
            @(posedge clk_i);
        end
    endtask

    // Insert 50-cent coin, pulse
    task put_coin_50;
        begin
            ct50_i = 1'b1;
            @(posedge clk_i);  // one clock cycle with active input
            ct50_i = 1'b0;
            @(posedge clk_i);
        end
    endtask
	
	// Insert 50-cent coin, continuous for 10 cycles
    task put_coin_50_continuous;
        begin
            ct50_i = 1'b1;
            repeat (10) @(posedge clk_i);
            ct50_i = 1'b0;
        end
    endtask

    task select_release;
        begin
            rel_i = 1'b1;
            @(posedge clk_i);
            rel_i = 1'b0;
        end
    endtask

    task press_return;
        begin
            ret_i = 1'b1;
            @(posedge clk_i);
            ret_i = 1'b0;
        end
    endtask

    task check_output(
        input string name,
        input logic  exp_rel,
        input logic  exp_ret,
        input int    test_interval
    );
        bit     match;
        logic   match_rel, match_ret;
        state_t match_state, match_next;
        string  match_state_str, match_next_str;
        int     i;
    
        match       = 1'b0;
        match_rel   = 1'b0;
        match_ret   = 1'b0;
        match_state = tb_state;
        match_next  = tb_next_state;
    
        // check for test_interval cycles
        for (i = 0; i < test_interval; i++) begin
            @(posedge clk_i);
            if (!match && rel_o == exp_rel && ret_o == exp_ret) begin
                match        = 1'b1;
                match_rel    = rel_o;
                match_ret    = ret_o;
                match_state  = tb_state;
                match_next   = tb_next_state;
            end
        end
    
        if (match) begin
            match_state_str = state_to_str(match_state);
            match_next_str  = state_to_str(match_next);
    
            // Display, when test is passed
            $display("%s: PASS!  expected (rel_o,ret_o)=(%0b,%0b), observed=(%0b,%0b) at state=%s, next=%s\n",
                     name,
                     exp_rel, exp_ret,
                     match_rel, match_ret,
                     match_state_str, match_next_str);
        end
        else begin
            // Display, when test failed
            $display("%s: FAIL!  expected (rel_o,ret_o)=(%0b,%0b) within %0d cycles, last values were (rel_o,ret_o)=(%0b,%0b), state=%s, next=%s\n",
                     name,
                     exp_rel, exp_ret, test_interval,
                     rel_o, ret_o,
                     s_state, s_next);
        end
    endtask


    initial begin
        print_enable = 1'b0;
        $dumpfile("tb_vending_machine.vcd");
        $dumpvars(0, tb_vending_machine);

        // Test 1
        $display("\n--- Test 1: 2x50 + select ---");
        $display("state    next_state | ct50 rel ret | rel_o ret_o");
        $display("----------------------------------------------------------");
        fork
            begin : CHECK1
                print_enable = 1'b1;
                check_output("Test 1: 2x50 + select", 1'b1, 1'b0, 10);
                print_enable = 1'b0;
            end
            begin : STIM1
                reset();
                put_coin_50();
                put_coin_50();
                select_release();
            end
        join
        repeat (3) @(posedge clk_i);

        // Test 2
        $display("\n--- Test 2: 3x50 + return ---");
        $display("state    next_state | ct50 rel ret | rel_o ret_o");
        $display("----------------------------------------------------------");
        fork
            begin : CHECK2
                print_enable = 1'b1;
                check_output("Test 2: 3x50 + return", 1'b0, 1'b1, 10);
                print_enable = 1'b0;
            end
            begin : STIM2
                reset();
                put_coin_50();
                put_coin_50();
                put_coin_50();
                press_return();
            end
        join
        repeat (3) @(posedge clk_i);

        // Test 3
        $display("\n--- Test 3: 2x50 + return ---");
        $display("state    next_state | ct50 rel ret | rel_o ret_o");
        $display("----------------------------------------------------------");
        fork
            begin : CHECK3
                print_enable = 1'b1;
                check_output("Test 3: 2x50 + return", 1'b0, 1'b1, 10);
                print_enable = 1'b0;
            end
            begin : STIM3
                reset();
                put_coin_50();
                put_coin_50();
                press_return();
            end
        join
        repeat (3) @(posedge clk_i);

        // Test 4
        $display("\n--- Test 4: 1x50 + return ---");
        $display("state    next_state | ct50 rel ret | rel_o ret_o");
        $display("----------------------------------------------------------");
        fork
            begin : CHECK4
                print_enable = 1'b1;
                check_output("Test 4: 1x50 + return", 1'b0, 1'b1, 10);
                print_enable = 1'b0;
            end
            begin : STIM4
                reset();
                put_coin_50();
                press_return();
            end
        join
        repeat (3) @(posedge clk_i);

        // Test 5
        $display("\n--- Test 5: fall through ---");
        $display("state    next_state | ct50 rel ret | rel_o ret_o");
        $display("----------------------------------------------------------");
        fork
            begin : CHECK5
                print_enable = 1'b1;
                check_output("Test 5: test fall trough", 1'b0, 1'b0, 10);
                print_enable = 1'b0;
            end
            begin : STIM5
                reset();
                put_coin_50_continuous();
            end
        join

        $finish;
    end


endmodule
