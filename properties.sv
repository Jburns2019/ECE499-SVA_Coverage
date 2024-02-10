`ifdef FORMAL

property p_not_IDLE;
    @(posedge reset) accmodule != '0;
endproperty

property p_reset;
    @(posedge reset) ##0 !accmodule;
endproperty

property p_req_M1;
    @(posedge clk) req[0] |=> !req[0];
endproperty
property p_req_M2;
    @(posedge clk) req[1] |=> !req[1];
endproperty
property p_req_M3;
    @(posedge clk) req[2] |=> !req[2];
endproperty

property p_done_M1;
    @(posedge clk) done[0] |=> !done[0];
endproperty
property p_done_M2;
    @(posedge clk) done[1] |=> !done[1];
endproperty
property p_done_M3;
    @(posedge clk) done[2] |=> !done[2];
endproperty

// spec. 12
property p_M2_M3_oscilating_tie_breaker;
    @(posedge clk) (req == 3'b110 && accmodule == 2'b10) |-> ##[1:$] (req == 3'b110 && accmodule == 2'b11)
endproperty

// spec. 13
property p_atmost_2_cycles_M2;
    // @(posedge clk) accmodule == 2'b10 |=> accmodule == 2'b10 |=> accmodule != 2'b10;
    @(posedge clk) req[M2] |=> $rose(req[M2]) |=> $stable(req[M2]) |=> $fell(req[M2]);
endproperty
property p_atmost_2_cycles_M3;
    @(posedge clk) req[M3] |=> $rose(req[M3]) |=> $stable(req[M3]) |=> $fell(req[M3]);
endproperty

// spec. 16
property p_req_done_opposite_M1;
    @(posedge clk) (req[M1] && done[M1]) == 0;
endproperty
property p_req_done_opposite_M2;
    @(posedge clk) (req[M2] && done[M2]) == 0;
endproperty
property p_req_done_opposite_M3;
    @(posedge clk) (req[M3] && done[M3]) == 0;
endproperty

`endif