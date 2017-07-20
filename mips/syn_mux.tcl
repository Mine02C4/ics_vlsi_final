#
# Your design
#
set base_name "mux4"
set rtl_file  "mux4.v"

#
# Libraries
#
set target_library "~matutani/lib/typical.db"
set synthetic_library "dw_foundation.sldb"
set link_library [concat "*" $target_library $synthetic_library]
set symbol_library "generic.sldb"
define_design_lib WORK -path ./WORK

#
# Read RTL file(s)
#
analyze -format verilog $rtl_file
elaborate $base_name
current_design $base_name

#
# Design synthesis
#
compile

#
# Output
#
write -format verilog -hierarchy -output ${base_name}.vnet

# report_timing
# report_reference -hier
# quit
