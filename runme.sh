#!/bin/bash

sh clean.sh

#Create the work library.
vlib work

#Compile the sv file.
#Change controller_wrong.sv to controller.sv here and in propcheck.do (fpv tool do file) to see a bug free run.
vlog +define+ASSERTIONS controller.sv tb.sv covergroups.sv +fcover -cover sbcef +cover=f -O0

#Simulate states.
vsim tb -c -coverage -do cover.do +ALLSPECS
echo ""
echo ""
echo "Finished simulating."

if [[ $(hostname) == *"babylon"* ]]; then
    echo "As you are on the babylon server jaspergold is being launched."
    echo "Within jasper gold, use the command 'include run_controller.tcl' to prove properties."
    echo ""

    jg #include run_controller.tcl
elif [[ $(hostname) == *"flip"* ]]; then
    #sh fpv.sh

    echo ""
    echo ""
    echo "You were not on the babylon server."
    echo ""
fi