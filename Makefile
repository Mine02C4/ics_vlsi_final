.PHONY: clean all core sim
VHEADERS:=define.h parameter.h
VFILES:=addrdec.v sram.v top.v timer.v busarb.v slaves.v dmactr.v decoder.v executor.v alu.v core.v register.v
BUSTESTFILE:=test.v
CORETESTFILE:=coretest.v
MODEL:=~matutani/lib/cells.v

core: $(CORETESTFILE) $(VFILES) $(VHEADERS)
	ncverilog +access+r $(CORETESTFILE) $(VFILES)

all: dump.vcd

dump.vcd: $(BUSTESTFILE) $(VFILES) $(VHEADERS)
	ncverilog +access+r $(BUSTESTFILE) $(VFILES)

dat: mips32test.dat

mips32test.dat: mips32test.asm
	asm32.pl $^ -o $@

clean:
	rm -rf INCA_libs ncverilog.log dump.trn dump.dsn sdf.log mips.saif
	rm -rf *.vcd *.trn *.dsn
	rm -rf command.log default.svf WORK *.enc.dat *.enc
	rm -rf innovus.* *.rpt timingReports Default.view


#
# Step 1: RTL simulation
#
sim: $(CORETESTFILE) $(VFILES)
	ncverilog +delay_mode_zero +access+r $(CORETESTFILE) $(VFILES) | tee sim.log

#
# Step 2: Synthesis
#
syn:
	dc_shell-xg-t -f scripts/syn.tcl | tee syn.log

#
# Step 3: Place-and-route
#
par:
	innovus -init scripts/par.tcl | tee par.log

#
# Step 4: Static timing analysis
#
sta:
	dc_shell-xg-t -f scripts/sta.tcl | tee sta.log

#
# Step 5: Delay simulation 
#
dsim:
	ncverilog +define+__POST_PR__ +access+r -v ${MODEL} coretest.v mips_final.vnet | tee dsim.log

#
# Step 6: Power estimation 
#
power:
	vcd2saif -input dump.vcd -output mips.saif
	dc_shell-xg-t -f scripts/power.tcl | tee power.log

#
# Remove unnecessary files
#
allclean:
	make clean
	rm -f sim.log syn.log par.log sta.log power.log dsim.log dump.vcd
	rm -f mips.vnet mips_final.vnet mips.sdc mips.sdf mips.spef mips.sdf.X
	rm -f mips_final.vnet mips.sdf mips.spef mips.sdf.X
	rm -rf .simvision .cadence .*.rs.fp .*.rs.fp.spr
