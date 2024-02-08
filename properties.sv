`ifdef FORMAL

property p_reset;
    @(posedge reset) accmodule == 0;
endproperty

`endif