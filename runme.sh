#!/bin/bash

sh clean.sh

#Create the work library.
if [ ! -d "work" ]; then
	vlib work
fi

#Compile the sv file.
vlog controller_wrong.sv tb.sv covergroups.sv +fcover -cover sbcef +cover=f -O0

#Simulate states.
vsim tb -c -coverage -do cover.do +SPEC4 +SPEC5 +SPEC6 +SPEC7 +SPEC8_M1 +SPEC8_M2 +SPEC8_M3 +SPEC10 +SPEC12 +SPEC14 +SPEC15 +SPEC17 +SPEC18 +SPEC19 +SPEC21