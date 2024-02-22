#!/bin/bash

sh clean.sh

#Create the work library.
vlib work

#Compile the sv file.
#Change controller_wrong.sv to controller.sv here and in propcheck.do (fpv tool do file) to see a bug free run.
vlog +define+ASSERTIONS controller.sv tb.sv covergroups.sv +fcover -cover sbcef +cover=f -O0

#Simulate states.
vsim tb -c -coverage -do cover.do +ALLSPECS