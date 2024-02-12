module properties(
  input clk,
  input reset,
  input [2:0] req,
  input [2:0] done,
  input logic [4:0] mstate, // 1-hot encoded
  input logic [1:0] accmodule,
  input integer nb_interrupts  // nb of interruptions
);

    parameter M1 = 0;
    parameter M2 = 1;
    parameter M3 = 2;
    parameter state_M1 = 2'b01;
    parameter state_M2 = 2'b10;
    parameter state_M3 = 2'b11;

//Trial assertions to get a feel for more complex assertions.
//  Additionally they are the basis for some larger assertions, so they give a little more information.
a_M1_it_access:
    assert property(
        @(posedge clk) disable iff(reset)
            !accmodule && (req[M2] || req[M3])
            |=> (accmodule == state_M2 && !done[M2] || accmodule == 2'b11 && !done[M3]) && req[M1]
            |=> accmodule == state_M1
    )
    else $error("M1 did not interrupt M2 or M3.");

//Spec. 4
//Reset should remove module access as soon as its asserted.
a_reset:
    assert property(
        @(posedge clk)
            reset
            |-> $past(accmodule)
            |-> !accmodule
    )
    else $error("Reset did not change accmodule.");

//Spec. 9
//Check that if there is a scenario in which M1 should have indefinite access it always has indefinite access.
//  If there are no requests and no module access
//  followed by a cycle with a reqest for M1.
//  The M1 module should have access from the next clock cycle until it is done.
a_M1_id_access:
    assert property(
        @(posedge clk) disable iff(reset)
            !req && !accmodule
            |=> req[M1]
            |=> (accmodule == state_M1 until done[M1])
    )
    else $error("M1 did not get indefinite access.");

//Check that there is a scenario in which M1 should have access for 2 cycles it always has access for 2 cycles.
//  If no module has access
//  followed by a cycle with M2 or M3 having access, M1 requesting access, and no done signals
//  followed by a cycle with M1 having access and not being done with it
//  Then M1 should hve access on the next clock cycle.
a_M1_it_2_cycle_access:
    assert property(
        @(posedge clk) disable iff(reset)
            !accmodule && (req[M2] || req[M3])
            |=> (accmodule == state_M2 && !done[M2] || accmodule == 2'b11 && !done[M3]) && req[M1]
            |=> accmodule == state_M1 && !done[M1]
            |=> accmodule == state_M1
    )
    else $error("Interrupting M1 had access for atleast 2 cycles.");
//Check that there is a scenario in which M1 cannot have access for 3 cycles from an interrupt.
//  If no module has access
//  followed by a cycle with M2 or M3 having access, M1 requesting access, and no done signals
//  followed by a cycle with M1 having access and not being done with it
//  followed by a cycle with M1 having access and not requesting M1 access
//  Then M1 can't have access the next clock cycle.
a_M1_no_it_3_cycle_access:
    assert property(
        @(posedge clk)
        disable iff(reset)
        !accmodule && (req[M2] || req[M3])
        |=> (accmodule == state_M2 && !done[M2] || accmodule == 2'b11 && !done[M3]) && req[M1]
        |=> accmodule == state_M1 && !done[M1]
        |=> accmodule == state_M1 && !req[M1]
        |=> accmodule != state_M1
    )
    else $error("Interrupting M1 had access for more than 2 cycles.");

//Spec. 11
a_module_granted_M1_access_before_on_posedge: 
    assert property(not_granted_access_before_posedge(M1, state_M1))
    else $error("M1 got access before the clock edge.");
a_module_granted_M1_access_on_posedge:
    assert property(granted_access_on_posedge(3'b001, state_M1))
    else $error("M1 did not get access when it requested.");
a_module_granted_M2_access_before_on_posedge:
    assert property(not_granted_access_before_posedge(M2, state_M2))
    else $error("M2 got access before the clock edge.");
a_module_granted_M2_access_on_posedge:
    assert property(granted_access_on_posedge(3'b010, state_M2))
    else $error("M2 did not get access when it requested.");
a_module_granted_M3_access_before_on_posedge:
    assert property(not_granted_access_before_posedge(M3, 2'b11))
    else $error("M3 got access before the clock edge.");
a_module_granted_M3_access_on_posedge:
    assert property(granted_access_on_posedge(3'b100, 2'b11))
    else $error("M3 did not get access when it requested.");

//Check that module_num cannot get access before the clock edge.
//  If module_num does not have access and module_num requests access
//  then module_num shouldn't get access at the end of this clock cycle.
property not_granted_access_before_posedge(module_num, module_state);
    @(posedge clk) disable iff(reset)
        accmodule != module_state && req[module_num]
        |-> ##0 accmodule != module_state
endproperty

//Check that a module always gets access when it requests it.
//  If only a module requests access while no other module has access
//  then that module should get access in the next clock cycle.
property granted_access_on_posedge(req_state, module_state);
    @(posedge clk) disable iff(reset)
        (!accmodule || req_state[M1]) && req == req_state
        |=> accmodule == module_state
endproperty

//Spec. 13
a_M2_2_cycle_access:
    assert property(two_cycle_access(M2, state_M2))
    else $error("M2 did not get 2 cycles of access when it should have.");
a_M3_2_cycle_access:
    assert property(two_cycle_access(M3, 2'b11))
    else $error("M3 did not get 2 cycles of access when it should have.");

//Check that module_num can get atleast 2 cycles of access, but cannot get 3 cycles of access.
//  If there are no requests and no modules have access
//  followed by a cycle where module_num requests access.
//  followed by a cycle where module_num gets access, module_num is not done, and M1 does not request access
//  followed by a cycle where module_num gets access and module_num does not request access (instead of asserting done)
//  then module_num should not have access on the next cycle.
property two_cycle_access(module_num, module_state);
    @(posedge clk) disable iff(reset)
        !req && !accmodule
        |=> req[module_num]
        |=> accmodule == module_state && !done[module_num] && !req[M1]
        |=> accmodule == module_state && !req[module_num]
        |=> accmodule != module_state;
endproperty

//Spec. 14  
a_M1_smooth_M2:
    assert property(smooth_transition(M1, M2, M3, state_M1, state_M2))
    else $error("There was not a smooth transition to M2 from M1.");
a_M1_smooth_M3: 
    assert property(smooth_transition(M1, M3, M2, state_M1, 2'b11))
    else $error("There was not a smooth transition to M3 from M1.");
a_M2_smooth_M1:
    assert property(smooth_transition(M2, M1, M3, state_M2, state_M1))
    else $error("There was not a smooth transition to M1 from M2.");
a_M2_smooth_M3:
    assert property(smooth_transition(M2, M3, M1, state_M2, 2'b11))
    else $error("There was not a smooth transition to M3 from M2.");
a_M3_smooth_M1:
    assert property(smooth_transition(M3, M1, M2, 2'b11, state_M1))
    else $error("There was not a smooth transition to M1 from M3.");
a_M3_smooth_M2:
    assert property(smooth_transition(M3, M2, M1, 2'b11, state_M2))
    else $error("There was not a smooth transition to M2 from M3.");

//Check that module_num_from can transition smoothly to module_num_to.
//  If module_num_from requests
//  followed by a cylce where module_num_from has access and module_num_from is not done
//  followed by a cycle where module_num_from has access, module_num_from is done, no request for the other module_num, and module_num_to requests
//  then module_num_to should get access.
property smooth_transition(module_num_from, module_num_to, module_num_unused, module_state_from, module_state_to);
    @(posedge clk) disable iff(reset)
        req[module_num_from]
        |=> accmodule == module_state_from && !done[module_num_from]
        |=> accmodule == module_state_from && done[module_num_from] && !req[module_num_unused] && req[module_num_to]
        |=> accmodule == module_state_to
endproperty;

//Spec. 7
a_req_M1:
    assume property(asserted_for_only_1_cycle(req, M1));
a_req_M2:
    assume property(asserted_for_only_1_cycle(req, M2));
a_req_M3:
    assume property(asserted_for_only_1_cycle(req, M3));

//Sepc. 15
a_done_M1:
    assume property(asserted_for_only_1_cycle(done, M1));
a_done_M2:
    assume property(asserted_for_only_1_cycle(done, M2));
a_done_M3:
    assume property(asserted_for_only_1_cycle(done, M3));

//Ensure that a signal is not raised for more than 1 cycle.
//  If the signal for the module is asserted
//  then the signal must be deasserted.
property asserted_for_only_1_cycle(signal, module_num);
    @(posedge clk) disable iff(reset)
        signal[module_num]
        |=> !signal[module_num]
endproperty

//Spec. 16
a_no_req_and_done_M1:
    assume property(not_both_asserted(M1));
a_no_req_and_done_M2:
    assume property(not_both_asserted(M2));
a_no_req_and_done_M3:
    assume property(not_both_asserted(M3));

//Ensure that done and req are not asserted at the same time for a module.
//  Need to have either the done signal deasserted or the req signal deasserted. 
property not_both_asserted(module_num);
    @(posedge clk) disable iff(reset)
        !done[module_num] || !req[module_num]
endproperty
endmodule