#!/bin/bash

sh clean.sh

#Create the work library.
#vlib work

#Compile the sv file.
#vlog controller_wrong.sv tb.sv covergroups.sv +fcover -cover sbcef +cover=f -O0

#Simulate states.
#vsim tb -c -coverage -do cover.do +ALLSPECS

sh fpv.sh