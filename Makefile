.PHONY: clean all core
VHEADERS:=define.h parameter.h
VFILES:=addrdec.v sram.v top.v timer.v busarb.v slaves.v dmactr.v decoder.v executor.v alu.v core.v register.v
BUSTESTFILE:=test.v
CORETESTFILE:=coretest.v

core: $(CORETESTFILE) $(VFILES) $(VHEADERS)
	ncverilog +access+r $(CORETESTFILE) $(VFILES)

all: dump.vcd

dump.vcd: $(BUSTESTFILE) $(VFILES) $(VHEADERS)
	ncverilog +access+r $(BUSTESTFILE) $(VFILES)

dat: mips32test.dat

mips32test.dat: mips32test.asm
	asm32.pl $^ -o $@

clean:
	rm -rf INCA_libs ncverilog.log ncverilog.key dump.vcd sim.log
	rm -rf *.vcd *.trn *.dsn

