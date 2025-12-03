# Create the work library (if it doesn't exist)
vlib work
vmap work work

# Compile all VHDL files in the folder
vcom *.vhdl

# Run simulation in command-line mode
vsim -c tb_washer -do "add wave *; run -all; quit"
