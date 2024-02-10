`ifdef ASSERTIONS
property p_reset;
    @(posedge clk) accmodule && reset |=> !accmodule;
endproperty

property p_M1_in_access;
    @(posedge clk)
        disable iff(reset) req[0] |=> accmodule == 2'b01;
endproperty

property p_M1_it_access;
    @(posedge clk)
        disable iff(reset) !accmodule |=> (accmodule == 2'b10 || accmodule == 2'b11) && req[0] && !done[1] && !done[2] |=> accmodule == 2'b01;
endproperty

//Spec. 9
property p_M1_id_access;
    @(posedge clk)
        disable iff(reset) !req && !accmodule |=> req[0] |=> (accmodule == 2'b01 until done[0]);
endproperty
property p_M1_it_2_cycle_access;
    @(posedge clk)
        disable iff(reset) !accmodule |=> (accmodule == 2'b10 || accmodule == 2'b11) && req[0] && !done[1] && !done[2] |=> accmodule == 2'b01 && !done[1] |=> accmodule == 2'b01 && !req[0] |=> accmodule != 2'b01;
endproperty

//Spec. 13
property p_M2_2_cycle_access;
    @(posedge clk)
        disable iff(reset) !req && !accmodule |=> req[1] |=> accmodule == 2'b10 && !done[1] && !req[0] |=> accmodule == 2'b10 && !req[1] |=> accmodule != 2'b10;
endproperty
property p_M3_2_cycle_access;
    @(posedge clk)
        disable iff(reset) !req && !accmodule |=> req[2] |=> accmodule == 2'b11 && !done[2] && !req[0] |=> accmodule == 2'b11 && !req[2] |=> accmodule != 2'b11;
endproperty

//Spec. 16
property p_no_req_and_done_M1;
    @(posedge clk)
        disable iff(reset) !done[0] || !req[0];
endproperty
property p_no_req_and_done_M2;
    @(posedge clk)
        disable iff(reset) !done[1] || !req[1];
endproperty
property p_no_req_and_done_M3;
    @(posedge clk)
        disable iff(reset) !done[2] || !req[2];
endproperty


property p_req_M1;
    @(posedge clk)
        disable iff(reset) req[0] |=> !req[0];
endproperty
property p_req_M2;
    @(posedge clk)
        disable iff(reset) req[1] |=> !req[1];
endproperty
property p_req_M3;
    @(posedge clk)
        disable iff(reset) req[2] |=> !req[2];
endproperty

property p_done_M1;
    @(posedge clk)
        disable iff(reset) done[0] |=> !done[0];
endproperty
property p_done_M2;
    @(posedge clk)
        disable iff(reset) done[1] |=> !done[1];
endproperty
property p_done_M3;
    @(posedge clk)
        disable iff(reset) done[2] |=> !done[2];
endproperty
`endif