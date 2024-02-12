//`timescale 1ns/1ns
`include "covergroups.sv"

module tb();
  // M3,M2,M1
  parameter M1 = 0;
  parameter M2 = 1;
  parameter M3 = 2;
  
  logic [2:0] req; 
  logic [2:0] done;
  logic clk, reset;  // Input signals to the DUT.

  logic [4:0] mstate;
  logic [1:0] accmodule;
  integer nb_interrupts;

  controller iDUT(.*);

  parameter PERIOD = 20;
  always
    #(PERIOD/2) clk = ~clk;

  logic req_was_M1, req_was_M2, req_was_M3, req_needs_to_change;
  logic done_all_zero, done_has_not_changed, done_needs_to_change;
  logic req_and_dones;

class Random_Class;
  rand bit [2:0] req;
  rand bit [2:0] done;
  rand bit [2:0] reset;

  constraint is_one_hot {done[0] ^ done[1] ^ done[2] && done != 3'b111;}
  constraint not_both {!(req[M1] && done[M1] || req[M2] && done[M2] || req[M3] && done[M3]);}
endclass

Random_Class randomizer = new;

function need_to_rerandomize(logic [2:0] req, logic [2:0] done, logic [2:0] req_curr, logic [2:0] done_curr);
  req_was_M1 = req[M1] == req_curr[M1] && req[M1];
  req_was_M2 = req[1] == req_curr[1] && req[1];
  req_was_M3 = req[2] == req_curr[2] && req[2];
  req_needs_to_change = req_was_M1 || req_was_M2 || req_was_M3;

  done_all_zero = done_curr != '0;
  done_has_not_changed = done == done_curr;
  done_needs_to_change = done_all_zero && done_has_not_changed;

  req_and_dones = req[M1] && done[M1] || req[M2] && done[M2] || req[M3] && done[M3];

  return req_needs_to_change || done_needs_to_change || req_and_dones;
endfunction

cg_M1_interrupts cgi_M1_interrupts;
cg_all_modules_requestable cgi_all_modules_requestable;
cg_req_M1_acted_on_edge cgi_req_M1_acted_on_edge;
cg_req_M2_acted_on_edge cgi_req_M2_acted_on_edge;
cg_req_M3_acted_on_edge cgi_req_M3_acted_on_edge;
cg_M2_and_M3_no_it cgi_M2_and_M3_no_it;
cg_M2_M3_tie_breaker cgi_M2_M3_tie_breaker;
cg_smooth_trasitions cgi_smooth_trasitions;
cg_modules_finish_access cgi_modules_finish_access;
cg_invalid_access cgi_invalid_access;
cg_all_modules_doneable cgi_all_modules_doneable;
cg_cut_off_m2m3_after_2_cycle cgi_cut_off_m2m3_after_2_cycle;
cg_nb_interrupts cgi_nb_interrupts;

initial begin
  if ($test$plusargs("SPEC5")) begin cgi_M1_interrupts = new; end
  if ($test$plusargs("SPEC6")) begin cgi_all_modules_requestable = new; end
  if ($test$plusargs("SPEC8_M1")) begin cgi_req_M1_acted_on_edge = new; end
  if ($test$plusargs("SPEC8_M2")) begin cgi_req_M2_acted_on_edge = new; end
  if ($test$plusargs("SPEC8_M3")) begin cgi_req_M3_acted_on_edge = new; end
  if ($test$plusargs("SPEC10")) begin cgi_M2_and_M3_no_it = new; end
  if ($test$plusargs("SPEC12")) begin cgi_M2_M3_tie_breaker = new; end
  if ($test$plusargs("SPEC14")) begin cgi_smooth_trasitions = new; end
  if ($test$plusargs("SPEC15")) begin cgi_modules_finish_access = new; end
  if ($test$plusargs("SPEC17")) begin cgi_invalid_access = new; end
  if ($test$plusargs("SPEC18")) begin cgi_all_modules_doneable = new; end
  if ($test$plusargs("SPEC19")) begin cgi_cut_off_m2m3_after_2_cycle = new; end
  if ($test$plusargs("SPEC21")) begin cgi_nb_interrupts = new; end
  if ($test$plusargs("ALLSPECS")) begin
    cgi_M1_interrupts = new;
    cgi_all_modules_requestable = new;
    cgi_req_M1_acted_on_edge = new;
    cgi_req_M2_acted_on_edge = new;
    cgi_req_M3_acted_on_edge = new;
    cgi_M2_and_M3_no_it = new;
    cgi_M2_M3_tie_breaker = new;
    cgi_smooth_trasitions = new;
    cgi_modules_finish_access = new;
    cgi_invalid_access = new;
    cgi_all_modules_doneable = new;
    cgi_cut_off_m2m3_after_2_cycle = new;
    cgi_nb_interrupts = new;
  end

  clk = 0;

  randomizer.srandom(1234);
  repeat(50000) begin
    randomizer.randomize();
    while (need_to_rerandomize(req, done, randomizer.req, randomizer.done)) begin
      randomizer.randomize();
    end

    req = randomizer.req;
    done = randomizer.done;
    reset = randomizer.reset == '0;
    #PERIOD;
  end

  req = '0;
  done = '0;

  #PERIOD $dumpflush;
  $stop;
end

initial begin
  $dumpfile("test.vcd");
  $dumpvars(1, tb);
end
endmodule