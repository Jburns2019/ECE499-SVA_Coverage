# Compile Section

vlib work
#Change controller_wrong.sv to controller.sv here and in runme.sh line 10 to see a bug free run.
vlog -sv +define+FORMAL +define+ASSERTIONS controller.sv
vlog -sv -mfcu -cuname sva_bind +define+ASSERTIONS properties.sv

# PropCheck Section
onerror {exit 1}

###### add directives
netlist reset reset -active_high -async
netlist clock clk -period 20

###### Run PropCheck
formal compile -d controller -cuname sva_bind
formal verify -auto_constraint_off -timeout 120s

exit 0