clear -all
analyze -sv controller.sv
elaborate -top controller
clock clk -factor 1 -phase 1
reset -analyze -synchronous -list signal -silent
reset -expression {reset}

#Spec. 4
#Reset should remove module access as soon as its asserted.
assert -name a_reset {
    @(posedge clk)
        reset
        |-> $past(accmodule)
        |-> !accmodule
};

#Spec. 9
#Check that if there is a scenario in which M1 should have indefinite access it always has indefinite access.
#  If there are no requests and no module access
#  followed by a cycle with a reqest for M1.
#  The M1 module should have access from the next clock cycle until it is done.
assert -name a_M1_id_access {
    @(posedge clk) disable iff(reset)
        !req && !accmodule
        |=> req[0]
        |=> (accmodule == 2'b01 until done[0])
};

prove -all