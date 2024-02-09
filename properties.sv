`ifdef FORMAL

property p_reset;
    @(posedge reset) $fell(accmodule);
endproperty

`endif