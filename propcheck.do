# Compile Section

vlib work
vlog -sv +define+FORMAL controller.sv
vlog -sv -mfcu -cuname sva_bind +define+FORMAL properties.sv

# PropCheck Section
onerror {exit 1}

###### add directives
netlist reset reset -active_high -async
netlist clock clk -period 20

###### Run PropCheck
formal compile -d controller -cuname sva_bind
formal verify -timeout 120s

exit 0