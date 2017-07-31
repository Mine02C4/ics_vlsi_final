#
# Step 1: Setup (File --> Import Design)
#
redirect Default.view {
echo "create_library_set -name default -timing {/home/staff2/matutani/lib/slow.lib}"
echo "create_constraint_mode -name default -sdc_files {core.sdc}"
echo "create_delay_corner -name default -library_set {default}"
echo "create_analysis_view -name default -constraint_mode {default} -delay_corner {default}"
echo "set_analysis_view -setup {default} -hold {default}"
}
set init_top_cell core
set init_verilog core.vnet
set init_lef_file /home/staff2/matutani/lib/cells.lef
set init_pwr_net VDD
set init_gnd_net VSS
set init_mmmc_file Default.view
init_design

#
# Step 2: Floorplan (Floorplan --> Specify Floorplan)
#
floorPlan -s 150 150 15 15 15 15 

#editpin -pin clk	-layer metal3 -spreadType CENTER -side TOP -use CLOCK
#editpin -pin reset	-layer metal3 -spreadType CENTER -side TOP -use SIGNAL
#editpin -pin memdata[0]	-layer metal3 -spreadType CENTER -side TOP -use SIGNAL
#editpin -pin memdata[1]	-layer metal3 -spreadType CENTER -side TOP -use SIGNAL
#editpin -pin memdata[2]	-layer metal3 -spreadType CENTER -side TOP -use SIGNAL
#editpin -pin memdata[3]	-layer metal3 -spreadType CENTER -side TOP -use SIGNAL
#editpin -pin memdata[4]	-layer metal3 -spreadType CENTER -side TOP -use SIGNAL
#editpin -pin memdata[5]	-layer metal3 -spreadType CENTER -side LEFT -use SIGNAL
#editpin -pin memdata[6]	-layer metal3 -spreadType CENTER -side LEFT -use SIGNAL
#editpin -pin memdata[7]	-layer metal3 -spreadType CENTER -side LEFT -use SIGNAL
#editpin -pin memread	-layer metal3 -spreadType CENTER -side LEFT -use SIGNAL
#editpin -pin memwrite	-layer metal3 -spreadType CENTER -side LEFT -use SIGNAL
#editpin -pin adr[0]	-layer metal3 -spreadType CENTER -side LEFT -use SIGNAL
#editpin -pin adr[1]	-layer metal3 -spreadType CENTER -side LEFT -use SIGNAL
#editpin -pin adr[2]	-layer metal3 -spreadType CENTER -side BOTTOM -use SIGNAL
#editpin -pin adr[3]	-layer metal3 -spreadType CENTER -side BOTTOM -use SIGNAL
#editpin -pin adr[4]	-layer metal3 -spreadType CENTER -side BOTTOM -use SIGNAL
#editpin -pin adr[5]	-layer metal3 -spreadType CENTER -side BOTTOM -use SIGNAL
#editpin -pin adr[6]	-layer metal3 -spreadType CENTER -side BOTTOM -use SIGNAL
#editpin -pin adr[7]	-layer metal3 -spreadType CENTER -side BOTTOM -use SIGNAL
#editpin -pin writedata[0]	-layer metal3 -spreadType CENTER -side BOTTOM -use SIGNAL
#editpin -pin writedata[1]	-layer metal3 -spreadType CENTER -side RIGHT -use SIGNAL
#editpin -pin writedata[2]	-layer metal3 -spreadType CENTER -side RIGHT -use SIGNAL
#editpin -pin writedata[3]	-layer metal3 -spreadType CENTER -side RIGHT -use SIGNAL
#editpin -pin writedata[4]	-layer metal3 -spreadType CENTER -side RIGHT -use SIGNAL
#editpin -pin writedata[5]	-layer metal3 -spreadType CENTER -side RIGHT -use SIGNAL
#editpin -pin writedata[6]	-layer metal3 -spreadType CENTER -side RIGHT -use SIGNAL
#editpin -pin writedata[7]	-layer metal3 -spreadType CENTER -side RIGHT -use SIGNAL

saveDesign floor.enc

#
# Step 3: Power ring (Power --> Power Planning --> Add Ring)
#
addRing -nets {VSS VDD} -type core_rings \
  -spacing_top 2 -spacing_bottom 2 -spacing_right 2 -spacing_left 2 \
  -width_top 4 -width_bottom 4 -width_right 4 -width_left 4 \
  -jog_distance 0.095 -threshold 0.095 \
  -layer_top metal10 -layer_bottom metal10 -layer_right metal9 \
  -layer_left metal9 \
  -stacked_via_top_layer metal10 -stacked_via_bottom_layer metal1 

#
# Step 4: Power stripe (Power --> Power Planning --> Add Striple)
#
addStripe -nets {VSS VDD} -layer metal8 -width 4 -spacing 2 \
  -block_ring_top_layer_limit metal9 -block_ring_bottom_layer_limit metal7 \
  -padcore_ring_top_layer_limit metal9 -padcore_ring_bottom_layer_limit metal7 \
  -stacked_via_top_layer metal10 -stacked_via_bottom_layer metal1 \
  -set_to_set_distance 50 -xleft_offset 50 -merge_stripes_value 0.095 \
  -max_same_layer_jog_length 1.6 

#
# Step 5: Power route (Route --> Special Route)
#
sroute -nets {VSS VDD} -layerChangeRange {1 10} \
  -connect { blockPin padPin padRing corePin floatingStripe } \
  -blockPinTarget { nearestRingStripe nearestTarget } \
  -padPinPortConnect { allPort oneGeom } \
  -checkAlignedSecondaryPin 1 -blockPin useLef -allowJogging 1 \
  -crossoverViaBottomLayer 1 -allowLayerChange 1 -targetViaTopLayer 10 \
  -crossoverViaTopLayer 10 -targetViaBottomLayer 1 

saveDesign power.enc

#
# Step 6: Placement (Place --> Standard Cell)
#
placeDesign

#
# Step 7: Optimization (preCTS) (ECO --> Optimize Design)
#
setDesignMode -process 45
setDelayCalMode -engine aae -SIAware true
setAnalysisMode -analysisType onChipVariation -cppr both

optDesign -preCTS

#
# Step 8: Clock tree synthesis (CTS) (command line only)
#         Clock tree check (Clock --> CCOpt Clock Tree Debugger)
#
set_ccopt_property buffer_cells {CLKBUF_X1 CLKBUF_X2 CLKBUF_X3}
ccopt_design

saveDesign cts.enc

#
# Step 9: Optimization (postCTS) (ECO --> Optimize Design)
#
optDesign -postCTS -hold

#
# Step 10: Detailed route (Route --> Nano Route --> Route)
#
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
routeDesign -globalDetail

#
# Step 11: Optimization (postRoute) (ECO --> Optimize Design)
#
optDesign -postRoute
optDesign -postRoute -hold

saveDesign route.enc

#
# Step 12: Add fillers (Place --> Physical Cells --> Add Filler)
#
addFiller -prefix FILLER -cell FILLCELL_X1 FILLCELL_X2 FILLCELL_X4 \
  FILLCELL_X8 FILLCELL_X16 FILLCELL_X32 

#
# Step 13: Verification (LVS) (Verify --> Verify Connectivity)
#
verifyConnectivity -type all -error 1000 -warning 50

#
# Step 14: Verification (DRC) (Verify --> Verify Geometry)
#
verifyGeometry

#
# Step 15: Data out (Timing --> Extract RC, Timing --> Write SDF,
#                    File --> Save --> Netlist)
saveNetlist mips_final.vnet
isExtractRCModeSignoff
rcOut -spef mips.spef
write_sdf -recompute_parallel_arcs mips.sdf

saveDesign final.enc
