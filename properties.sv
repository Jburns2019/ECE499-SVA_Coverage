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

//Trial assertions to get a feel for more complex assertions.
//  Additionally they are the basis for some larger assertions, so they give a little more information.
a_M1_it_access:
    assert property(
        @(posedge clk) disable iff(reset)
            !accmodule && (req[M2] || req[M3])
            |=> (accmodule == 2'b10 && !done[M2] || accmodule == 2'b11 && !done[M3]) && req[M1]
            |=> accmodule == 2'b01
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
            |=> (accmodule == 2'b01 until done[M1])
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
            |=> (accmodule == 2'b10 && !done[M2] || accmodule == 2'b11 && !done[M3]) && req[M1]
            |=> accmodule == 2'b01 && !done[M1]
            |=> accmodule == 2'b01
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
        |=> (accmodule == 2'b10 && !done[M2] || accmodule == 2'b11 && !done[M3]) && req[M1]
        |=> accmodule == 2'b01 && !done[M1]
        |=> accmodule == 2'b01 && !req[M1]
        |=> accmodule != 2'b01
    )
    else $error("Interrupting M1 had access for more than 2 cycles.");
  
//Spec. 11
//Check that M1 cannot get access before the clock edge.
//  If M1 does not have access and M1 requests access
//  then M1 shouldn't get access at the end of this clock cycle.
a_module_granted_M1_access_before_on_posedge: 
    assert property(
        @(posedge clk) disable iff(reset)
            accmodule != 2'b01 && req[M1]
            |-> ##0 accmodule != 2'b01
    )
    else $error("M1 got access before the clock edge.");
//Check that M1 cannot get access before the clock edge.
//  If M1 does not have access and M1 requests access
//  then M1 shouldn't get access at the end of this clock cycle.
a_module_granted_M1_access_on_posedge:
    assert property(
        @(posedge clk) disable iff(reset)
            req[M1]
            |=> accmodule == 2'b01
    )
    else $error("M1 did not get access when it requested.");
//Check that M2 cannot get access before the clock edge.
//  If M2 does not have access and M2 requests access
//  then M2 shouldn't get access at the end of this clock cycle.
a_module_granted_M2_access_before_on_posedge:
    assert property(
        @(posedge clk) disable iff(reset)
            accmodule != 2'b10 && req[M2]
            |-> ##0 accmodule != 2'b10
    )
    else $error("M2 got access before the clock edge.");
a_module_granted_M2_access_on_posedge:
    assert property(
        @(posedge clk) disable iff(reset)
            !accmodule && req[M2] && !req[M1] && !req[M3]
            |=> accmodule == 2'b10
    )
    else $error("M2 did not get access when it requested.");
//Check that M3 cannot get access before the clock edge.
//  If M3 does not have access and M3 requests access
//  then M3 shouldn't get access at the end of this clock cycle.
a_module_granted_M3_access_before_on_posedge:
    assert property(
        @(posedge clk) disable iff(reset)
            accmodule != 2'b11 && req[M3]
            |-> ##0 accmodule != 2'b11
    )
    else $error("M3 got access before the clock edge.");
a_module_granted_M3_access_on_posedge:
    assert property(
        @(posedge clk) disable iff(reset)
            !accmodule && req[M3] && !req[M1] && !req[M2]
            |=> accmodule == 2'b11
    )
    else $error("M3 did not get access when it requested.");
  
//Spec. 13
a_M2_2_cycle_access:
    assert property(
        @(posedge clk) disable iff(reset)
            !req && !accmodule
            |=> req[M2]
            |=> accmodule == 2'b10 && !done[M2] && !req[M1]
            |=> accmodule == 2'b10 && !req[M2]
            |=> accmodule != 2'b10
    )
    else $error("M2 did not get 2 cycles of access when it should have.");
a_M3_2_cycle_access:
    assert property(
        @(posedge clk) disable iff(reset)
            !req && !accmodule
            |=> req[M3]
            |=> accmodule == 2'b11 && !done[M3] && !req[M1]
            |=> accmodule == 2'b11 && !req[M3]
            |=> accmodule != 2'b11
    )
    else $error("M3 did not get 2 cycles of access when it should have.");

//Spec. 14  
a_M1_smooth_M2:
    assert property(
        @(posedge clk) disable iff(reset)
            req[M1]
            |=> accmodule == 2'b01 && !done[M1] && !req[M1]
            |=> accmodule == 2'b01 && done[M1] && !req[M3] && req[M2]
            |=> accmodule == 2'b10
    )
    else $error("There was not a smooth transition to M2 from M1.");
a_M1_smooth_M3: 
    assert property(
        @(posedge clk) disable iff(reset)
            req[M1]
            |=> accmodule == 2'b01 && !done[M1] && !req[M1]
            |=> accmodule == 2'b01 && done[M1] && !req[M2] && req[M3]
            |=> accmodule == 2'b11
    )
    else $error("There was not a smooth transition to M3 from M1.");
a_M2_smooth_M1:
    assert property(
        @(posedge clk) disable iff(reset)
            req[M2]
            |=> accmodule == 2'b10 && !done[M2] && !req[M2]
            |=> accmodule == 2'b10 && done[M2] && !req[M3] && req[M1]
            |=> accmodule == 2'b01
    )
    else $error("There was not a smooth transition to M1 from M2.");
a_M2_smooth_M3:
    assert property(
        @(posedge clk) disable iff(reset)
            req[M2]
            |=> accmodule == 2'b10 && !done[M2] && !req[M2]
            |=> accmodule == 2'b10 && done[M2] && !req[M1] && req[M3]
            |=> accmodule == 2'b11
    )
    else $error("There was not a smooth transition to M3 from M2.");
a_M3_smooth_M1:
    assert property(
        @(posedge clk) disable iff(reset)
            req[M3]
            |=> accmodule == 2'b11 && !done[M3] && !req[M3]
            |=> accmodule == 2'b11 && done[M3] && !req[M2] && req[M1]
            |=> accmodule == 2'b01
    )
    else $error("There was not a smooth transition to M1 from M3.");
a_M3_smooth_M2:
    assert property(
        @(posedge clk) disable iff(reset)
            req[M3]
            |=> accmodule == 2'b11 && !done[M3] && !req[M3]
            |=> accmodule == 2'b11 && done[M3] && !req[M1] && req[M2]
            |=> accmodule == 2'b10
    )
    else $error("There was not a smooth transition to M2 from M3.");

//Spec. 7
a_req_M1:
    assume property(
        @(posedge clk) disable iff(reset)
            req[M1]
            |=> !req[M1]
    );
a_req_M2:
    assume property(
        @(posedge clk) disable iff(reset)
            req[M2]
            |=> !req[M2]
    );
a_req_M3:
    assume property(
        @(posedge clk) disable iff(reset)
            req[M3]
            |=> !req[M3]
    );

//Sepc. 15
a_done_M1:
    assume property(
        @(posedge clk) disable iff(reset)
            done[M1]
            |=> !done[M1]
    );
a_done_M2:
    assume property(
        @(posedge clk) disable iff(reset)
            done[M2]
            |=> !done[M2]
    );
a_done_M3:
    assume property(
        @(posedge clk) disable iff(reset)
            done[M3]
            |=> !done[M3]
    );

//Spec. 16
a_no_req_and_done_M1:
    assume property(
        @(posedge clk)
            disable iff(reset)
            !done[M1] || !req[M1]
    );
a_no_req_and_done_M2:
    assume property(
        @(posedge clk)
            disable iff(reset)
            !done[M2] || !req[M2]
    );
a_no_req_and_done_M3:
    assume property(
        @(posedge clk)
            disable iff(reset)
            !done[M3] || !req[M3]
    );
endmodule