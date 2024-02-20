//Spec. 5
covergroup cg_M1_interrupts @(posedge tb.clk);
    cp_mstate: coverpoint tb.mstate {
        bins M1_it_M2_2p = (5'b00100 => 5'b01000);
        bins M1_it_M2_3p = (5'b00101 => 5'b01001);
        bins M1_it_M3_2p = (5'b00110 => 5'b01000);
        bins M1_it_M3_3p = (5'b00111 => 5'b01001);
    }
    cp_accmodule: coverpoint tb.accmodule {
        bins M2_to_M1 = (2'b10 => 2'b01);
        bins M3_to_M1 = (2'b11 => 2'b01);
    }
endgroup

//Spec. 6
covergroup cg_all_modules_requestable @(posedge tb.clk);
    cp_req: coverpoint tb.req {
        wildcard bins req_M1 = {3'b??1};
        wildcard bins req_M2 = {3'b?10};
        wildcard bins req_M3 = {3'b1?0};
    }
    cp_accmodule: coverpoint tb.accmodule {
        wildcard bins to_M1 = (2'b?? => 2'b01);
        wildcard bins to_M2 = (2'b?? => 2'b10);
        wildcard bins to_M3 = (2'b?? => 2'b11);
    }
    cp_both: cross cp_req, cp_accmodule {
        option.cross_auto_bin_max = 0;

        bins M1_req_acted_on = binsof(cp_req.req_M1) && binsof(cp_accmodule.to_M1);
        bins M2_req_acted_on = binsof(cp_req.req_M2) && binsof(cp_accmodule.to_M2);
        bins M3_req_acted_on = binsof(cp_req.req_M3) && binsof(cp_accmodule.to_M3);
    }
endgroup

//Spec. 8
covergroup cg_req_M1_acted_on_edge @(posedge tb.req[0], posedge tb.accmodule[0] or negedge tb.accmodule[1]);
    cp_clk: coverpoint tb.clk {
        bins pos_clk = {1};
        bins neg_clk = {0};
    }
    cp_accmodule_to_M1: coverpoint tb.accmodule {
        bins idle_to_M1 = (2'b00 => 2'b01);
        bins M2_to_M1 = (2'b10 => 2'b01);
        bins M3_to_M1 = (2'b11 => 2'b01);
    }
    cp_immidiate_chage: cross cp_clk, cp_accmodule_to_M1 {
        bins proper_change_to_M1 = binsof(cp_clk.pos_clk) && binsof(cp_accmodule_to_M1);
        illegal_bins improper_change_to_M1 = binsof(cp_clk.neg_clk) && binsof(cp_accmodule_to_M1);
    }
endgroup
covergroup cg_req_M2_acted_on_edge @(posedge tb.req[1], posedge tb.accmodule[1] or negedge tb.accmodule[0]);
    cp_clk: coverpoint tb.clk {
        bins pos_clk = {1};
        bins neg_clk = {0};
    }
    cp_accmodule_to_M2: coverpoint tb.accmodule {
        bins idle_to_M2 = (2'b00 => 2'b10);
        bins M1_to_M2 = (2'b01 => 2'b10);
        bins M3_to_M2 = (2'b11 => 2'b10);
    }
    cp_immidiate_change: cross cp_clk, cp_accmodule_to_M2 {
        bins proper_change_to_M2 = binsof(cp_clk.pos_clk) && binsof(cp_accmodule_to_M2);
        illegal_bins improper_change_to_M2 = binsof(cp_clk.neg_clk) && binsof(cp_accmodule_to_M2);
    }
endgroup
covergroup cg_req_M3_acted_on_edge @(posedge tb.req[2], posedge tb.accmodule[1] or negedge tb.accmodule[0]);
    cp_clk: coverpoint tb.clk {
        bins pos_clk = {1};
        bins neg_clk = {0};
    }
    cp_accmodule_to_M3: coverpoint tb.accmodule {
        bins idle_to_M3 = (2'b00 => 2'b11);
        bins M1_to_M3 = (2'b01 => 2'b11);
        bins M2_to_M3 = (2'b10 => 2'b11);
    }
    cp_immidiate_change: cross cp_clk, cp_accmodule_to_M3 {
        bins proper_change_to_M3 = binsof(cp_clk.pos_clk) && binsof(cp_accmodule_to_M3);
        illegal_bins improper_change_to_M3 = binsof(cp_clk.neg_clk) && binsof(cp_accmodule_to_M3);
    }
endgroup

//Spec. 10
covergroup cg_M2_and_M3_no_it @(posedge tb.clk);
    cp_mstate: coverpoint tb.mstate {
        wildcard bins state_any = (5'b????? => 5'b?????);
        wildcard ignore_bins M1_sd = (5'b0110? => 5'b?????);
        wildcard ignore_bins M2_in_sec_cycle = (5'b0111? => 5'b?????);
        wildcard ignore_bins M3_in_sec_cycle = (5'b1000? => 5'b?????);
    }
    cp_done: coverpoint tb.done {
        wildcard bins done_any = (3'b??? => 3'b???);
        wildcard ignore_bins done_M1 = (3'b??1 => 3'b???);
        wildcard ignore_bins done_M2 = (3'b?1? => 3'b???);
        wildcard ignore_bins done_M3 = (3'b1?? => 3'b???);
    }
    cp_accmodule: coverpoint tb.accmodule {
        bins M2_to_M3 = (2'b10 => 2'b11);
        bins M3_to_M2 = (2'b11 => 2'b10);
        bins M1_to_M2 = (2'b01 => 2'b10);
        bins M1_to_M3 = (2'b01 => 2'b11);
    }
    cp_both: cross cp_mstate, cp_done, cp_accmodule {
        option.cross_auto_bin_max = 0;
        
        illegal_bins improper_M2_to_M3 = binsof(cp_accmodule.M2_to_M3) && binsof(cp_mstate) && binsof(cp_done);
        illegal_bins improper_M3_to_M2 = binsof(cp_accmodule.M3_to_M2) && binsof(cp_mstate) && binsof(cp_done);
        illegal_bins improper_M1_to_M2 = binsof(cp_accmodule.M1_to_M2) && binsof(cp_mstate) && binsof(cp_done);
        illegal_bins improper_M1_to_M3 = binsof(cp_accmodule.M1_to_M3) && binsof(cp_mstate) && binsof(cp_done);
    }
endgroup

//Spec. 12
covergroup cg_M2_M3_tie_breaker @(posedge tb.clk);
    cp_req: coverpoint tb.req {
        wildcard bins tie = (3'b110 => 3'b???);
    }
    cp_mstate: coverpoint tb.mstate {
        wildcard bins got_to_M3in_2p = (5'b????? => 5'b00110);
        wildcard bins got_to_M2in_3p = (5'b????? => 5'b00101);
    }
    cp_both: cross cp_req, cp_mstate;
endgroup

//Spec. 14
covergroup cg_smooth_trasitions @(posedge tb.clk);
    cp_done: coverpoint tb.done {
        wildcard bins done_M1 = (3'b001 => 3'b???);
        wildcard bins done_M2 = (3'b?10 => 3'b???);
        wildcard bins done_M3 = (3'b1?0 => 3'b???);
    }
    cp_req: coverpoint tb.req {
        wildcard bins req_M1 = (3'b??1 => 3'b???);
        wildcard bins req_M2 = (3'b?10 => 3'b???);
        wildcard bins req_M3 = (3'b1?0 => 3'b???);
    }
    cp_transitions: coverpoint tb.accmodule {
        bins m1_to_m2 = (2'b01 => 2'b10);
        bins m1_to_m3 = (2'b01 => 2'b11);
        bins m2_to_m1 = (2'b10 => 2'b01);
        bins m2_to_m3 = (2'b10 => 2'b11);
        bins m3_to_m1 = (2'b11 => 2'b01);
        bins m3_to_m2 = (2'b11 => 2'b10);
    }
    cp_both: cross cp_done, cp_req, cp_transitions {
        option.cross_auto_bin_max = 0;
        bins M1_smooth_to_M2 = binsof(cp_done.done_M1) && binsof(cp_req.req_M2) && binsof(cp_transitions.m1_to_m2);
        bins M1_smooth_to_M3 = binsof(cp_done.done_M1) && binsof(cp_req.req_M3) && binsof(cp_transitions.m1_to_m3);
        bins M2_smooth_to_M1 = binsof(cp_done.done_M2) && binsof(cp_req.req_M1) && binsof(cp_transitions.m2_to_m1);
        bins M2_smooth_to_M3 = binsof(cp_done.done_M2) && binsof(cp_req.req_M3) && binsof(cp_transitions.m2_to_m3);
        bins M3_smooth_to_M1 = binsof(cp_done.done_M3) && binsof(cp_req.req_M1) && binsof(cp_transitions.m3_to_m1);
        bins M3_smooth_to_M2 = binsof(cp_done.done_M3) && binsof(cp_req.req_M2) && binsof(cp_transitions.m3_to_m2);
    }
endgroup

//Spec. 15
covergroup cg_modules_finish_access @(posedge tb.clk);
    cp_done: coverpoint tb.done {
        wildcard bins done_M1 = (3'b001 => 3'b???);
        wildcard bins done_M2 = (3'b010 => 3'b???);
        wildcard bins done_M3 = (3'b100 => 3'b???);
    }
    cp_no_req: coverpoint tb.req {
        wildcard bins no_req = (3'b000 => 3'b???);
    }
    cp_accmodule: coverpoint tb.accmodule {
        bins M1_cont = (2'b01 => 2'b01);
        bins M2_cont = (2'b10 => 2'b10);
        bins M3_cont = (2'b11 => 2'b11);
    }
    cp_done_siged: cross cp_no_req, cp_done, cp_accmodule {
        option.cross_auto_bin_max = 0;
        
        illegal_bins improper_done_M1 = binsof(cp_done.done_M1) && binsof(cp_no_req) && binsof(cp_accmodule.M1_cont);
        illegal_bins improper_done_M2 = binsof(cp_done.done_M2) && binsof(cp_no_req) && binsof(cp_accmodule.M2_cont);
        illegal_bins improper_done_M3 = binsof(cp_done.done_M3) && binsof(cp_no_req) && binsof(cp_accmodule.M3_cont);
    }
endgroup

//Spec. 17
covergroup cg_all_modules_doneable @(posedge tb.clk);
    cp_done: coverpoint tb.done {
        wildcard bins done_M1 = {3'b??1};
        wildcard bins done_M2 = {3'b?1?};
        wildcard bins done_M3 = {3'b1??};
    }
    cp_accmodule: coverpoint tb.accmodule {
        bins M1_to_idle = (2'b01 => 2'b00);
        bins M2_to_idle = (2'b10 => 2'b00);
        bins M3_to_idle = (2'b11 => 2'b00);
    }
    cp_both: cross cp_done, cp_accmodule {
        option.cross_auto_bin_max = 0;
        bins M1_done_acted_on = binsof(cp_done.done_M1) && binsof(cp_accmodule.M1_to_idle);
        bins M2_done_acted_on = binsof(cp_done.done_M2) && binsof(cp_accmodule.M2_to_idle);
        bins M3_done_acted_on = binsof(cp_done.done_M3) && binsof(cp_accmodule.M3_to_idle);
    }
endgroup

//Spec. 18
covergroup cg_cut_off_m2m3_after_2_cycle @(posedge tb.clk);
    cp_req: coverpoint tb.req {
        wildcard bins no_req_M2 = (3'b?0? => 3'b?0? => 3'b?0?);
        wildcard bins no_req_M3 = (3'b0?? => 3'b0?? => 3'b0??);
    }
    cp_done: coverpoint tb.done {
        wildcard bins no_done_M2 = (3'b?0? => 3'b?0? => 3'b?0?);
        wildcard bins no_done_M3 = (3'b0?? => 3'b0?? => 3'b0??);
    }
    cp_transitions: coverpoint tb.accmodule {
        bins M2_cutoff = (2'b10 => 2'b10 => 2'b00);
        bins M3_cutoff = (2'b11 => 2'b11 => 2'b00);
        bins M2_elapsed = (2'b10 => 2'b10 => 2'b10);
        bins M3_elapsed = (2'b11 => 2'b11 => 2'b11);
    }
    cp_both: cross cp_req, cp_done, cp_transitions {
        option.cross_auto_bin_max = 0;
        bins cutoff_M2 = binsof(cp_req.no_req_M2) && binsof(cp_done.no_done_M2) && binsof(cp_transitions.M2_cutoff);
        bins cutoff_M3 = binsof(cp_req.no_req_M3) && binsof(cp_done.no_done_M3) && binsof(cp_transitions.M3_cutoff);
        illegal_bins elapsed_M2 = binsof(cp_req.no_req_M2) && binsof(cp_done.no_done_M2) && binsof(cp_transitions.M2_elapsed);
        illegal_bins elapsed_M3 = binsof(cp_req.no_req_M3) && binsof(cp_done.no_done_M3) && binsof(cp_transitions.M3_elapsed);
    }
endgroup

//Spec. 19
covergroup cg_invalid_access @(posedge tb.clk);
    cp_no_req: coverpoint tb.req {
        wildcard bins req_any = (3'b??? => 3'b???);
        wildcard ignore_bins no_req_M2 = (3'b?10 => 3'b???);
        wildcard ignore_bins no_req_M3 = (3'b1?0 => 3'b???);
    }
    cp_accmodule: coverpoint tb.accmodule {
        bins to_M2 = (2'b01 => 2'b10);
        bins to_M3 = (2'b01 => 2'b11);
    }
    cp_both: cross cp_no_req, cp_accmodule {
        option.cross_auto_bin_max = 0;
        
        illegal_bins improper_change_to_M2 = binsof(cp_no_req) && binsof(cp_accmodule.to_M2);
        illegal_bins improper_change_to_M3 = binsof(cp_no_req) && binsof(cp_accmodule.to_M3);
    }
endgroup

//Spec. 21-4
covergroup cg_nb_interrupts @(posedge tb.clk);
    cp_transitions: coverpoint tb.iDUT.accmodule {
        bins m1_in_m2 = (2'b10 => 2'b01);
        bins m1_in_m3 = (2'b11 => 2'b01);
    }
    cp_nb_interrupts: coverpoint tb.iDUT.nb_interrupts {
        bins interruptions = {[1:2**32]};
    }
    cp_both: cross cp_transitions, cp_nb_interrupts;
endgroup