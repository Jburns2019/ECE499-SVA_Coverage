# Compile Section

vlib work
#vlog -sv +define+FORMAL controller.sv
vlog -sv +define+FORMAL controller_wrong.sv
vlog -sv -mfcu -cuname sva_bind +define+FORMAL properties.sv

# PropCheck Section
onerror {exit 1}

###### add directives
# fix one of the  nets to a value
#netlist constant clk_bypass 1'b1
netlist reset reset -active_high -async
netlist clock clk -period 20

###### Run PropCheck
formal compile -d controller -cuname sva_bind
formal verify -timeout 60s

exit 0