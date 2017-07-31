.PHONY: clean all
VHEADERS:=define.h parameter.h
VFILES:=addrdec.v sram.v top.v timer.v busarb.v slaves.v dmactr.v decoder.v executor.v alu.v core.v register.v
BUSTESTFILE:=test.v
CORETESTFILE:=

all: dump.vcd

dump.vcd: $(BUSTESTFILE) $(VFILES) $(VHEADERS)
	ncverilog +access+r $(BUSTESTFILE) $(VFILES)

clean:
	rm -rf INCA_libs ncverilog.log ncverilog.key dump.vcd sim.log
	rm -rf *.vcd *.trn *.dsn

