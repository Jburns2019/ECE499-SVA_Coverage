clear -all
analyze -sv controller.sv
elaborate -top controller
clock clk -factor 1 -phase 1
#Allow reset to change.
reset -none

#Spec. 9
#Check that if there is a scenario in which M1 should have indefinite access it always has indefinite access.
#  If there are no requests and no module access
#  followed by a cycle with a reqest for M1.
#  The M1 module should have access from the next clock cycle until it is done.
assert -name a_M1_id_access_tcl {
    @(posedge clk) disable iff(reset)
        !req && !accmodule
        |=> req[0]
        |=> accmodule == 2'b01 until done[0]
};

#Spec. 12
assert -name a_oscillating_tie_breaker_tcl {
    @(posedge clk) disable iff(reset)
        req == 3'b110 && !accmodule
        |=> accmodule == 2'b10
        |=> accmodule == 2'b10 && done[1]
        |-> ##[0:$] req == 3'b110
        |=> accmodule == 2'b11 && !done[2] && !req[0]
        |=> accmodule == 2'b11
};
cover -name c_oscillating_tie_breaker_tcl {
    @(posedge clk) disable iff(reset)
        req == 3'b110 && !accmodule
        |=> accmodule == 2'b10
        |=> accmodule == 2'b10 && done[1]
        |-> ##[0:$] req == 3'b110
        |=> accmodule == 2'b11 && !done[2] && !req[0]
        |=> accmodule == 2'b11
};

prove -all