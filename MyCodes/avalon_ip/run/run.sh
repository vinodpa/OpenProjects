vsim -c tb_axi_lite
run -all
vcd2wlf mydump.vcd mydump.wlf
quit