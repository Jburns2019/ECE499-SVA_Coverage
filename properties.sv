`ifdef FORMAL

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

`endif