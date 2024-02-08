coverage exclude -srcfile tb.sv

run -all
coverage save a.ucdb
coverage report -details -html
coverage report -details -output cov.rpt
exit