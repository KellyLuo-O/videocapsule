quit -sim

vlib work

vcom ../colorimetrie.vhd
vcom colorimetrie_tb.vhd

vsim -c work.colorimetrie_tb

# INPUTS
add wave -divider Inputs:
add wave -color yellow uut/clk
add wave -color yellow uut/reset
add wave -color yellow uut/cs
add wave -color yellow uut/wr
add wave -color yellow uut/rd
add wave -color yellow uut/clk_pixel
add wave -color yellow uut/synchro_trame
add wave -color yellow uut/address
add wave -color yellow uut/R
add wave -color yellow uut/G
add wave -color yellow uut/B
add wave -color yellow uut/writedata

# OUTPUTS
add wave -divider Outputs:
add wave uut/readdata

run -all