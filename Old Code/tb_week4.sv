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

class Random_Class;
  rand bit [2:0] req;
  rand bit [2:0] done;
  rand bit [2:0] reset;

  constraint is_one_hot {done[0] ^ done[1] ^ done[2] && done != 3'b111;}
endclass

Random_Class randomizer = new;

function need_to_rerandomize(logic [2:0] req, logic [2:0] done, logic [2:0] req_curr, logic [2:0] done_curr);
  req_was_M1 = req[0] == req_curr[0] && req[0];
  req_was_M2 = req[1] == req_curr[1] && req[1];
  req_was_M3 = req[2] == req_curr[2] && req[2];
  req_needs_to_change = req_was_M1 || req_was_M2 || req_was_M3;

  done_all_zero = done_curr != '0;
  done_has_not_changed = done == done_curr;
  done_needs_to_change = done_all_zero && done_has_not_changed;

  return req_needs_to_change || done_needs_to_change;
endfunction

cg_M1_interrupts cgi_M1_interrupts;
cg_all_modules_requestable cgi_all_modules_requestable;
cg_req_for_cycle cgi_req_for_cycle;
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
  if ($test$plusargs("SPEC7")) begin cgi_req_for_cycle = new; end
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

  clk = 0;

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

  reset_inputs();

  access_M1in_2p();
  req = 1 << M1;
  #PERIOD reset_inputs();
  #(3*PERIOD);
  assess_state("Long M1 requested while in M1", 2'b01, accmodule);

  access_M1id_2p();
  #(3*PERIOD);
  assess_state("long M1 accessed from idle", 2'b01, accmodule);

  access_M1it_2p();
  #(3*PERIOD);
  assess_state("long M1 interrupts M2", 2'b00, accmodule);

  access_M3in_2p();
  req = 1 << M1;
  #PERIOD reset_inputs();
  #(3*PERIOD);
  assess_state("long M1 interrupts M3", 2'b00, accmodule);

  # 20 $dumpflush;
  $stop;
end

initial begin
  $dumpfile("test.vcd");
  $dumpvars(1, tb);
end

task assess_state(string name, logic [1:0] intended_state, logic [1:0] accmodule);
  assert(accmodule == intended_state)
  else $error("%s. %b instead of %b.", name, accmodule, intended_state);
endtask

task reset_inputs();
  req = '0;
  done = '0;
endtask

task request_reset_controller();
  reset = 1;
  reset_inputs();
  #PERIOD reset = 0;
endtask

//Idle.
task access_IDLE_2p();
  request_reset_controller();
  #PERIOD assess_state("accss to idle 2p", 2'b00, accmodule);
endtask

task access_IDLE_3p();
  access_M2in_3p();
  done = 1 << M2;
  req = '0;
  #PERIOD assess_state("accss to idle 3p", 2'b00, accmodule);
  reset_inputs();
endtask


//M1 first cycle.
task access_M1in_2p();
  request_reset_controller();
  req = 1 << M1;
  #PERIOD assess_state("accss to M1 2p", 2'b01, accmodule);
  reset_inputs();
endtask

task access_M1in_3p();
  access_M2in_3p();
  done = 1 << M2;
  req = 1 << M1;
  #PERIOD assess_state("accss to M1 3p", 2'b01, accmodule);
  reset_inputs();
endtask


//M2 first cycle.
task access_M2in_2p();
  request_reset_controller();
  req = 1 << M2;
  #PERIOD assess_state("accss to M2 2p", 2'b10, accmodule);
  reset_inputs();
endtask

task access_M2in_3p();
  request_reset_controller();
  req = 1 << M3 | 1 << M2;
  #PERIOD assess_state("accss to M2 3p", 2'b10, accmodule);
  reset_inputs();
endtask


//M3 first cycle.
task access_M3in_2p();
  request_reset_controller();
  req = 1 << M3;
  #PERIOD assess_state("accss to M3 2p", 2'b11, accmodule);
  reset_inputs();
endtask

task access_M3in_3p();
  access_M2in_3p();
  done = 1 << M2;
  req = 1 << M3;
  #PERIOD assess_state("accss to M3 3p", 2'b11, accmodule);
  reset_inputs();
endtask


//Interupts.
task access_M1it_2p();
  access_M2in_2p();
  req = 1 << M1;
  #PERIOD assess_state("accss to M1 interrupting M2 2p", 2'b01, accmodule);
  reset_inputs();
endtask

task access_M1it_3p();
  access_M2in_3p();
  req = 1 << M1;
  #PERIOD assess_state("accss to M1 interrupting M2 3p", 2'b01, accmodule);
  reset_inputs();
endtask


//M1 indefinite.
task access_M1id_2p();
  access_M1in_2p();
  #PERIOD assess_state("accss to M1 indefinite access 2p", 2'b01, accmodule);
  reset_inputs();
endtask

task access_M1id_3p();
  access_M1in_3p();
  #PERIOD assess_state("accss to M1 indefinite access 3p", 2'b01, accmodule);
  reset_inputs();
endtask


//M1 2nd cycles.
task access_M1sd_2p();
  access_M1it_2p();
  #PERIOD assess_state("accss to M1 interrupting M2, second sycle 2p", 2'b01, accmodule);
  reset_inputs();
endtask

task access_M1sd_3p();
  access_M1it_3p();
  #PERIOD assess_state("accss to M1 interrupting M2, second cycle 3p", 2'b01, accmodule);
  reset_inputs();
endtask


//M2 2nd cycles.
task access_M2sd_2p();
  access_M2in_2p();
  #PERIOD assess_state("accss to M2 second cycle 2p", 2'b10, accmodule);
  reset_inputs();
endtask

task access_M2sd_3p();
  access_M2in_3p();
  #PERIOD assess_state("accss to M2 second cycle 3p", 2'b10, accmodule);
  reset_inputs();
endtask


//M3 2nd cycles.
task access_M3sd_2p();
  access_M3in_2p();
  #PERIOD assess_state("accss to M3 second cycle 2p", 2'b11, accmodule);
  reset_inputs();
endtask

task access_M3sd_3p();
  access_M3in_3p();
  #PERIOD assess_state("accss to M3 second cycle 3p", 2'b11, accmodule);
  reset_inputs();
endtask

task all_IDLE_np(int n);
  for (int i= 0; i < 8; i++) begin
    if (n == 2) access_IDLE_2p();
    else access_IDLE_3p();
    req = i;
    #PERIOD;
  end
endtask

task all_M1in_np(int n);
  for (int i= 0; i < 2; i++) begin
    if (n == 2) access_M1in_2p();
    else access_M1in_3p();
    #PERIOD done = i;
    #PERIOD;
  end
endtask

task all_M2in_np(int n);
  for (int i = 0; i < 8; i++) begin
    if (n == 2) access_M2in_2p();
    else access_M2in_3p();
    done = 1 << M2;
    req = i;
    #PERIOD;
  end

  if (n == 2) access_M2in_2p();
  else access_M2in_3p();
  req = 1 << M1;
  #PERIOD;
endtask

task all_M3in_np(int n);
  for (int i = 0; i < 8; i++) begin
    if (n == 2) access_M3in_2p();
    else access_M3in_3p();
    done = 1 << M3;
    req = i;
    #PERIOD;
  end

  if (n == 2) access_M3in_2p();
  else access_M3in_3p();
  req = 1 << M1;
  #PERIOD;
endtask

task all_M1it_np(int n);
  for (int i = 0; i < 8; i++) begin
    if (n == 2) access_M1it_2p();
    else access_M1it_3p();
    done = 1 << M1;
    req = i;
    #PERIOD;
  end
endtask

task all_M1id_np(int n);
  for (int i = 0; i < 8; i++) begin
    if (n == 2) access_M1id_2p();
    else access_M1id_3p();
    done = 1 << M1;
    req = i;
    #PERIOD;
  end
endtask

task all_M1sd_np(int n);
  for (int i = 0; i < 8; i++) begin
    if (n == 2) access_M1sd_2p();
    else access_M1sd_3p();
    req = i;
    #PERIOD;
  end
endtask

task all_M2sd_np(int n);
  for (int i = 0; i < 8; i++) begin
    if (n == 2) access_M2sd_2p();
    else access_M2sd_3p();
    req = i;
    #PERIOD;
  end
endtask

task all_M3sd_np(int n);
  for (int i = 0; i < 8; i++) begin
    if (n == 2) access_M3sd_2p();
    else access_M3sd_3p();
    req = i;
    #PERIOD;
  end
endtask
endmodule