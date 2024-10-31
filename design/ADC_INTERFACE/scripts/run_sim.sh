#!/bin/bash

# Paths to source and testbench directories
RTL_PATH="../rtl"
TB_PATH="../testbench"

# VHDL file and testbench file names without extensions
ENTITY_NAME="ADC_INTERFACE_LTC2325CUKG"          # Update with your VHDL file name in ../rtl/
TESTBENCH_NAME="tb_${ENTITY_NAME}"  # Update if testbench file is named differently

# Compile the VHDL file
echo "Compiling $ENTITY_NAME.vhd..."
ghdl -a "$RTL_PATH/$ENTITY_NAME.vhd"
if [ $? -ne 0 ]; then
    echo "Error compiling $ENTITY_NAME.vhd"
    exit 1
fi

# Compile the testbench file
echo "Compiling $TESTBENCH_NAME.vhd..."
ghdl -a "$TB_PATH/$TESTBENCH_NAME.vhd"
if [ $? -ne 0 ]; then
    echo "Error compiling $TESTBENCH_NAME.vhd"
    exit 1
fi

# Elaborate the design
echo "Elaborating $TESTBENCH_NAME..."
ghdl -e "$TESTBENCH_NAME"
if [ $? -ne 0 ]; then
    echo "Error elaborating $TESTBENCH_NAME"
    exit 1
fi

# Run the simulation and generate the VCD file
echo "Running the simulation..."
ghdl -r "$TESTBENCH_NAME" --vcd=wave.vcd --stop-time=5000ns
if [ $? -ne 0 ]; then
    echo "Error running simulation for $TESTBENCH_NAME"
    exit 1
fi

# Open the wave.vcd file in GTKWave
echo "Opening waveform in GTKWave..."
gtkwave wave.vcd &
