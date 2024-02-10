`ifdef ASSERTIONS

//Spec. 4
property p_reset;
    @(posedge clk)
        reset
        |-> $past(accmodule)
        |-> !accmodule;
endproperty

//Spec. 9
property p_M1_id_access;
    @(posedge clk)
        disable iff(reset)
        !req && !accmodule
        |=> req[M1]
        |=> (accmodule == 2'b01 until done[M1]);
endproperty
property p_M1_it_2_cycle_access;
    @(posedge clk)
        disable iff(reset)
        !accmodule
        |=> (accmodule == 2'b10 || accmodule == 2'b11) && req[M1] && !done[M2] && !done[M3]
        |=> accmodule == 2'b01 && !done[M2]
        |=> accmodule == 2'b01 && !req[M1]
        |=> accmodule != 2'b01;
endproperty

//Spec. 11
property p_module_granted_M1_access_before_on_posedge;
    @(posedge clk)
        disable iff(reset)
        accmodule != 2'b01 && req[M1]
        |-> ##0 accmodule != 2'b01
        |=> accmodule == 2'b01;
endproperty
property p_module_granted_M2_access_before_on_posedge;
    @(posedge clk)
        disable iff(reset)
        accmodule != 2'b10 && req[M2]
        |-> ##0 accmodule != 2'b10
        |=> accmodule == 2'b10;
endproperty
property p_module_granted_M3_access_before_on_posedge;
    @(posedge clk)
        disable iff(reset)
        accmodule != 2'b11 && req[M3]
        |-> ##0 accmodule != 2'b11
        |=> accmodule == 2'b11;
endproperty

property p_module_granted_M1_access_on_posedge;
    @(posedge clk)
        disable iff(reset)
        req[M1]
        |=> accmodule == 2'b01;
endproperty
property p_module_granted_M2_access_on_posedge;
    @(posedge clk)
        disable iff(reset)
        !accmodule && req[M2] && !req[M1] && !req[M3]
        |=> accmodule == 2'b10;
endproperty
property p_module_granted_M3_access_on_posedge;
    @(posedge clk)
        disable iff(reset)
        !accmodule && req[M3] && !req[M1] && !req[M2]
        |=> accmodule == 2'b11;
endproperty

//Spec. 13
property p_M2_2_cycle_access;
    @(posedge clk)
        disable iff(reset)
        !req && !accmodule
        |=> req[M2]
        |=> accmodule == 2'b10 && !done[M2] && !req[M1]
        |=> accmodule == 2'b10 && !req[M2]
        |=> accmodule != 2'b10;
endproperty
property p_M3_2_cycle_access;
    @(posedge clk)
        disable iff(reset)
        !req && !accmodule
        |=> req[M3]
        |=> accmodule == 2'b11 && !done[M3] && !req[M1]
        |=> accmodule == 2'b11 && !req[M3]
        |=> accmodule != 2'b11;
endproperty

//Spec. 14
property p_M1_smooth_transition_M2;
    @(posedge clk)
        disable iff(reset)
        req[M1]
        |=> accmodule == 2'b01 && !done && !req[M1]
        |=> accmodule == 2'b01 && done[M1] && !req[M1] && !req[M3] && req[M2]
        |=> accmodule == 2'b10;
endproperty
property p_M1_smooth_transition_M3;
    @(posedge clk)
        disable iff(reset)
        req[M1]
        |=> accmodule == 2'b01 && !done && !req[M1]
        |=> accmodule == 2'b01 && done[M1] && !req[M1] && !req[M2] && req[M3]
        |=> accmodule == 2'b11;
endproperty
property p_M2_smooth_transition_M1;
    @(posedge clk)
        disable iff(reset)
        req[M2]
        |=> accmodule == 2'b10 && !done && !req[M2]
        |=> accmodule == 2'b10 && done[M2] && !req[M2] && !req[M3] && req[M1]
        |=> accmodule == 2'b01;
endproperty
property p_M2_smooth_transition_M3;
    @(posedge clk)
        disable iff(reset)
        req[M2]
        |=> accmodule == 2'b10 && !done && !req[M2]
        |=> accmodule == 2'b10 && done[M2] && !req[M2] && !req[M1] && req[M3]
        |=> accmodule == 2'b11;
endproperty
property p_M3_smooth_transition_M1;
    @(posedge clk)
        disable iff(reset)
        req[M3]
        |=> accmodule == 2'b11 && !done && !req[M3]
        |=> accmodule == 2'b11 && done[M3] && !req[M3] && !req[M2] && req[M1]
        |=> accmodule == 2'b01;
endproperty
property p_M3_smooth_transition_M2;
    @(posedge clk)
        disable iff(reset)
        req[M3]
        |=> accmodule == 2'b11 && !done && !req[M3]
        |=> accmodule == 2'b11 && done[M3] && !req[M3] && !req[M1] && req[M2]
        |=> accmodule == 2'b10;
endproperty

//Spec. 16
property p_no_req_and_done_M1;
    @(posedge clk)
        disable iff(reset)
        !done[M1] || !req[M1];
endproperty
property p_no_req_and_done_M2;
    @(posedge clk)
        disable iff(reset)
        !done[M2] || !req[M2];
endproperty
property p_no_req_and_done_M3;
    @(posedge clk)
        disable iff(reset)
        !done[M3] || !req[M3];
endproperty

//Trial assertions to get a feel for more complex assertions.
//  Additionally they are the basis for some larger assertions, so they give a little more information.
property p_M1_it_access;
    @(posedge clk)
        disable iff(reset)
        !accmodule
        |=> (accmodule == 2'b10 || accmodule == 2'b11) && req[M1] && !done[M2] && !done[M3]
        |=> accmodule == 2'b01;
endproperty

property p_req_M1;
    @(posedge clk)
        disable iff(reset)
        req[M1]
        |=> !req[M1];
endproperty
property p_req_M2;
    @(posedge clk)
        disable iff(reset)
        req[M2]
        |=> !req[M2];
endproperty
property p_req_M3;
    @(posedge clk)
        disable iff(reset)
        req[M3]
        |=> !req[M3];
endproperty

property p_done_M1;
    @(posedge clk)
        disable iff(reset)
        done[M1]
        |=> !done[M1];
endproperty
property p_done_M2;
    @(posedge clk)
        disable iff(reset)
        done[M2]
        |=> !done[M2];
endproperty
property p_done_M3;
    @(posedge clk)
        disable iff(reset)
        done[M3]
        |=> !done[M3];
endproperty
`endif