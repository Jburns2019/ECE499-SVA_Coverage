clear -all
analyze -sv controller.sv
elaborate -top controller
clock clk -factor 1 -phase 1
reset -analyze -synchronous -list signal -silent
reset -expression {reset}

assert -name a_M1_it_access {
    @(posedge clk) disable iff(reset)
        !accmodule && (req[1] || req[2])
        |=> (accmodule == 2'b10 && !done[1] || accmodule == 2'b11 && !done[2]) && req[0]
        |=> accmodule == 2'b01
};

assert -name a_reset {
    @(posedge clk)
        reset
        |-> $past(accmodule)
        |-> !accmodule
};

assert -name a_M1_id_access {
    @(posedge clk) disable iff(reset)
        !req && !accmodule
        |=> req[0]
        |=> (accmodule == 2'b01 until done[0])
};

assert -name a_M1_it_2_cycle_access {
    @(posedge clk) disable iff(reset)
        !accmodule && (req[1] || req[2])
        |=> (accmodule == 2'b10 && !done[1] || accmodule == 2'b11 && !done[2]) && req[0]
        |=> accmodule == 2'b01 && !done[0]
        |=> accmodule == 2'b01
};

assert -name a_M1_no_it_3_cycle_access {
    @(posedge clk) disable iff(reset)
        !accmodule && (req[M2] || req[M3])
        |=> (accmodule == 2'b10 && !done[1] || accmodule == 2'b11 && !done[2]) && req[0]
        |=> accmodule == 2'b01 && !done[0]
        |=> accmodule == 2'b01 && !req[0]
        |=> accmodule != 2'b01
};

assert -name a_module_granted_M1_access_before_on_posedge {
    @(posedge clk) disable iff(reset)
        accmodule != 2'b01 && req[0]
        |-> ##0 accmodule != 2'b01
};
assert -name a_module_granted_M2_access_before_on_posedge {
    @(posedge clk) disable iff(reset)
        accmodule != 2'b10 && req[1]
        |-> ##0 accmodule != 2'b10
};
assert -name a_module_granted_M3_access_before_on_posedge {
    @(posedge clk) disable iff(reset)
        accmodule != 2'b11 && req[2]
        |-> ##0 accmodule != 2'b11
};

assert -name a_module_granted_M1_access_on_posedge {
    @(posedge clk) disable iff(reset)
        req == 3'b001
        |=> accmodule == 2'b01
};
assert -name a_module_granted_M2_access_on_posedge {
    @(posedge clk) disable iff(reset)
        !accmodule && req == 3'b010
        |=> accmodule == 2'b10
};
assert -name a_module_granted_M3_access_on_posedge {
    @(posedge clk) disable iff(reset)
        !accmodule && req == 3'b100
        |=> accmodule == 2'b11
};

assert -name a_M2_2_cycle_access {
    @(posedge clk) disable iff(reset)
        !req && !accmodule
        |=> req[1]
        |=> accmodule == 2'b10 && !done[1] && !req[0]
        |=> accmodule == 2'b10 && !req[1]
        |=> accmodule != 2'b10
};
assert -name a_M3_2_cycle_access {
    @(posedge clk) disable iff(reset)
        !req && !accmodule
        |=> req[2]
        |=> accmodule == 2'b11 && !done[2] && !req[0]
        |=> accmodule == 2'b11 && !req[2]
        |=> accmodule != 2'b11
};

assert -name a_M1_smooth_M2 {
    @(posedge clk) disable iff(reset)
        req[0]
        |=> accmodule == 2'b01 && !done[0]
        |=> accmodule == 2'b01 && done[0] && !req[2] && req[1]
        |=> accmodule == 2'b10
};
assert -name a_M1_smooth_M3 {
    @(posedge clk) disable iff(reset)
        req[0]
        |=> accmodule == 2'b01 && !done[0]
        |=> accmodule == 2'b01 && done[0] && !req[1] && req[2]
        |=> accmodule == 2'b11
};
assert -name a_M2_smooth_M1 {
    @(posedge clk) disable iff(reset)
        req[1]
        |=> accmodule == 2'b10 && !done[1]
        |=> accmodule == 2'b10 && done[1] && !req[2] && req[0]
        |=> accmodule == 2'b01
};
assert -name a_M2_smooth_M3 {
    @(posedge clk) disable iff(reset)
        req[1]
        |=> accmodule == 2'b10 && !done[1]
        |=> accmodule == 2'b10 && done[1] && !req[0] && req[2]
        |=> accmodule == 2'b11
};
assert -name a_M3_smooth_M1 {
    @(posedge clk) disable iff(reset)
        req[2]
        |=> accmodule == 2'b11 && !done[2]
        |=> accmodule == 2'b11 && done[2] && !req[1] && req[0]
        |=> accmodule == 2'b01
};
assert -name a_M3_smooth_M2 {
    @(posedge clk) disable iff(reset)
        req[2]
        |=> accmodule == 2'b11 && !done[2]
        |=> accmodule == 2'b11 && done[2] && !req[0] && req[1]
        |=> accmodule == 2'b10
};

assume -name a_req_M1 -env {
    @(posedge clk) disable iff(reset)
        req[0]
        |=> !req[0]
}
assume -name a_req_M2 -env {
    @(posedge clk) disable iff(reset)
        req[1]
        |=> !req[1]
}
assume -name a_req_M3 -env {
    @(posedge clk) disable iff(reset)
        req[2]
        |=> !req[2]
}

assume -name a_done_M1 -env {
    @(posedge clk) disable iff(reset)
        done[0]
        |=> !done[0]
}
assume -name a_done_M2 -env {
    @(posedge clk) disable iff(reset)
        done[1]
        |=> !done[1]
}
assume -name a_done_M3 -env {
    @(posedge clk) disable iff(reset)
        done[2]
        |=> !done[2]
}

cover -name c_done_can_be_0 {
    @(posedge clk) done == '0
}
cover -name c_done_can_be_1 {
    @(posedge clk) done == 3'b001
}
cover -name c_done_can_be_2 {
    @(posedge clk) done == 3'b010
}
cover -name c_done_can_be_4 {
    @(posedge clk) done == 3'b100
}

cover -name c_req_can_be_0 {
    @(posedge clk) req == 3'b000
}
cover -name c_req_can_be_1 {
    @(posedge clk) req == 3'b001
}
cover -name c_req_can_be_2 {
    @(posedge clk) req == 3'b010
}
cover -name c_req_can_be_3 {
    @(posedge clk) req == 3'b011
}
cover -name c_req_can_be_4 {
    @(posedge clk) req == 3'b100
}
cover -name c_req_can_be_5 {
    @(posedge clk) req == 3'b101
}
cover -name c_req_can_be_6 {
    @(posedge clk) req == 3'b110
}
cover -name c_req_can_be_7 {
    @(posedge clk) req == 3'b111
}

assume -name a_no_req_and_done_M1 -env {
    @(posedge clk) disable iff(reset)
        !done[0] || !req[0]
}
assume -name a_no_req_and_done_M2 -env {
    @(posedge clk) disable iff(reset)
        !done[1] || !req[1]
}
assume -name a_no_req_and_done_M3 -env {
    @(posedge clk) disable iff(reset)
        !done[2] || !req[2]
}